# frozen_string_literal: true

require_relative 'esp_adapter/version'

require 'faraday'
require 'multi_json'
require 'esp_adapter/base'
require 'esp_adapter/mailchimp'
require 'esp_adapter/esp_error'

module EspAdapter
  class Error < StandardError; end

  # Error classes for specific HTTP error status codes.
  class UnauthorizedError < StandardError; end
  class BadRequestError < StandardError; end
  class ForbiddenError < StandardError; end
  class ResourceNotFound < StandardError; end
  class RequestTimeoutError < StandardError; end
  class UnprocessableEntityError < StandardError; end

  # Error classes for generic client and server errors.
  class ClientError < StandardError; end
  class ServerError < StandardError; end
end
