# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/service'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Service Resource', type: :integration do
  let(:endpoint) { ENV.fetch('ENDPOINT') }
  let(:provider_key) { ENV.fetch('PROVIDER_KEY') }
  let(:name) { SecureRandom.uuid }
  let(:rnd_num) { SecureRandom.random_number(1_000_000_000) * 1.0 }
  let(:http_client) { ThreeScaleApi::HttpClient.new(endpoint: endpoint, provider_key: provider_key) }
  let(:manager) { ThreeScaleApi::Resources::ServiceManager.new(http_client) }
  let(:service) { manager.create({name: name, system_name: name}) }

  after(:each) do
    begin
      manager.delete(service['id'])
    rescue ThreeScaleApi::HttpClient::NotFoundError
    end
  end

  context '#service CRUD' do
    subject(:entity) { service.entity }
    it 'creates a service' do
      expect(entity).to include('name' => name)
    end

    it 'list an services' do
      serv_name = service['name']
      expect(manager.list.any? { |serv| serv['name'] == serv_name }).to be(true)
    end

    it 'read a service' do
      expect(manager.read(service['id']).entity).to include('name' => service['name'])
    end

    it 'delete service' do
      manager.delete(service['id'])
      expect(manager.list.any? { |serv| serv['name'] == service['name'] }).to be(false)
    end

    it 'finds service' do
      serv = manager[service['name']]
      expect(serv.entity).to include('id' => serv['id'])
      serv_id = manager[service['id']]
      expect(serv_id.entity).to include('name' => name)
    end

    it 'update service' do
      service['name'] = 'testServiceNameUpdated'
      expect(service.update.entity).to include('name' => 'testServiceNameUpdated')
      expect(service.entity).to include('name' => 'testServiceNameUpdated')
    end
  end

end