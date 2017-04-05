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
    @rnd_num = SecureRandom.random_number(1_000_000_000) * 1.0
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @serv_manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @serv_manager.create({name: @name, system_name: @name})
    @unit = 'click'
    @manager = @service.metrics
    @metric = @manager.create({friendly_name: @name, unit: @unit})
  end

  after(:all) do
    begin
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError
    end
  end

  context '#metric CRUD' do
    subject(:entity) { @metric.entity }
    it 'create' do
      expect(entity).to include('friendly_name' => @name)
    end

    it 'list' do
      name = @metric['friendly_name']
      expect(@manager.list.any? { |met| met['friendly_name'] == name }).to be(true)
    end

    it 'read' do
      expect(@manager.read(@metric['id']).entity).to include('friendly_name' => @name)
    end

    it 'delete' do
      s_name = SecureRandom.uuid
      metric = @manager.create({friendly_name: s_name, unit: @unit})
      expect(metric.entity).to include('friendly_name' => s_name)
      metric.delete
      expect(@manager.list.any? { |s| s['friendly_name'] == metric['friendly_name'] }).to be(false)
    end

    it 'update' do
      @metric['unit'] = 'testUnit'
      expect(@metric.update.entity).to include('unit' => 'testUnit')
      expect(@metric.entity).to include('unit' => 'testUnit')
    end
  end

end