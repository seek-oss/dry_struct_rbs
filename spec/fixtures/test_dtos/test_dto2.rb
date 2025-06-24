# frozen_string_literal: true

class TestDtos::TestDto2 < My::Dto::NonStrict
  attribute :hsi, My::Types::Hash.of(My::Types::String, My::Types::Integer)
  attribute :huu, My::Types::Hash.of(My::Types::Any, My::Types::Any)
  attribute :as, My::Types::Array.of(My::Types::String)
  attribute :au, My::Types::Array.of(My::Types::Any).optional
  attribute :b, My::Types::Bool
  attribute :f, My::Types::Float
  attribute :s, My::Types::String
  attribute :so, My::Types::String.optional
  attribute :t, My::Types::Time
  attribute :i, My::Types::Integer
  attribute? :u, My::Types::Any
end
