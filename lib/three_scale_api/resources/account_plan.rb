# frozen_string_literal: true

require 'three_scale_api/resources/default'

module ThreeScaleApi
  module Resources
    # Account plan resource manager wrapper for account plan entity received by REST API
    class AccountPlanManager < DefaultManager
      # Creates instance of the Account resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client)
        super(http_client, entity_name: 'account_plan', collection_name: 'plans')
        @resource_instance = AccountPlan
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super.concat '/account_plans'
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

    # Account resource wrapper for account entity received by REST API
    class AccountPlan < DefaultResource
      # Creates instance of the Account resource
      #
      # @param [ThreeScaleQE::TestClient] client Instance of the test client
      # @param [ServicesManager] manager Instance of the service manager by which this resource has been obtained
      # @param [Hash] entity Service Hash from API client
      def initialize(client, manager, entity)
        super(client, manager, entity)
      end

      # Sets plan as default
      def set_default
        @manager.set_default(entity['id']) if @manager.respond_to?(:set_default)
      end
    end
  end
end
