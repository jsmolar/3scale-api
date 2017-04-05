# frozen_string_literal: true

require 'three_scale_api/resources/default'

module ThreeScaleApi
  module Resources
    # WebHook resource manager wrapper for the WebHook entity received by the REST API
    class WebHookManager < DefaultManager
      attr_accessor :service

      # Creates instance of the WebHook resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client, service)
        super(http_client, entity_name: 'webhook', collection_name: 'webhooks')
        @resource_instance = WebHook
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super.concat('/webhooks')
      end

      # @api public
      # Updates Webhooks
      #
      # @param [Hash] attributes Attributes that will be updated
      # @option attributes [String] url URL that will be notified about all the events
      # @option attributes [Boolean] active Activate/Disable WebHooks
      # @option attributes [Boolean] provider_actions Dashboard actions fire web hooks. If false, only user actions in the portal trigger events.
      # @option attributes [Boolean] account_created_on
      # @option attributes [Boolean] account_updated_on
      # @option attributes [Boolean] account_deleted_on
      # @option attributes [Boolean] user_created_on
      # @option attributes [Boolean] user_updated_on
      # @option attributes [Boolean] user_deleted_on
      # @option attributes [Boolean] application_created_on
      # @option attributes [Boolean] application_updated_on
      # @option attributes [Boolean] application_deleted_on
      # @option attributes [Boolean] account_plan_changed_on
      # @option attributes [Boolean] application_plan_changed_on
      # @option attributes [Boolean] application_user_key_updated_on
      # @option attributes [Boolean] application_key_created_on
      # @option attributes [Boolean] application_key_deleted_on
      # @option attributes [Boolean] application_suspended_on
      # @option attributes [Boolean] application_key_updated_on
      # @return [Hash] Webhook
      def update(attributes)
        super(attributes)
      end

    end

    # WebHook resource wrapper for the WebHook entity received by the REST API
    class WebHook < DefaultResource
      attr_accessor :service

      # Construct the WebHook resource
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