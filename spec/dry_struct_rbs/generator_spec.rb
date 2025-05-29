# frozen_string_literal: true

require 'spec_helper'
require 'dry-struct'
require 'rbs'
require 'dry_struct_rbs'

module Types
  include Dry.Types()
end

class Person < Dry::Struct
  attribute :name, Types::String
  attribute :age, Types::Integer
  attribute :tags, Types::Array.of(Types::String)
end

RSpec.describe DryStructRBS::Generator do
  subject(:generator) { described_class.new(Person) }

  describe '#generate' do
    let(:declaration) { generator.generate }

    it 'returns an RBS class declaration' do
      expect(declaration).to be_a(RBS::AST::Declarations::Class)
      expect(declaration.name.to_s).to eq('::Person')
    end

    it 'includes attribute readers for all attributes' do
      attr_names = declaration.members.select { |m| m.is_a?(RBS::AST::Members::AttrReader) }.map(&:name)
      expect(attr_names).to contain_exactly(:name, :age, :tags)
    end

    it 'assigns correct types to attributes' do
      name_attr = declaration.members.find { |m| m.is_a?(RBS::AST::Members::AttrReader) && m.name == :name }
      age_attr  = declaration.members.find { |m| m.is_a?(RBS::AST::Members::AttrReader) && m.name == :age }
      tags_attr = declaration.members.find { |m| m.is_a?(RBS::AST::Members::AttrReader) && m.name == :tags }

      expect(name_attr.type.to_s).to eq('String')
      expect(age_attr.type.to_s).to eq('Integer')
      expect(tags_attr.type.to_s).to eq('Array[String]')
    end

    it 'includes an initialize method with keyword arguments for all attributes' do
      init_method = declaration.members.find do |m|
        m.is_a?(RBS::AST::Members::MethodDefinition) && m.name == :initialize
      end
      expect(init_method).not_to be_nil

      param_names = init_method.types.first.type.required_keywords.map(&:name)
      expect(param_names).to contain_exactly(:name, :age, :tags)
    end
  end
end
