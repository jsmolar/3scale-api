# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Method Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @s_manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @s_manager.create(name: @name, system_name: @name)
    @metric = @service.metrics.list.first
    @manager = @metric.methods
    @resource = @manager.create(friendly_name: @name)
  end

  after(:all) do
    begin
      @resource.delete
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#method' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'friendly_name' }

    it 'has valid references' do
      expect(@resource.service).to eq(@service)
      expect(@resource.metric).to eq(@metric)
      expect(@resource.manager).to eq(@manager)
    end

    it 'create' do
      expect(entity).to include(base_attr => @name)
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
      resource = @manager.create(friendly_name: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'find' do
      resource = @manager[@resource['system_name']]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'update' do
      unit_name = @name + 'Updated'
      @resource['system_name'] = unit_name
      expect(@resource.update.entity).to include('system_name' => unit_name)
      expect(@resource.entity).to include('system_name' => unit_name)
    end
  end

end