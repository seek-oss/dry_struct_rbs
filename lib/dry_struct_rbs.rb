# frozen_string_literal: true

require 'dry-struct'
require 'rbs'

module DryStructRBS
  class Generator
    def initialize(struct_class)
      @struct_class = struct_class
    end

    def generate
      RBS::AST::Declarations::Class.new(
        name: type_name,
        type_params: [],
        super_class: struct_superclass,
        members: [
          *attribute_members,
          *method_members
        ],
        location: nil,
        annotations: [],
        comment: nil
      )
    end

    private

    def type_name
      @struct_class.name&.yield_self { |n| RBS::TypeName.new(name: n.to_sym, namespace: RBS::Namespace.root) } ||
        raise('Anonymous classes not supported')
    end

    def struct_superclass
      if @struct_class.superclass == Dry::Struct
        nil
      else
        RBS::AST::Declarations::Class::Super.new(
          name: RBS::TypeName.new(name: @struct_class.superclass.name.to_sym, namespace: RBS::Namespace.root),
          args: []
        )
      end
    end

    def attribute_members
      @struct_class.schema.keys.map do |key|
        RBS::AST::Members::AttrReader.new(
          name: key.name,
          type: convert_type(key.type),
          ivar_name: "@#{key.name}",
          kind: :instance,
          location: nil,
          comment: nil,
          visibility: :public,
          annotations: []
        )
      end
    end

    def method_members
      [
        RBS::AST::Members::MethodDefinition.new(
          name: :initialize,
          kind: :instance,
          types: [
            RBS::MethodType.new(
              type_params: [],
              type: RBS::Types::Function.new(
                required_positionals: [],
                optional_positionals: [],
                rest_positionals: nil,
                trailing_positionals: [],
                required_keywords: @struct_class.schema.keys.map do |key|
                  RBS::Types::Function::Param.new(
                    name: key.name,
                    type: convert_type(key.type),
                    location: nil
                  )
                end,
                optional_keywords: [],
                rest_keywords: nil,
                return_type: RBS::Types::Bases::Void.new(location: nil)
              ),
              block: nil,
              location: nil
            )
          ],
          location: nil,
          comment: nil,
          overload: false,
          visibility: :public,
          annotations: []
        )
      ]
    end

    def convert_type(dry_type)
      primitive = dry_type.respond_to?(:primitive) ? dry_type.primitive : nil

      case primitive.name
      when String.name
        RBS::Types::ClassInstance.new(
          name: RBS::TypeName.new(name: :String, namespace: RBS::Namespace.empty),
          args: [],
          location: nil
        )
      when Integer.name
        RBS::Types::ClassInstance.new(
          name: RBS::TypeName.new(name: :Integer, namespace: RBS::Namespace.empty),
          args: [],
          location: nil
        )
      when Float.name
        RBS::Types::ClassInstance.new(
          name: RBS::TypeName.new(name: :Float, namespace: RBS::Namespace.empty),
          args: [],
          location: nil
        )
      when Array.name
        member_type = dry_type.respond_to?(:member) ? convert_type(dry_type.member) : RBS::Types::Bases::Any.new(location: nil)
        RBS::Types::ClassInstance.new(
          name: RBS::TypeName.new(name: :Array, namespace: RBS::Namespace.empty),
          args: [member_type],
          location: nil
        )
      when Hash.name
        key_type = dry_type.respond_to?(:key_type) ? convert_type(dry_type.key_type) : RBS::Types::Bases::Any.new(location: nil)
        value_type = dry_type.respond_to?(:value_type) ? convert_type(dry_type.value_type) : RBS::Types::Bases::Any.new(location: nil)
        RBS::Types::ClassInstance.new(
          name: RBS::TypeName.new(name: :Hash, namespace: RBS::Namespace.empty),
          args: [key_type, value_type],
          location: nil
        )
      else
        RBS::Types::Bases::Any.new(location: nil)
      end
    end
  end
end
