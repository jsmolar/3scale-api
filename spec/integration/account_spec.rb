# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/account'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Account Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @rnd_num = SecureRandom.random_number(1_000_000_000) * 1.0
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @acc_plan_mgr = ThreeScaleApi::Resources::AccountPlanManager.new(@http_client)
    @acc_plan_def = @acc_plan_mgr['Default']
    unless @acc_plan_def
      plan = @acc_plan_mgr.create(name: 'Default')
      plan.set_default
    end
    @manager = ThreeScaleApi::Resources::AccountManager.new(@http_client)
    @resource = @manager.sign_up(org_name: @name, username: @name)
  end

  after(:all) do
    begin
      @resource.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#account_plan CRUD' do
    subject(:entity) { @resource.entity }

    it 'create' do
      expect(entity).to include('org_name' => @name)
    end


    it 'list' do
      res_name = @resource['org_name']
      expect(@manager.list.any? { |res| res['org_name'] == res_name }).to be(true)
    end

    it 'read' do
      expect(@manager.read(@resource['id']).entity).to include('org_name' => @name)
    end

    it 'delete' do
      res_name = SecureRandom.uuid
      resource = @manager.sign_up(org_name: res_name, username: res_name)
      expect(resource.entity).to include('org_name' => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r['org_name'] == res_name }).to be(false)
    end

    it 'finds' do
      resource = @manager[@resource['org_name']]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include('org_name' => @name)
    end

    it 'update' do
      expect(@resource.entity).to include('state' => 'created')
      @resource['state'] = 'approved'
      expect(@resource.update.entity).to include('state' => 'approved')
      expect(@resource.entity).to include('state' => 'approved')
    end

  end

end