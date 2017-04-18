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
        super.concat "/accounts/#{@account['id']}/users"
      end

      # Change state
      #
      # @param [Fixnum] id Account user id
      # @param [String] state State ('member' | 'admin' | 'suspend' | 'unsuspend' | 'activate')
      def set_state(id, state = 'member')
        response = http_client.put("#{base_path}/#{id}/#{state}")
        resource_instance(response)
      end

      # Suspends the Account user
      #
      # @param [Fixnum] id Account user ID
      def suspend(id)
        set_state(id, state: 'suspend')
      end

      # Resumes the Account user
      #
      # @param [Fixnum] id Account user ID
      def resume(id)
        set_state(id, state: 'unsuspend')
      end

      # Resumes the Account user
      #
      # @param [Fixnum] id Account user ID
      def activate(id)
        set_state(id, state: 'activate')
      end

      # Sets role as admin
      #
      # @param [Fixnum] id Account user ID
      def set_as_admin(id)
        set_state(id, state: 'admin')
      end

      # Sets role as member
      #
      # @param [Fixnum] id Account user ID
      def set_as_member(id)
        set_state(id, state: 'admin')
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

      # Activate the account user
      def activate
        set_state('activate')
      end

      # Suspend the account user
      def suspend
        set_state('suspend')
      end

      # Resume the account user
      def resume
        set_state('unsuspend')
      end

      # Set the account user as admin
      def as_admin
        set_state('admin')
      end

      # Set the the account user as member
      def as_member
        set_state('member')
      end

      # Activate the account user
      #
      # @param [String] state State ('member' | 'admin' | 'suspend' | 'unsuspend' | 'activate')
      def set_state(state)
        @manager.set_state(@entity['id'], state) if @manager.respond_to?(:set_state)
      end
    end
  end
end
