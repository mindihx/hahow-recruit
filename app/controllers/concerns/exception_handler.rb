# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :respond_not_found

    def error_object(error)
      {
        error: {
          message: error.message
        }
      }
    end

    def respond_not_found(error)
      render json: error_object(error), status: :not_found
    end
  end
end
