# frozen_string_literal: true

require 'three_scale_api/resources/default'

module ThreeScaleApi
  module Resources
    # Service plan resource manager wrapper for the service plan entity received by the REST API
    class ServicePlanManager < DefaultManager
      attr_accessor :service

      # Creates instance of the Proxy resource manager
      #
      # @param [ThreeScaleQE::HttpClient] http_client Instance of http client
      def initialize(http_client, service = nil)
        super(http_client, entity_name: 'service_plan', collection_name: 'plans')
        @service = service
        @resource_instance = ServicePlan
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super + ("/services/#{@service['id']}/service_plans")
      end

      # Lists all services
      #
      # @return [Array<ServicePlan>] List of ServicePlan
      def list_all
        @log.debug('List all')
        response = @http_client.get('/admin/api/service_plans')
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

    # Service plan resource wrapper for proxy entity received by REST API
    class ServicePlan < DefaultResource
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
      # @return [ServicePlan] Service plan instance
      def set_default
        @manager.set_default(@entity['id']) if @manager.respond_to?(:set_default)
      end
    end
  end
end