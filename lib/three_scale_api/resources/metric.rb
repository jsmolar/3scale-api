# frozen_string_literal: true

require 'three_scale_api/resources/default'
require 'three_scale_api/resources/application_plan_limit'
require 'three_scale_api/resources/method'

module ThreeScaleApi
  module Resources
    # Metric resource manager wrapper for the metric entity received by REST API
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

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super.concat "/services/#{@service['id']}/metrics"
      end
    end

    # Metric resource wrapper for the metric entity received by the REST API
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

      # Gets application plan limits
      #
      # @return [ApplicationPlanLimitManager] Instance of the Application plan limits manager
      def application_plan_limits(app_plan)
        ApplicationPlanLimitManager.new(@http_client, app_plan, metric: self)
      end

      # Gets methods manager
      #
      # @return [MethodsManager] Instance of the Methods manager
      def methods
        manager_instance(MethodManager)
      end
    end
  end
end