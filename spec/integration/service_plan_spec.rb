# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Service plan Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @rnd_num = SecureRandom.random_number(1_000_000_000) * 1.0
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @s_manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @s_manager.create(name: @name)
    @manager =  @service.service_plans
    @resource = @manager.create(name: @name, system_name: @name)
  end

  after(:all) do
    begin
      @resource.delete
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#service_plan CRUD' do
    subject(:entity) { @resource.entity }
    it 'create' do
      expect(entity).to include('name' => @name)
    end

    it 'list' do
      res_name = @resource['name']
      expect(@manager.list.any? { |res| res['name'] == res_name }).to be(true)
    end

    it 'list_all' do
      res_name = @resource['name']
      expect(@manager.list_all.any? { |res| res['name'] == res_name }).to be(true)
    end

    it 'read' do
      expect(@manager.read(@resource['id']).entity).to include('name' => @name)
    end

    it 'delete' do
      res_name = SecureRandom.uuid
      resource = @manager.create(name: res_name)
      expect(resource.entity).to include('name' => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r['name'] == res_name }).to be(false)
    end

    it 'finds' do
      resource = @manager[@resource['name']]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include('name' => @name)
    end

    it 'update' do
      res_name = SecureRandom.uuid
      @resource['name'] = res_name
      expect(@resource.update.entity).to include('name' => res_name)
      expect(@resource.entity).to include('name' => res_name)
    end

    it 'set_default and get_default' do
      old_default = @manager.get_default
      if old_default
        expect(@manager[old_default['id']].to_h).to include('default' => true)
      end

      @resource.set_default

      expect(@manager[@resource['id']].to_h).to include('default' => true)
      if old_default
        old_default.set_default
        expect(@manager[old_default['id']].to_h).to include('default' => true)
      end
    end
  end

end