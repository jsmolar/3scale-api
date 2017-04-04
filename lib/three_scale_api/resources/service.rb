require 'three_scale_api/tools'
require 'three_scale_api/resources/default'
require 'three_scale_api/resources/proxy'
require 'three_scale_api/resources/metric'
require 'three_scale_api/resources/service_plan'
require 'three_scale_api/resources/mapping_rule'
require 'three_scale_api/resources/application_plan'

module ThreeScaleApi
  module Resources
    # Default resource manager wrapper for default entity received by REST API
    # All other managers inherits from Default manager
    class ServiceManager < DefaultManager

      # Creates instance of the Service resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client)
        super(http_client, entity_name: 'service', collection_name: 'services')
        @resource_instance = Service
      end

      def base_path
        super.concat('/services')
      end
    end

    # Default resource wrapper for any entity received by REST API
    # All other resources inherits from Default resource
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
