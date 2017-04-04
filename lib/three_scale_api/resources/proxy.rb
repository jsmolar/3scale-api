require 'three_scale_api/resources/default'
module ThreeScaleApi
  module Resources
    # Proxy resource manager wrapper for proxy entity received by REST API
    class ProxyManager < DefaultManager
      attr_accessor :service

      # Creates instance of the Proxy resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client, service)
        super(http_client, entity_name: 'proxy', collection_name: 'proxies')
        @service = service
        @resource_instance = Proxy
      end

      def base_path
        super.concat("/services/#{@service['id']}/proxy")
      end

      def read
        @log.debug('Read')
        response = http_client.get("#{base_path}")
        resource_instance(response)
      end

      # Promotes proxy configuration from one env to another
      #
      # @param [Fixnum] config_id Configuration ID
      # @param [String] from From which environment
      # @param [String] to To which environment
      # @return [Proxy] Instance of the proxy resource
      def promote(config_id: 1, from: 'sandbox', to: 'production')
        @log.debug "Promote [#{config_id}] from \"#{from}\" to \"#{to}\""
        response = @http_client.post("#{base_path}/configs/#{from}/#{config_id}/promote", params: {to: to}, body: {})
        resource_instance(response)
      end

      # Gets list of the proxy configs for spec. environment
      #
      # @return [Array<Proxy>] Array of the instances of the proxy resource
      # @param [String] env Environment name
      def config_list(env: 'sandbox')
        @log.debug "Lists Configs for [#{env}]"
        response = http_client.get("#{base_path}/configs/#{env}")
        resource_instance(response)
      end

      # Reads configuration of the provided environment by provided ID
      #
      # @param [Fixnum] id Id of the configuration
      # @param [String] env Environment name
      # @return [Proxy] Instance of the proxy resource
      def config_read(id: 1, env: 'sandbox')
        response = http_client.get("#{base_path}/configs/#{env}/#{id}")
        resource_instance(response)
      end

      # Gets latest configuration of specified environment
      #
      # @param [String] env Environment name
      # @return [Proxy] Instance of the proxy resource
      def latest(env: 'sandbox')
        @log.debug("Latest config: #{env}")
        response = http_client.get("#{base_path}/configs/#{env}/latest")
        resource_instance(response)
      end

    end

    # Proxy resource wrapper for proxy entity received by REST API
    class Proxy < DefaultResource
      attr_accessor :service

      # Construct the proxy resource
      #
      # @param [ThreeScaleApi::HttpClient] client Instance of test client
      # @param [ThreeScaleApi::Resources::DefaultManager] manager Instance of test client
      # @param [Hash] entity Entity Hash from API client of the proxy
      def initialize(client, manager, entity)
        super(client, manager, entity)
        @service = manager.service
      end
    end
  end
end