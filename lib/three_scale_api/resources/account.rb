# frozen_string_literal: true

require 'three_scale_api/resources/default'
require 'three_scale_api/resources/account_user'
require 'three_scale_api/resources/application'

module ThreeScaleApi
  module Resources
    # Default resource manager wrapper for default entity received by REST API
    class AccountManager < DefaultManager
      # Creates instance of the Service resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client)
        super(http_client, entity_name: 'account', collection_name: 'accounts')
        @resource_instance = Account
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super.concat '/accounts'
      end

      # Creates developer account (Same way as used in Developer portal)
      # Will also create default user with username
      #
      # @param [Hash] attributes Attributes
      # @option attributes [String] :email User Email
      # @option attributes [String] :org_name Account name
      # @option attributes [String] :username User name
      # @option attributes [String] :password User Password
      # @option attributes [String] :account_plan_id Account Plan ID
      # @option attributes [String] :service_plan_id Service Plan ID
      # @option attributes [String] :application_plan_id Application Plan ID
      def sign_up(attributes)
        @log.debug("Sign UP: #{attributes}")
        response = http_client.post('/admin/api/signup', body: attributes)
        resource_instance(response)
      end

      # Creates developer
      def create(attributes)
        sign_up(attributes)
      end

      # Sets account to spec. state
      #
      # @param [Fixnum] id Account ID
      # @param [String] state 'approve' or 'reject' or 'make_pending'
      def set_state(id, state = 'approve')
        @log.debug "Set state [#{id}]: #{state}"
        response = http_client.put("#{base_path}/#{id}/#{state}")
        resource_instance(response)
      end

      # Sets default plan for dev. account
      #
      # @param [Fixnum] id Account ID
      # @param [Fixnum] plan_id Plan id
      def set_plan(id, plan_id)
        @log.debug("Set #{resource_name}  default (id: #{id}) ")
        body = { plan_id: plan_id }
        response = http_client.put("#{base_path}/#{id}/change_plan", body: body)
        resource_instance(response)
      end

      # Approves account
      #
      # @param [Fixnum] id Account ID
      def approve(id)
        set_state(id, 'approve')
      end

      # Rejects account
      #
      # @param [Fixnum] id Account ID
      def reject(id)
        set_state(id, 'reject')
      end

      # Set pending
      #
      # @param [Fixnum] id Account ID
      def pending(id)
        set_state(id, 'make_pending')
      end
    end

    # Default resource wrapper for any entity received by REST API
    class Account < DefaultResource
      # Creates instance of the Service resource
      #
      # @param [ThreeScaleQE::TestClient] client Instance of the test client
      # @param [ServicesManager] manager Instance of the service manager by which this resource has been obtained
      # @param [Hash] entity Service Hash from API client
      def initialize(client, manager, entity)
        super(client, manager, entity)
      end

      # Sets plan for account
      #
      # @param [Fixnum] plan_id Plan ID
      def set_plan(plan_id)
        @manager.set_plan(@entity['id'], plan_id) if @manager.respond_to?(:set_plan)
      end

      # Sets state of the account
      #
      # @param [String] state 'approve' or 'reject' or 'make_pending'
      def set_state(state)
        @manager.set_state(@entity['id'], state) if @manager.respond_to?(:set_state)
      end

      # Approves account
      def approve
        set_state('approve')
      end

      # Reject account
      def reject
        set_state('reject')
      end

      # Set pending for account
      def pending
        set_state('pending')
      end

      # Gets Account Users Manager
      #
      # @return [AccountUsersManager] Account Users Manager
      def users
        manager_instance(AccountUserManager)
      end

      # Gets  Application Manager
      #
      # @return [ApplicationManager] Account Users Manager
      def applications
        manager_instance(ApplicationManager)
      end
    end
  end
end
