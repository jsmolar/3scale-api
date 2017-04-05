# frozen_string_literal: true

require 'three_scale_api/tools'
require 'three_scale_api/resources/default'

module ThreeScaleApi
  module Resources
    # Provider resource manager wrapper for the provider entity received by the REST API
    class ProviderManager < DefaultManager
      # Creates instance of the Provider resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client)
        super(http_client, entity_name: 'user', collection_name: 'users')
        @resource_instance = Provider
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super + '/users'
      end

      # Change state
      #
      # @param [Fixnum] id Provider user id
      # @param [String] state State ('member' | 'admin' | 'suspend' | 'unsuspend' | 'activate')
      def set_state(id, state = 'member')
        response = http_client.put("#{base_path}/#{id}/#{state}")
        resource_instance(response)
      end

      # Suspends the provider
      #
      # @param [Fixnum] id Provider ID
      def suspend(id)
        set_state(id, state: 'suspend')
      end

      # Resumes the provider
      #
      # @param [Fixnum] id Provider ID
      def resume(id)
        set_state(id, state: 'unsuspend')
      end

      # Resumes the provider
      #
      # @param [Fixnum] id Provider ID
      def activate(id)
        set_state(id, state: 'activate')
      end

      # Sets role as admin
      #
      # @param [Fixnum] id Provider ID
      def set_as_admin(id)
        set_state(id, state: 'admin')
      end

      # Sets role as member
      #
      # @param [Fixnum] id Provider ID
      def set_as_member(id)
        set_state(id, state: 'admin')
      end
    end

    # Provider resource wrapper for the provider entity received by REST API
    class Provider < DefaultResource
      # Creates instance of the Provider resource
      #
      # @param [ThreeScaleQE::TestClient] client Instance of the test client
      # @param [ProvidersManager] manager Instance of the provider manager by which this resource has been obtained
      # @param [Hash] entity Provider Hash from API client
      def initialize(client, manager, entity)
        super(client, manager, entity)
      end

      # Activate provider account
      def activate
        set_state('activate')
      end

      # Suspend provider account
      def suspend
        set_state('suspend')
      end

      # Resume provider account
      def resume
        set_state('unsuspend')
      end

      # Set provider as admin
      def as_admin
        set_state('admin')
      end

      # Set provider as member
      def as_member
        set_state('member')
      end

      # Activate provider account
      #
      # @param [String] state State ('member' | 'admin' | 'suspend' | 'unsuspend' | 'activate')
      def set_state(state)
        @manager.set_state(@entity['id'], state) if @manager.respond_to?(:set_state)
      end
    end
  end
end
