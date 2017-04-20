# frozen_string_literal: true

require 'three_scale_api'
require 'securerandom'
require_relative './spec_helper'

RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to
  # set it on RSpec 3.
  #
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context 'Shared initialization', shared_context: :metadata do
  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    log_level = ENV.fetch('LOG_LEVEL', 'debug')
    @name = SecureRandom.uuid
    @client = ThreeScaleApi::Client.new(endpoint: @endpoint,
                                        provider_key: @provider_key,
                                        log_level: log_level)
    @resource = nil
    @manager = nil
  end

  ##############################
  ###                        ###
  ### Shared methods section ###
  ###                        ###
  ##############################

  # Creates ad_hoc service
  def create_service(name: nil, **vagrs)
    name ||= @name
    @client.services.create(name: name, system_name: name, **vagrs)
  end

  # Creates account with fix of default acc. plan
  def create_account(name: nil, **vargs)
    name ||= @name
    fix_default_acc_plan
    @client.accounts.sign_up(org_name: name, username: name, **vargs)
  end

  # Creates provider
  def create_provider(name: nil, **vagrs)
    name ||= @name
    email = "#{name}@example.com"
    @client.providers.create(username: name, email: email, password: name)
  end

  def create_active_doc(name: nil, **vargs)
    name ||= @name
    @resource = @manager.create(name: name, body: '{}', published: false, skip_swagger_validations: true)
  end

  # Cleans resource
  def clean_resource(resource)
    resource&.delete # if resource exists, delete it
  rescue ThreeScaleApi::HttpClient::NotFoundError => ex
    @client.http_client.log.warning("Cannot delete #{resource}: #{ex}")
  end

  # Fixes default account plan
  def fix_default_acc_plan
    acc_plan_manager = @client.account_plans
    acc_plan_def = acc_plan_manager['Default']

    unless acc_plan_def
      plan = acc_plan_manager.create(name: 'Default')
      plan.set_default
    end
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'Shared initialization', include_shared: true
end


