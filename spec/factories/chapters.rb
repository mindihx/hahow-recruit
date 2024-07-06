# frozen_string_literal: true

FactoryBot.define do
  factory :chapter do
    association :course

    name { "chapter name" }
  end
end
