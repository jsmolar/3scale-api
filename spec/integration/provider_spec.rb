# frozen_string_literal: true

require 'securerandom'
require 'three_scale_api/resources/provider'
require 'three_scale_api/http_client'
require_relative '../spec_helper'

RSpec.describe 'Provider Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @name = SecureRandom.uuid
    @rnd_num = SecureRandom.random_number(1_000_000_000) * 1.0
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @manager = ThreeScaleApi::Resources::ProviderManager.new(@http_client)
    @resource = @manager.create(username: @name,
                                email: "#{@name}@example.com",
                                password: @name)
  end

  after(:all) do
    begin
      @resource.delete
    rescue ThreeScaleApi::HttpClient::NotFoundError => ex
      puts ex
    end
  end

  context '#provider CRUD' do
    subject(:entity) { @resource.entity }
    it 'create' do
      expect(entity).to include('username' => @name)
    end

    it 'list' do
      res_name = @resource['username']
      expect(@manager.list.any? { |res| res['username'] == res_name }).to be(true)
    end

    it 'read' do
      expect(@manager.read(@resource['id']).entity).to include('username' => @name)
    end

    it 'delete' do
      res_name = SecureRandom.uuid
      resource = @manager.create(username: res_name,
                                 email: "#{res_name}@example.com",
                                 password: res_name)
      expect(resource.entity).to include('username' => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r['username'] == res_name }).to be(false)
    end

    it 'update' do
      new_name = SecureRandom.uuid
      @resource['username'] = new_name
      expect(@resource.update.entity).to include('username' => new_name)
      expect(@resource.entity).to include('username' => new_name)
    end

    it 'activates' do
      expect(@resource['state']).to eq('pending')
      @resource.activate
      expect(@manager[@resource['id']].entity).to include('state' => 'active')
    end

    it 'admin' do
      expect(@resource['role']).to eq('member')
      @resource.as_admin
      expect(@manager[@resource['id']].entity).to include('role' => 'admin')
    end

  end

end