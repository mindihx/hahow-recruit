# frozen_string_literal: true

module Admin
  class CourseSerializer
    include JSONAPI::Serializer

    attributes :name, :teacher_name
    attribute :description, if: ->(_course, params) { !params[:hide_detail] }

    attribute :chapters do |course, params|
      options = {
        params: { hide_detail: params[:hide_detail] }
      }
      ChapterSerializer.new(course.chapters, options).serializable_hash[:data]
    end
  end
end
