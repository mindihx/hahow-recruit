# frozen_string_literal: true

module Admin
  class CourseSerializer
    include JSONAPI::Serializer

    attributes :name, :teacher_name, :description
  end
end
