# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api'
require_relative '../spec_helper'

RSpec.describe 'Service Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @rnd_num = SecureRandom.random_number(1_000_000_000) * 1.0
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @resource = @manager.create(name: @name, system_name: @name)
  end

  after(:all) do
    begin
      @resource.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#service CRUD' do
    subject(:entity) { @resource.entity }
    it 'create' do
      expect(entity).to include('system_name' => @name)
    end

    it 'list' do
      res_name = @resource['system_name']
      expect(@manager.list.any? { |res| res['system_name'] == res_name }).to be(true)
    end

    it 'read' do
      expect(@manager.read(@resource['id']).entity).to include('system_name' => @name)
    end

    it 'delete' do
      res_name = SecureRandom.uuid
      resource = @manager.create({name: res_name, system_name: res_name})
      expect(resource.entity).to include('system_name' => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r['system_name'] == res_name }).to be(false)
    end

    it 'finds' do
      resource = @manager[@resource['system_name']]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include('system_name' => @name)
    end

    it 'update' do
      @resource['name'] = 'testServiceNameUpdated'
      expect(@resource.update.entity).to include('name' => 'testServiceNameUpdated')
      expect(@resource.entity).to include('name' => 'testServiceNameUpdated')
    end
  end

end