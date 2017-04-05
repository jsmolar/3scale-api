# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Application plan limit resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @rnd_num = SecureRandom.random_number(1_000_000_000) * 1.0
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @s_manager = ThreeScaleApi::Resources::ServiceManager.new(@http_client)
    @service = @s_manager.create(name: @name)
    @unit = 'click'
    @metric = @service.metrics.create(friendly_name: @name, unit: @unit)
    @ap_manager = @service.application_plans
    @app_plan = @ap_manager.create(name: @name, system_name: @name)
    @manager = @app_plan.limits(@metric)
    @resource = @manager.create(period: 'minute', value: 10)
  end

  after(:all) do
    begin
      @resource.delete
      @app_plan.delete
      @service.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#application_limit_plan CRUD' do
    subject(:entity) { @resource.entity }
    it 'create' do
      expect(entity).to include('period' => 'minute')
      expect(entity).to include('value' => 10)
    end

    it 'list' do
      expect(@manager.list.length).to be >= 1
    end

    it 'read' do
      expect(@manager.read(@resource['id']).entity).to include('period' => 'minute')
    end

    it 'delete' do
      resource = @manager.create(period: 'hour', value: 100)
      expect(resource.entity).to include('period' => 'hour')
      resource.delete
      expect(@manager.list.any? { |r| r['period'] == 'hour' }).to be(false)
    end

    it 'update' do
      @resource['value'] = 100
      expect(@resource.update.entity).to include('value' => 100)
      expect(@resource.entity).to include('value' => 100)
    end
  end
end