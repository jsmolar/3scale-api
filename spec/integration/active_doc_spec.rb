# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/active_doc'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Active Doc Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @manager = ThreeScaleApi::Resources::ActiveDocManager.new(@http_client)
    @body = '{}'
    @resource = @manager.create(name: @name, body: @body, published: false, skip_swagger_validations: true)
  end

  after(:all) do
    begin
      @resource.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#Active doc CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'name' }
    it 'create' do
      expect(entity).to include(base_attr => @name)
      expect(entity).to include('published' => false)
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
      res = @manager.create(name: res_name, body: @body, skip_swagger_validations: true )
      expect(res.entity).to include(base_attr => res_name)
      res.delete
      expect(@manager.list.any? { |s| s[base_attr] == res[base_attr] }).to be(false)
    end

    it 'finds' do
      resource = @manager[@resource[base_attr]]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'update' do
      @resource['published'] = true
      expect(@resource.update.entity).to include('published' => true)
      expect(@resource.entity).to include('published' => true)
    end
  end
end