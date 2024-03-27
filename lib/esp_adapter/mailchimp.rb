# frozen_string_literal: true

module EspAdapter
  # Mailchimp class for interfacing with the Mailchimp APIs.
  class Mailchimp < Base
    DEFAULT_TIMEOUT = 60
    DEFAULT_WRITE_TIMEOUT = 60
    MAX_RETRIES = 1

    # Get lists
    #
    # @param api_key [String]
    # @param config [Hash]
    #
    def initialize(api_key, config: {})
      super(api_key)
      set_config(config:)
    end

    # Get lists
    #
    # @param opts [Hash]
    #
    # @retrun parsed API response [Hash]
    #
    def lists(opts: {})
      handle_errors do
        params = {}
        params[:fields] = opts[:fields] if opts.key?(:fields)
        params[:exclude_fields] = opts[:exclude_fields] if opts.key?(:exclude_fields)
        params[:count] = opts[:count] if opts.key?(:count)
        params[:offset] = opts[:offset] if opts.key?(:offset)
        params[:before_date_created] = opts[:before_date_created] if opts.key?(:before_date_created)
        params[:since_date_created] = opts[:since_date_created] if opts.key?(:since_date_created)
        params[:before_campaign_last_sent] = opts[:before_campaign_last_sent] if opts.key?(:before_campaign_last_sent)
        params[:since_campaign_last_sent] = opts[:since_campaign_last_sent] if opts.key?(:since_campaign_last_sent)
        params[:email] = opts[:email] if opts.key?(:email)
        params[:sort_field] = opts[:sort_field] if opts.key?(:sort_field)
        params[:sort_dir] = opts[:sort_dir] if opts.key?(:sort_dir)
        params[:has_ecommerce_store] = opts[:has_ecommerce_store] if opts.key?(:has_ecommerce_store)
        params[:include_total_contacts] = opts[:include_total_contacts] if opts.key?(:include_total_contacts)

        response = connection.get('lists') do |req|
          req.params = params
        end
        parse_response(response)
      end
    end

    # Get metrics of a list
    #
    # @param list_id [String]
    # @param opts [Hash]
    #
    # @retrun parsed API response [Hash]
    #
    def list_metrics(list_id, opts: {})
      handle_errors do
        params = {}
        params[:fields] = opts[:fields] if opts.key?(:fields)
        params[:exclude_fields] = opts[:exclude_fields] if opts.key?(:exclude_fields)
        params[:include_total_contacts] = opts[:include_total_contacts] if opts.key?(:include_total_contacts)

        path = "lists/#{list_id}"
        response = connection.get(path) do |req|
          req.params = params
        end

        parse_response(response)
      end
    end

    private

    # Set require configurations
    #
    # @param config [Hash]
    #
    def set_config(config: {})
      @timeout = config.fetch(:timeout, DEFAULT_TIMEOUT)
      @open_timeout = config.fetch(:write_timeout, DEFAULT_WRITE_TIMEOUT)
    end

    # Get datacenter server from API key
    #
    # @param api_key [String]
    #
    # @return server [String]
    def get_server_from_api_key(api_key = '')
      split = api_key.split('-')
      server = 'invalid-server'

      server = split[1] if split.length == 2
      server
    rescue StandardError
      nil
    end

    # Build base64 encoded token for basic auth.
    #
    # @param api_key [String]
    #
    # @return encoded URL [String]
    def encoded_basic_token(api_key)
      Base64.urlsafe_encode64("user:#{api_key}")
    end

    # Create Faraday connection object
    #
    # @return [Faraday object]
    #
    def connection
      Faraday.new(url) do |conn|
        conn.response :raise_error
        conn.use EspAdapter::EspError
        conn.headers['Content-Type'] = 'application/json'
        conn.headers['Authorization'] = "Basic #{encoded_basic_token(@api_key)}"
        conn.options.timeout = @timeout
        conn.options.open_timeout = @open_timeout
      end
    end

    # Get URL with Datacenter.
    #
    # @return [String]
    #
    def url
      server = get_server_from_api_key(@api_key)

      "https://#{server}.api.mailchimp.com/3.0"
    end

    # Parse API response.
    #
    # @param response[Faraday Response]
    # @param options[Hash]
    #
    # @return [Hash]
    #
    def parse_response(response, **options)
      parsed_response = nil

      if response.body
        begin
          parsed_response = MultiJson.load(response.body, **options)
        rescue MultiJson::ParseError
          raise EspAdapter::ServerError, { status: 500, message: 'Something went wrong!' }
        end
      end

      parsed_response
    end

    # Handle API errors and raise exception if any
    #
    def handle_errors
      retries = 0

      yield
    rescue EspAdapter::RequestTimeoutError => e
      raise e unless retries < MAX_RETRIES

      retries += 1

      retry
    rescue Faraday::ConnectionFailed, Socket::ResolutionError => e
      if e.message.include?('nodename nor servname provided')
        raise EspAdapter::UnauthorizedError,
              { status: 401,
                message: "Your API key may be invalid, or you've attempted to access the wrong datacenter" }
      end
    end
  end
end
