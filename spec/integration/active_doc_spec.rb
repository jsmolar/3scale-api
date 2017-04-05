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
    @rnd_num = SecureRandom.random_number(1_000_000_000) * 1.0
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @manager = ThreeScaleApi::Resources::ActiveDocManager.new(@http_client)
    @body = '{}'
    @doc = @manager.create({name: @name, body: @body, published: false, skip_swagger_validations: true})
  end

  after(:all) do
    begin
      @doc.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError
    end
  end

  context '#Active doc CRUD' do
    subject(:entity) { @doc.entity }
    it 'create' do
      expect(entity).to include('name' => @name)
      expect(entity).to include('published' => false)
    end

    it 'list' do
      serv_name = @name
      expect(@manager.list.any? { |serv| serv['name'] == serv_name }).to be(true)
    end

    it 'read' do
      expect(@manager.read(@doc['id']).entity).to include('name' => @name)
    end

    it 'delete' do
      s_name = SecureRandom.uuid
      doc = @manager.create({name: s_name, body: @body, skip_swagger_validations: true} )
      expect(doc.entity).to include('name' => s_name)
      doc.delete
      expect(@manager.list.any? { |s| s['name'] == doc['name'] }).to be(false)
    end

    it 'update' do
      @doc['published'] = true
      expect(@doc.update.entity).to include('published' => true)
      expect(@doc.entity).to include('published' => true)
    end
  end

end