# frozen_string_literal: true

FactoryBot.define do
  factory :unit do
    association :chapter

    name { "unit name" }
    content { "unit content" }
  end
end
