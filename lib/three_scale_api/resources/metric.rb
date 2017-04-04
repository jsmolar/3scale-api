require 'three_scale_api/resources/default'
module ThreeScaleApi
  module Resources
    # Metric resource manager wrapper for metric entity received by REST API
    class MetricManager < DefaultManager
      attr_accessor :service

      # Creates instance of the Proxy resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client, service)
        super(http_client, entity_name: 'metric', collection_name: 'metrics')
        @service = service
        @resource_instance = Metric
      end

      def base_path
        super.concat("/services/#{@service['id']}/metrics")
      end
    end

    # Metric resource wrapper for metric entity received by REST API
    class Metric < DefaultResource
      attr_accessor :service

      # Construct the metric resource
      #
      # @param [ThreeScaleApi::HttpClient] client Instance of http client
      # @param [ThreeScaleApi::Resources::MetricManager] manager Metrics manager
      # @param [Hash] entity Entity Hash from API client of the metric
      def initialize(client, manager, entity)
        super(client, manager, entity)
        @service = manager.service
      end
    end
  end
end