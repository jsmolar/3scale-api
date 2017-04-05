# frozen_string_literal: true

require 'three_scale_api/resources/default'

module ThreeScaleApi
  module Resources
    # Account user resource manager wrapper for account user entity received by REST API
    class AccountUserManager < DefaultManager
      attr_accessor :account
      # Creates instance of the Service resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      # @param [Account] account Account entity
      def initialize(http_client, account)
        super(http_client, entity_name: 'user', collection_name: 'users')
        @resource_instance = AccountUser
        @account = account
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super + "/accounts/#{@account['id']}/users"
      end
    end

    # Account user resource wrapper for account user received by REST API
    class AccountUser < DefaultResource
      attr_accessor :account
      # Creates instance of the Service resource
      #
      # @param [ThreeScaleQE::TestClient] client Instance of the test client
      # @param [AccountUserManager] manager Instance of the service manager by which this resource has been obtained
      # @param [Hash] entity Service Hash from API client
      def initialize(client, manager, entity)
        super(client, manager, entity)
        @account = manager.account
      end
    end
  end
end
