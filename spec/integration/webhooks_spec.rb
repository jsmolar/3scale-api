# frozen_string_literal: true

require 'three_scale_api'
require_relative '../spec_helper'

RSpec.describe 'WebHooks Resource', type: :integration do

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @http_client = ThreeScaleApi::HttpClient.new(endpoint: @endpoint, provider_key: @provider_key)
    @manager = ThreeScaleApi::Resources::WebHookManager.new(@http_client)
  end

  context '#WebHooks read and update' do
    subject(:entity) { @manager.read }

    it 'read' do
      expect(entity).to be_truthy
      expect(entity.entity).to include('account_created_on')
      expect(entity.entity).to include('url')
      expect(entity.entity).to include('active')
    end

    it 'update' do
      url = 'https://httpbin.org'
      orig_url = entity['url']
      entity['url'] = url
      entity.update
      res = @manager.read
      expect(res.entity).to include('url' => url)
      res['url'] = orig_url
      res.update
      expect(@manager.read.entity).to include('url' => orig_url)
    end
  end

end