# frozen_string_literal: true

require 'unparser'
require 'fileutils'
require 'rbs'
require 'stringio'
require 'prism'

module DryStructRbs
  class Generator
    DEFAULT_CONFIG = {
      rbs_output_dir: 'sig',
      ignored_dirs: [],
      dry_types_namespace: 'Types',
      project_root: 'app',
      write_files: false,
      overwrite_files: false
    }.freeze

    attr_reader :input_path, :config

    def initialize(input_path, config = {})
      @input_path = input_path
      @config = DEFAULT_CONFIG.merge(config)
      @rbs_files = []
      @type_mapper = TypeMapper.new(@config[:dry_types_namespace])
    end

    def generate
      collect_rbs_files
      write_files if config[:write_files]
      @rbs_files
    end

    private

    def collect_rbs_files
      files = File.file?(input_path) ? [input_path] : Dir.glob(File.join(input_path, '**/*.rb'))
      files.each { |file| process_ruby_file(file) }
    end

    def process_ruby_file(file_path)
      ast = parse_file(file_path)
      return unless ast

      traverse_ast(ast, file_path)
    end

    def parse_file(file_path)
      Prism::Translation::Parser.parse_file(file_path)
    end

    def traverse_ast(node, file_path, namespace_stack = [], namespace_types = [])
      return unless node.is_a?(Parser::AST::Node)

      case node.type
      when :module
        module_name = extract_const_name(node.children[0])
        traverse_ast(node.children[1], file_path, namespace_stack + [module_name], namespace_types + [:module])
      when :class
        class_name = extract_const_name(node.children[0])
        superclass = extract_const_name(node.children[1])
        attributes = AttributeParser.new(node.children[2], @type_mapper).parse
        unless attributes.empty?
          rbs_content = generate_rbs(namespace_stack, namespace_types, class_name, attributes, superclass)
          rbs_file = build_rbs_file_path(file_path, class_name, namespace_stack.flat_map { _1.split('::') } + [class_name])
          @rbs_files << { rb_file_name: file_path, rbs_file_name: rbs_file, rbs_content: rbs_content }
        end
        traverse_ast(node.children[2], file_path, namespace_stack + [class_name], namespace_types + [:class])
      else
        node.children.each { |child| traverse_ast(child, file_path, namespace_stack, namespace_types) }
      end
    end

    def generate_rbs(namespace_stack, namespace_types, class_name, attributes, superclass)
      members = attributes.map do |attr|
        RBS::AST::Members::AttrReader.new(
          name: attr[:name].to_sym,
          type: RBS::Parser.parse_type(attr[:rbs_type]),
          location: nil,
          comment: nil,
          ivar_name: nil,
          kind: :instance,
          annotations: [],
          visibility: nil
        )
      end

      class_decl = RBS::AST::Declarations::Class.new(
        name: RBS::TypeName.new(namespace: nil, name: class_name.to_sym),
        type_params: [],
        super_class: if superclass && !superclass.empty?
                       RBS::AST::Declarations::Class::Super.new(
                         name: RBS::Parser.parse_type(superclass),
                         args: [],
                         location: nil
                       )
                     end,
        members: members,
        location: nil,
        comment: nil,
        annotations: []
      )

      decls = [class_decl]
      namespace_stack.zip(namespace_types).reverse_each do |ns, type|
        decls = if type == :module
                  [RBS::AST::Declarations::Module.new(
                    name: RBS::Parser.parse_type(ns),
                    self_types: [],
                    type_params: [],
                    members: decls,
                    location: nil,
                    comment: nil,
                    annotations: []
                  )]
                else
                  [RBS::AST::Declarations::Class.new(
                    name: RBS::TypeName.new(namespace: nil, name: ns.to_sym),
                    type_params: [],
                    super_class: nil,
                    members: decls,
                    location: nil,
                    comment: nil,
                    annotations: []
                  )]
                end
      end

      out = StringIO.new
      writer = RBS::Writer.new(out: out)
      writer.write decls
      out.string
    end

    def extract_const_name(node)
      names = []
      while node.is_a?(Parser::AST::Node)
        case node.type
        when :const
          names.unshift(node.children[1])
          node = node.children[0]
        when :cbase
          names.unshift('')
          break
        else
          break
        end
      end
      names.join('::')
    end

    def build_rbs_file_path(rb_file_name, class_name, namespace_stack = [])
      relative_dir = File.dirname(rb_file_name)
      paths_to_substract = config[:ignored_dirs] + [config[:project_root]]
      paths_to_substract.each { |path| relative_dir = relative_dir.sub(%r{^#{path}/}, '') }
      dir_parts = relative_dir.split('/')
      parent_namespaces = namespace_stack[0...-1].map { |n| underscore(n) }
      parent_namespaces.shift while !parent_namespaces.empty? && dir_parts.include?(parent_namespaces.first)
      dir = [config[:rbs_output_dir], relative_dir, parent_namespaces.reject(&:empty?)].join('/')
      File.join(dir, "#{underscore(class_name.split('::').last)}.rbs")
    end

    def underscore(str)
      str.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end

    def write_files
      @rbs_files.each do |file|
        next unless config[:overwrite_files] || !File.exist?(file[:rbs_file_name]) || File.read(file[:rbs_file_name]).strip.empty?

        FileUtils.mkdir_p(File.dirname(file[:rbs_file_name]))
        File.write(file[:rbs_file_name], file[:rbs_content])
      end
    end
  end

  class AttributeParser
    def initialize(node, type_mapper)
      @node = node
      @type_mapper = type_mapper
    end

    def parse
      return [] unless @node.is_a?(Parser::AST::Node)
      return @node.children.flat_map { |child| self.class.new(child, @type_mapper).parse } if @node.type == :begin

      if @node.type == :send && %i[attribute attribute?].include?(@node.children[1])
        [parse_attribute(@node)]
      else
        []
      end
    end

    private

    def parse_attribute(node)
      method = node.children[1]
      name = node.children[2].children[0]
      type_info = @type_mapper.parse_type_info(node.children[3])
      {
        name: name,
        rbs_type: @type_mapper.build_rbs_type(*type_info[0..2], optional: method == :attribute? || type_info.last)
      }
    end
  end

  class TypeMapper
    def initialize(dry_types_namespace)
      @ns = dry_types_namespace
    end

    def parse_type_info(node)
      names = []
      key_type = nil
      value_type = nil
      optional = false
      while node.is_a?(Parser::AST::Node)
        case node.type
        when :const
          names.unshift(node.children[1])
          node = node.children[0]
        when :send
          if node.children[1] == :optional
            optional = true
            node = node.children[0]
          elsif node.children[1] == :of
            key_type = extract_const_name(node.children[2])
            value_type = extract_const_name(node.children[3]) if node.children[3]
            node = node.children[0]
          else
            break
          end
        else
          break
        end
      end
      [names.join('::'), key_type, value_type, optional]
    end

    def build_rbs_type(type, key_type = nil, value_type = nil, optional: false)
      type_map = {
        "#{@ns}::String" => 'String',
        "#{@ns}::Integer" => 'Integer',
        "#{@ns}::Float" => 'Float',
        "#{@ns}::Bool" => 'bool',
        "#{@ns}::Time" => 'Time',
        "#{@ns}::JSON::Time" => 'Time',
        "#{@ns}::Date" => 'Date',
        "#{@ns}::JSON::Date" => 'Date',
        "#{@ns}::Array" => -> { "Array[#{build_rbs_type(key_type)}]" },
        "#{@ns}::Hash" => -> { "Hash[#{build_rbs_type(key_type)}, #{build_rbs_type(value_type)}]" },
        "#{@ns}::JSON::Hash" => -> { "Hash[#{build_rbs_type(key_type)}, #{build_rbs_type(value_type)}]" }
      }
      result = type_map[type].respond_to?(:call) ? type_map[type].call : type_map[type] || 'untyped'
      result += '?' if result != 'untyped' && optional
      result
    end

    private

    def extract_const_name(node)
      names = []
      while node.is_a?(Parser::AST::Node)
        case node.type
        when :const
          names.unshift(node.children[1])
          node = node.children[0]
        when :cbase
          names.unshift('')
          break
        else
          break
        end
      end
      names.join('::')
    end
  end
end
