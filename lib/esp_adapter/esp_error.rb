# frozen_string_literal: true

module EspAdapter
  # Faraday error middleware to handle errors
  class EspError < Faraday::Response::RaiseError
    CLIENT_ERROR_STATUSES = (400..499)
    SERVER_ERROR_STATUSES = (500..599)

    # Method to handle completion of the request
    #
    # @param env [Hash]
    #
    def on_complete(env)
      case env[:status]
      when 400
        raise EspAdapter::BadRequestError, response_values(env)
      when 401
        raise EspAdapter::UnauthorizedError, response_values(env)
      when 403
        raise EspAdapter::ForbiddenError, response_values(env)
      when 404
        raise EspAdapter::ResourceNotFound, response_values(env)
      when 408
        raise EspAdapter::RequestTimeoutError, response_values(env)
      when 422
        raise EspAdapter::UnprocessableEntityError, response_values(env)
      when CLIENT_ERROR_STATUSES
        raise EspAdapter::ClientError, response_values(env)
      when SERVER_ERROR_STATUSES
        raise EspAdapter::ServerError, response_values(env)
      end
    end

    # Method to extract relevant response values from the environment
    #
    # @param env [Hash]
    # @param message [String, nil]
    #
    # @return [Hash]
    #
    def response_values(env, message = nil)
      body = JSON.parse(env.body)

      # Construct and return a hash containing status and message
      { status: env.status, message: message || body['detail'] }
    end
  end
end
