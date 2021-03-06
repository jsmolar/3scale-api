# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'three_scale_api/tools'
require 'openssl'

module ThreeScaleApi
  # Http Client
  class HttpClient
    attr_reader :endpoint,
                :admin_domain,
                :provider_key,
                :headers,
                :format,
                :http,
                :log,
                :logger_factory

    # Initializes HttpClient
    #
    # @param [String] endpoint 3Scale admin endpoint
    # @param [String] provider_key Provider key
    # @param [String] format Which format
    # @param [Boolean] verify_ssl Verify ssl certificate (default is 'true')
    def initialize(endpoint:,
                   provider_key:,
                   format: :json,
                   verify_ssl: true,
                   log_level: 'debug')
      @endpoint = URI(endpoint).freeze
      @admin_domain = @endpoint.host.freeze
      @provider_key = provider_key.freeze
      @logger_factory = ThreeScaleApi::Tools::LoggingFactory.new(log_level: log_level)
      @log = @logger_factory.get_instance(name: 'HttpClient')
      @http = Net::HTTP.new(admin_domain, @endpoint.port)
      @http.use_ssl = @endpoint.is_a?(URI::HTTPS)
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless verify_ssl
      @format = format
      @headers = {
          'Accept' => "application/#{format}",
          'Content-Type' => "application/#{format}",
          'Authorization' => 'Basic ' + [":#{@provider_key}"].pack('m').delete("\r\n")
      }

      if debug?
        @http.set_debug_output($stdout)
        @headers['Accept-Encoding'] = 'identity'
      end

      @headers.freeze
    end

    # Creates GET request to specified path
    #
    # @param [String] path Relative request path to endpoint
    # @param [Hash] params Optional parameters for the request
    def get(path, params: nil)
      @log.debug("[GET] #{path}")
      parse @http.get(format_path_n_query(path, params), headers)
    end

    # Creates PATCH request to specified path
    #
    # @param [String] path Relative request path to endpoint
    # @param [Hash] body Request's body
    # @param [Hash] params Optional parameters for the request
    def patch(path, body:, params: nil)
      @log.debug("[PATCH] #{path}: #{body}")
      parse @http.patch(format_path_n_query(path, params), serialize(body), headers)
    end

    # Creates POST request to specified path
    #
    # @param [String] path Relative request path to endpoint
    # @param [Hash] body Request's body
    # @param [Hash] params Optional parameters for the request
    def post(path, body:, params: nil)
      @log.debug("[POST] #{path}: #{body}")
      parse @http.post(format_path_n_query(path, params), serialize(body), headers)
    end

    # Creates PUT request to specified path
    #
    # @param [String] path Relative request path to endpoint
    # @param [Hash] body Request's body
    # @param [Hash] params Optional parameters for the request
    def put(path, body: nil, params: nil)
      @log.debug("[PUT] #{path}: #{body}")
      parse @http.put(format_path_n_query(path, params), serialize(body), headers)
    end

    # Creates DELETE request to specified path
    #
    # @param [String] path Relative request path to endpoint
    # @param [Hash] params Optional parameters for the request
    def delete(path, params: nil)
      @log.debug("[DELETE] #{path}")
      parse @http.delete(format_path_n_query(path, params), headers)
    end

    # Parses entity params from the response and checks status code
    #
    # @param [::Net::HTTPResponse] response Response received using some of the request methods
    # @return [Hash] Entity params
    def parse(response)
      case response
      when Net::HTTPUnprocessableEntity, Net::HTTPSuccess then parser.decode(response.body)
      when Net::HTTPForbidden then forbidden!(response)
      when Net::HTTPNotFound then not_found!(response)
      else "Can't handle #{response.inspect}"
      end
    end

    # Custom exception class that is thrown when the resource is not found
    class NotFoundError < StandardError; end

    # Not found - wrapper to throw NotFoundError
    #
    # @param [::Net::HTTPResponse] response Response received using some of the request methods
    # @raise [NotFoundError] Required resource hasn't been found
    def not_found!(response)
      raise NotFoundError, response
    end

    # Custom exception class that is thrown when the access to resource is forbidden
    class ForbiddenError < StandardError; end

    # Forbidden access - Wrapper to throw ForbiddenError
    #
    # @param [::Net::HTTPResponse] response Response received using some of the request methods
    # @raise [ForbiddenError] Access to required resource has been denied
    def forbidden!(response)
      raise ForbiddenError, response
    end

    # Takes request body and serializes it to JSON
    #
    # @param [String, Hash] body Body is serialized to JSON if it is not a string
    # @return [String] Serialized body
    def serialize(body)
      case body
      when nil then nil
      when String then body
      else parser.encode(body)
      end
    end

    def parser
      case @format
      when :json then JSONParser
      else "unknown format #{format}"
      end
    end

    protected

    def debug?
      ENV.fetch('THREESCALE_LOG', 'info') == 'debug'
    end

    # Helper to create a string representing a path plus a query string
    def format_path_n_query(path, params)
      path = "#{path}.#{@format}"
      path += "?#{URI.encode_www_form(params)}" unless params.nil?
      path
    end

    # Json parser module
    module JSONParser
      module_function

      # Decodes
      def decode(string)
        case string
        when nil, ' ', '' then nil
        else ::JSON.parse(string)
        end
      end

      def encode(query)
        ::JSON.generate(query)
      end
    end
  end
end
