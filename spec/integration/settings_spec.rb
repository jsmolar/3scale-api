# frozen_string_literal: true

require 'three_scale_api'
require_relative '../spec_helper'

RSpec.describe 'Settings Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @manager = ThreeScaleApi::Resources::SettingsManager.new(@http_client)
  end

  context '#settings read and update' do
    subject(:entity) { @manager.read }

    it 'read' do
      expect(entity).to be_truthy
      expect(entity.entity).to include('signups_enabled')
      expect(entity.entity).to include('strong_passwords_enabled')
    end

    it 'update' do
      entity['strong_passwords_enabled'] = true
      entity.update
      res = @manager.read
      expect(res.entity).to include('strong_passwords_enabled' => true)
      res['strong_passwords_enabled'] = false
      res.update
      expect(@manager.read.entity).to include('strong_passwords_enabled' => false)
    end
  end

end