# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :respond_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :respond_bad_request
    rescue_from ArgumentError, with: :respond_bad_request

    def error_object(error)
      {
        error: {
          message: error.message
        }
      }
    end

    def respond_error(error, status)
      render json: error_object(error), status:
    end

    def respond_not_found(error)
      respond_error(error, :not_found)
    end

    def respond_bad_request(error)
      respond_error(error, :bad_request)
    end
  end
end
