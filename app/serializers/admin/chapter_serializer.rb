# frozen_string_literal: true

module Admin
  class ChapterSerializer
    include JSONAPI::Serializer

    attributes :name

    attribute :units do |chapter, params|
      options = {
        params: { hide_detail: params[:hide_detail] }
      }
      UnitSerializer.new(chapter.units, options).serializable_hash[:data]
    end
  end
end
