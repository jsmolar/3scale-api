# frozen_string_literal: true

require 'three_scale_api/tools'
require 'three_scale_api/resources/default'
require 'three_scale_api/resources/proxy'
require 'three_scale_api/resources/metric'
require 'three_scale_api/resources/service_plan'
require 'three_scale_api/resources/mapping_rule'
require 'three_scale_api/resources/application_plan'

module ThreeScaleApi
  module Resources
    # Service resource manager wrapper for the service entity received by the REST API
    class ServiceManager < DefaultManager
      # Creates instance of the Service resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client)
        super(http_client, entity_name: 'service', collection_name: 'services')
        @resource_instance = Service
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super + '/services'
      end
    end

    # Service resource wrapper for the service entity received by REST API
    class Service < DefaultResource
      # Creates instance of the Service resource
      #
      # @param [ThreeScaleQE::TestClient] client Instance of the test client
      # @param [ServicesManager] manager Instance of the service manager by which this resource has been obtained
      # @param [Hash] entity Service Hash from API client
      def initialize(client, manager, entity)
        super(client, manager, entity)
      end

      # Gets the service plans manager that has bind this service resource
      #
      # @return [ServicePlansManager] Instance of the service plans manager
      def service_plans
        manager_instance(ServicePlanManager)
      end

      # Gets the proxy manager that has bind this service resource
      #
      # @return [ProxyManager] Instance of the proxy manager
      def proxy
        manager_instance(ProxyManager)
      end

      # Gets the metrics manager that has bind this service resource
      #
      # @return [MetricsManager] Instance of the metrics manager
      def metrics
        manager_instance(MetricManager)
      end

      # Gets the mapping rules manager that has bind this service resource
      #
      # @return [MappingRulesManager] Instance of the mapping rules manager
      def mapping_rules
        # manager_instance(MappingRuleManager)
      end

      # Gets the application plans manager that has bind this service resource
      #
      # @return [ApplicationPlansManager] Instance of the app. plans manager
      def application_plans
        # manager_instance(ApplicationPlanManager)
      end
    end
  end
end
