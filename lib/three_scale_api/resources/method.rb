# frozen_string_literal: true

require 'three_scale_api/resources/default'
require 'three_scale_api/resources/application_plan_limit'
require 'three_scale_api/resources/method'

module ThreeScaleApi
  module Resources
    # Method resource manager wrapper for the method entity received by REST API
    class MethodManager < DefaultManager
      attr_accessor :service, :metric

      # Creates instance of the Method resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      # @param [Metric] metric Instance of the metric resource
      def initialize(http_client, metric)
        super(http_client, entity_name: 'method', collection_name: 'methods')
        @service = metric.service
        @metric = metric
        @resource_instance = Method
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super.concat "/services/#{@service['id']}/metrics/#{@metric['id']}/methods"
      end
    end

    # Method resource wrapper for the metric entity received by the REST API
    class Method < DefaultResource
      attr_accessor :service, :metric

      # Construct the metric resource
      #
      # @param [ThreeScaleApi::HttpClient] client Instance of http client
      # @param [ThreeScaleApi::Resources::MetricManager] manager Metrics manager
      # @param [Hash] entity Entity Hash from API client of the metric
      def initialize(client, manager, entity)
        super(client, manager, entity)
        @service = manager.service
        @metric = manager.metric
      end

      # Gets application plan limits
      #
      # @return [ApplicationPlanLimitManager] Instance of the Application plan limits manager
      def application_plan_limits(app_plan)
        ApplicationPlanLimitManager.new(@http_client, app_plan, metric: self)
      end
    end
  end
end