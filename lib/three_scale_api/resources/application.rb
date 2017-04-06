# frozen_string_literal: true

require 'three_scale_api/resources/default'
require 'three_scale_api/resources/application_key'

module ThreeScaleApi
  module Resources
    # Application resource manager wrapper for an application entity received by the REST API
    class ApplicationManager < DefaultManager
      attr_accessor :account
      # Creates instance of the Service resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      # @param [Account] account Account entity
      def initialize(http_client, account)
        super(http_client, entity_name: 'application', collection_name: 'applications')
        @resource_instance = Application
        @account = account
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super  + "/accounts/#{account['id']}/applications"
      end

      # Lists all applications for each service
      #
      # @param [Fixnum] service_id Service ID
      # @return [Application] Application resource
      def list_all(service_id: nil)
        params = service_id ? {service_id: service_id} : nil
        response = http_client.get('/admin/api/applications', params: params)
        resource_list(response)
      end

      # Creates an application
      #
      # @param [Hash] attributes Attributes for the application
      # @option attributes [String] :name Application Name
      # @option attributes [String] :description Application Description
      # @option attributes [String] :user_key Application User Key
      # @option attributes [String] :application_id Application App ID
      # @option attributes [String] :application_key Application App Key(s)
      # @option attributes [String] :redirect_url OAuth endpoint
      # @option attributes [Fixnum] :plan_id Application Plan ID
      # @return [Application] Instance of the application
      def create(attributes)
       super(attributes)
      end

      # Finds the application by specified attributes
      #
      # @param [Fixnum] id Id of the application
      # @param [String] user_key User key for the application (if exists)
      # @param [String] application_id Application id for the application (if exists)
      # @param [Fixnum] service_id Service limiter, which applications for spec. service should be found
      # @return [Application] Application instance
      def find(id: nil, user_key:nil, application_id: nil, service_id:nil)
        params = { service_id: service_id, application_id: id, user_key: user_key, app_id: application_id}.reject { |_, value| value.nil? }
        response = http_client.get('/admin/api/applications/find', params: params)
        resource_instance(response)
      end

      # Sets state of the application
      #
      # @param [Fixnum] id Application ID
      # @param [String] state Application state: 'accept' or 'suspend' or 'resume'
      def set_state(id, state = 'accept')
        response = http_client.put("#{base_path}/#{id}/#{state}")
        resource_instance(response)
      end

      # Accepts the application
      #
      # @param [Fixnum] id Application ID
      def accept(id)
        set_state(id, state: 'accept')
      end

      # Suspends the application
      #
      # @param [Fixnum] id Application ID
      def suspend(id)
        set_state(id, state: 'suspend')
      end

      # Resumes the application
      #
      # @param [Fixnum] id Application ID
      def resume(id)
        set_state(id, state: 'resume')
      end
    end

    # Application resource wrapper for an application received by the REST API
    class Application < DefaultResource
      attr_accessor :account
      # Creates instance of the Service resource
      #
      # @param [ThreeScaleQE::TestClient] client Instance of the test client
      # @param [ApplicationManager] manager Instance of the service manager by which this resource has been obtained
      # @param [Hash] entity Service Hash from API client
      def initialize(client, manager, entity)
        super(client, manager, entity)
        @account = manager.account
      end

      # Applications keys manager instance
      #
      # @return [ApplicationKeysManager] Application keys manager instance
      def keys
        manager_instance(ApplicationKeyManager)
      end

      # Sets state of the application
      #
      # @param [String] state Application state: 'accept' or 'suspend' or 'resume'
      def set_state(state)
        @manager.set_state(@entity['id'], state) if @manager.respond_to?(:set_state)
      end

      # Accept application
      def accept
        set_state('accept')
      end

      # Suspend application
      def suspend
        set_state('suspend')
      end

      # Resume application
      def resume
        set_state('resume')
      end
    end
  end
end
