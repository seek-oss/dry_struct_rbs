# frozen_string_literal: true

module TestDtos
  class TestDto1 < Dry::Struct
    attribute :hsi, Types::Hash.of(Types::String, Types::Integer)
    attribute :huu, Types::Hash.of(Types::Any, Types::Any)
    attribute :as, Types::Array.of(Types::String)
    attribute :au, Types::Array.of(Types::Any).optional
    attribute :b, Types::Bool
    attribute :f, Types::Float
    attribute :s, Types::String
    attribute :so, Types::String.optional
    attribute :t, Types::Time
    attribute :i, Types::Integer
    attribute? :u, Types::Any
  end
end
