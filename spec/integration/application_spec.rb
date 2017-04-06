# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/account'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Application Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @acc_name = SecureRandom.uuid
    @name = SecureRandom.uuid
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @acc_plan_mgr = ThreeScaleApi::Resources::AccountPlanManager.new(@http_client)
    @service_mgr = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @service_mgr.create(name: @name, system_name: @name)
    @app_plan = @service.application_plans.create(name: @name)
    @acc_plan_def = @acc_plan_mgr['Default']

    unless @acc_plan_def
      plan = @acc_plan_mgr.create(name: 'Default')
      plan.set_default
    end

    @acc_manager = ThreeScaleApi::Resources::AccountManager.new(@http_client)
    @acc_resource = @acc_manager.sign_up(org_name: @acc_name, username: @acc_name)
    @manager = @acc_resource.applications
    @resource = @manager.create(name: @name, description: @name, plan_id: @app_plan['id'])
    @keys_manager = @resource.keys
    @key = @keys_manager.create(key: @name)
  end

  after(:all) do
    begin
      @resource.delete
      @acc_resource.delete
      @app_plan.delete
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#application CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'name' }
    it 'create' do
      expect(entity).to include(base_attr => @name)
      expect(entity).to include('description' => @name)
      expect(entity).to include('plan_id' => @app_plan['id'])
    end

    it 'list' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'read' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'delete' do
      res_name = SecureRandom.uuid
      resource = @manager.create(name: res_name, description: res_name, plan_id: @app_plan['id'])
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'update' do
      new_name = SecureRandom.uuid
      @resource['description'] = new_name
      expect(@resource.update.entity).to include('description' => new_name)
      expect(@resource.entity).to include('description' => new_name)
    end

    it 'activates' do
      @resource.suspend
      expect(@manager[@resource['id']].entity).to include('state' => 'suspended')
      @resource.resume
      expect(@manager[@resource['id']].entity).to include('state' => 'live')
    end

    context 'keys' do
      it 'create' do
        expect(@keys_manager.list.any? { |res| res['value'] == @name }).to be(true)
      end

      it 'list' do
        expect(@keys_manager.list.any? { |res| res['value'] == @name }).to be(true)
      end

      it 'delete' do
        res_name = SecureRandom.uuid
        resource = @keys_manager.create(key: res_name)
        expect(resource['value']).to eq(res_name)
        expect(@keys_manager.list.any? { |res| res['value'] == res_name }).to be(true)
        resource.delete
        expect(@manager.list.any? { |r| r['value'] == res_name }).to be(false)
      end

    end

  end
end