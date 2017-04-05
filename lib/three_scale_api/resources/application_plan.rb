# frozen_string_literal: true

require 'three_scale_api/resources/default'
require 'three_scale_api/resources/application_plan_limit'

module ThreeScaleApi
  module Resources
    # Application plan resource manager wrapper for an application plan entity received by the REST API
    class ApplicationPlanManager < DefaultManager
      attr_accessor :service

      # Creates instance of the application plan resource manager
      #
      # @param [ThreeScaleQE::HttpClient] http_client Instance of http client
      # @param [ThreeScaleQE::Resources::Service] service Service resource
      def initialize(http_client, service = nil)
        super(http_client, entity_name: 'application_plan', collection_name: 'plans')
        @service = service
        @resource_instance = ApplicationPlan
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super.concat("/services/#{@service['id']}/application_plans")
      end

      # Lists all services
      #
      # @return [Array<ServicePlan>] List of ServicePlan
      def list_all
        @log.debug('List all')
        response = @http_client.get('/admin/api/application_plans')
        resource_instance(response)
      end

      # Sets global default plan
      #
      # @param [Fixnum] id Plan ID
      # @return [AccountPlan] Account plan instance
      def set_default(id)
        @log.debug("Set default: #{id}")
        response = @http_client.put("#{base_path}/#{id}/default")
        resource_instance(response)
      end

      # Gets global default plan
      #
      # @return [AccountPlan] Account plan instance
      def get_default
        list.each do |plan|
          return plan if plan['default']
        end
        nil
      end
    end

    # Application plan resource wrapper for an application entity received by the REST API
    class ApplicationPlan < DefaultResource
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

      # Sets this plan as default
      #
      # @return [ServicePlan] Application plan instance
      def set_default
        @manager.set_default(@entity['id']) if @manager.respond_to?(:set_default)
      end

      # Gets instance of the limits manager
      #
      # @return [ApplicationPlanLimitManager] Application plan limit manager
      # @param [Metric] metric Metric resource
      def limits(metric:nil)
        ApplicationPlanLimitManager.new(http_client, self, metric: metric)
      end
    end
  end
end