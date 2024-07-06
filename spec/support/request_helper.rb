# frozen_string_literal: true

module RequestHelper
  def json_body
    JSON.parse(response.body, symbolize_names: true)
  end

  def response_error_message
    json_body.dig(:error, :message)
  end

  def post_as_json(*args, **kwargs)
    kwargs[:as] = :json
    post(*args, **kwargs)
  end

  def patch_as_json(*args, **kwargs)
    kwargs[:as] = :json
    patch(*args, **kwargs)
  end
end
