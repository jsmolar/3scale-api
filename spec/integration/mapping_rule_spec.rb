# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Mapping rule Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    uuid = SecureRandom.uuid
    @name = "/#{uuid}"
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @s_manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @s_manager.create(name: uuid, system_name: uuid)
    @metric = @service.metrics.list.first
    @manager = @service.mapping_rules(@metric)
    @resource = @manager.create(http_method: 'DELETE', pattern: @name, delta: 1)
  end

  after(:all) do
    begin
      @resource.delete
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#mapping_rule CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'pattern' }

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
      res_name = "/#{SecureRandom.uuid}"
      resource = @manager.create(http_method: 'PATCH', pattern: res_name, delta: 1)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'update' do
      updated = 100
      @resource['delta'] = updated
      expect(@resource.update.entity).to include('delta' => updated)
      expect(@resource.entity).to include('delta' => updated)
    end
  end
end