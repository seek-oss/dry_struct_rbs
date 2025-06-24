# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DryStructRbs::Generator do
  subject(:result) { described_class.new(directory_or_file, config).generate }

  let(:config) { {} }

  context 'with a file in input' do
    let(:directory_or_file) { 'spec/fixtures/test_dtos/test_dto1.rb' }

    it 'generates the correct RBS content' do
      expected_rbs_content1 = <<~RBS
        module TestDtos
          class TestDto1 < Dry::Struct
            attr_reader hsi: Hash[String, Integer]

            attr_reader huu: Hash[untyped, untyped]

            attr_reader as: Array[String]

            attr_reader au: Array[untyped]?

            attr_reader b: bool

            attr_reader f: Float

            attr_reader s: String

            attr_reader so: String?

            attr_reader t: Time

            attr_reader i: Integer

            attr_reader u: untyped
          end
        end
      RBS

      expect(result[0]).to eq(
        {
          rb_file_name: 'spec/fixtures/test_dtos/test_dto1.rb',
          rbs_file_name: 'sig/spec/fixtures/test_dtos/test_dto1.rbs',
          rbs_content: expected_rbs_content1
        }
      )
    end
  end

  context 'with a directory in input' do
    let(:directory_or_file) { 'spec/fixtures/test_dtos' }

    let(:config) do
      {
        dry_types_namespace: 'My::Types'
      }
    end

    it 'generates the correct RBS content' do
      expected_rbs_content2 = <<~RBS
        class TestDtos::TestDto2 < My::Dto::NonStrict
          attr_reader hsi: Hash[String, Integer]

          attr_reader huu: Hash[untyped, untyped]

          attr_reader as: Array[String]

          attr_reader au: Array[untyped]?

          attr_reader b: bool

          attr_reader f: Float

          attr_reader s: String

          attr_reader so: String?

          attr_reader t: Time

          attr_reader i: Integer

          attr_reader u: untyped
        end
      RBS

      expect(result[1]).to eq(
        {
          rb_file_name: 'spec/fixtures/test_dtos/test_dto2.rb',
          rbs_file_name: 'sig/spec/fixtures/test_dtos/test_dto2.rbs',
          rbs_content: expected_rbs_content2
        }
      )
    end
  end

  context 'without types namespace' do
    let(:config) { {} }
    let(:directory_or_file) { 'spec/fixtures/test_dtos/test_dto3.rb' }

    it 'generates the correct RBS content' do
      expected_rbs_content3 = <<~RBS
        module TestDtos::ModuleAgain::AndAgain
          class TestDto3 < Dry::Struct
            attr_reader hsi: Hash[String, Integer]

            attr_reader huu: Hash[untyped, untyped]

            attr_reader as: Array[String]

            attr_reader au: Array[untyped]?

            attr_reader b: bool

            attr_reader f: Float

            attr_reader s: String

            attr_reader so: String?

            attr_reader t: Time

            attr_reader i: Integer

            attr_reader u: untyped
          end
        end
      RBS

      expect(result[0]).to eq(
        {
          rb_file_name: 'spec/fixtures/test_dtos/test_dto3.rb',
          rbs_file_name: 'sig/spec/fixtures/test_dtos/module_again/and_again/test_dto3.rbs',
          rbs_content: expected_rbs_content3
        }
      )

      expected_rbs_content4 = <<~RBS
        module TestDtos::ModuleAgain::AndAgain
          class TestDto4 < Dry::Struct
            attr_reader u: untyped
          end
        end
      RBS
      expect(result[1]).to eq(
        {
          rb_file_name: 'spec/fixtures/test_dtos/test_dto3.rb',
          rbs_file_name: 'sig/spec/fixtures/test_dtos/module_again/and_again/test_dto4.rbs',
          rbs_content: expected_rbs_content4
        }
      )

      expected_rbs_content5 = <<~RBS
        module TestDtos::ModuleAgain::AndAgain
          class TestDto4
            class TestDto5 < Dry::Struct
              attr_reader u: untyped
            end
          end
        end
      RBS
      expect(result[2]).to eq(
        {
          rb_file_name: 'spec/fixtures/test_dtos/test_dto3.rb',
          rbs_file_name: 'sig/spec/fixtures/test_dtos/module_again/and_again/test_dto4/test_dto5.rbs',
          rbs_content: expected_rbs_content5
        }
      )
    end
  end
end
