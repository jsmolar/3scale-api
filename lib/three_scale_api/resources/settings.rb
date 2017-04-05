# frozen_string_literal: true

require 'three_scale_api/tools'
require 'three_scale_api/resources/default'

module ThreeScaleApi
  module Resources
    # Service resource manager wrapper for the service entity received by the REST API
    class SettingsManager < DefaultManager
      # Creates instance of the Service resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client)
        super(http_client, entity_name: 'settings', collection_name: 'settings')
        @resource_instance = Settings
      end

      # Reads settings
      #
      # @return [Settings] Instance of the settings resource
      def read
        @log.debug("Read #{resource_name}")
        response = http_client.get(base_path)
        resource_instance(response)
      end

      # Updates settings
      #
      # @param [Hash] attributes Settings attributes
      # @option attributes [Boolean] useraccountarea_enabled Allow the user to edit their submitted details, change passwords, etc
      # @option attributes [Boolean] hide_service Used a default service plan
      # @option attributes [Boolean] signups_enabled Developers are allowed sign up themselves.
      # @option attributes [Boolean] account_approval_required Approval is required by you before developer accounts are activated.
      # @option attributes [Boolean] strong_passwords_enabled Require strong passwords from your users:
      # @option attributes [Boolean] public_search Enables public search on Developer Portal
      # @option attributes [Boolean] account_plans_ui_visible Enables visibility of Account Plans
      # @option attributes [Boolean] change_account_plan_permission Account Plans changing
      # @option attributes [Boolean] service_plans_ui_visible Enables visibility of Service Plans
      # @option attributes [Boolean] change_service_plan_permission Service Plans changing
      # @option attributes [Boolean] end_user_plans_ui_visible Enables visibility of End User Plans
      def update(attributes)
        @log.debug("Update #{resource_name}: #{attributes}")
        response = http_client.patch(base_path, body: attributes)
        resource_instance(response)
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super + '/settings'
      end
    end

    # Service resource wrapper for the service entity received by REST API
    class Settings < DefaultResource
      # Creates instance of the Service resource
      #
      # @param [ThreeScaleQE::TestClient] client Instance of the test client
      # @param [ServicesManager] manager Instance of the service manager by which this resource has been obtained
      # @param [Hash] entity Service Hash from API client
      def initialize(client, manager, entity)
        super(client, manager, entity)
      end
    end
  end
end
