# frozen_string_literal: true

module Admin
  class UnitSerializer
    include JSONAPI::Serializer

    attributes :name
    attribute :description, if: ->(_unit, params) { !params[:hide_detail] }
    attribute :content, if: ->(_unit, params) { !params[:hide_detail] }
  end
end
