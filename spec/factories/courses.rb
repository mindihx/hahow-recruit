# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    name { Faker::Name.name }
    teacher_name { Faker::Name.name }
  end
end
