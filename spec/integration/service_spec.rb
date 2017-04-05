# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Service Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @rnd_num = SecureRandom.random_number(1_000_000_000) * 1.0
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @manager.create({name: @name, system_name: @name})
  end

  after(:all) do
    begin
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError
    end
  end

  context '#service CRUD' do
    subject(:entity) { @service.entity }
    it 'creates a service' do
      expect(entity).to include('system_name' => @name)
    end

    it 'list' do
      serv_name = @service['system_name']
      expect(@manager.list.any? { |serv| serv['system_name'] == serv_name }).to be(true)
    end

    it 'read' do
      expect(@manager.read(@service['id']).entity).to include('system_name' => @service['system_name'])
    end

    it 'delete' do
      s_name = SecureRandom.uuid
      serv = @manager.create({name: s_name, system_name: s_name})
      expect(serv.entity).to include('system_name' => s_name)
      serv.delete
      expect(@manager.list.any? { |s| s['system_name'] == serv['system_name'] }).to be(false)
    end

    it 'finds' do
      serv = @manager[@service['system_name']]
      expect(serv.entity).to include('id' => serv['id'])
      serv_id = @manager[@service['id']]
      expect(serv_id.entity).to include('system_name' => @name)
    end

    it 'update' do
      @service['name'] = 'testServiceNameUpdated'
      expect(@service.update.entity).to include('name' => 'testServiceNameUpdated')
      expect(@service.entity).to include('name' => 'testServiceNameUpdated')
    end
  end

end