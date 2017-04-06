# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Metric Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @s_manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @s_manager.create(name: @name, system_name: @name)
    @manager = @service.metrics
    @unit = 'click'
    @resource = @manager.create(friendly_name: @name, unit: @unit)
  end

  after(:all) do
    begin
      @resource.delete
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#metric' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'friendly_name' }

    it 'has valid references' do
      expect(@resource.service).to eq(@service)
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
      resource = @manager.create(unit: @unit, friendly_name: res_name)
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
      unit_name = @unit + 'Updated'
      @resource['unit'] = unit_name
      expect(@resource.update.entity).to include('unit' => unit_name)
      expect(@resource.entity).to include('unit' => unit_name)
    end
  end

end