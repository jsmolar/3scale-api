# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'


RSpec.describe 'Proxy API', type: :integration do
  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @s_manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @s_manager.create(name: @name, system_name: @name)
    @manager = @service.proxy
    @proxy = @manager.read
    @entity = @proxy.entity
    @url = "http://#{@name}.com:7777"
  end

  after(:all) do
    begin
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#proxy CRUD' do

    it 'has valid references' do
      expect(@proxy.service).to eq(@service)
      expect(@proxy.manager).to eq(@manager)
    end

    it 'read' do
      expect(@entity).to include('service_id' => @service['id'])
    end

    it 'update' do
      @proxy['endpoint'] = @url
      expect(@proxy.update.entity).to include('endpoint' => @url)
      expect(@proxy.entity).to include('endpoint' => @url)
    end
  end
end