# frozen_string_literal: true
require 'three_scale_api'

RSpec.describe 'ThreeScaleApi Client' do
  let(:endpoint) { 'https://test.3scale.com' }
  let(:provider_key) { 'somerandomkey' }
  subject(:client) { ThreeScaleApi::Client.new(endpoint: endpoint, provider_key: provider_key) }

  it 'service manager instance' do
    expect(client.services).to be_a_kind_of(ThreeScaleApi::Resources::ServiceManager)
  end

  it 'accounts manager instance' do
    expect(client.accounts).to be_a_kind_of(ThreeScaleApi::Resources::AccountManager)
  end

  it 'account plans manager instance' do
    expect(client.account_plans).to be_a_kind_of(ThreeScaleApi::Resources::AccountPlanManager)
  end

  it 'active doc manager instance' do
    expect(client.active_docs).to be_a_kind_of(ThreeScaleApi::Resources::ActiveDocManager)
  end

  it 'webhooks manager instance' do
    expect(client.webhooks).to be_a_kind_of(ThreeScaleApi::Resources::WebHookManager)
  end

  it 'providers manager instance' do
    expect(client.providers).to be_a_kind_of(ThreeScaleApi::Resources::ProviderManager)
  end

  it 'settings manager instance' do
    expect(client.settings).to be_a_kind_of(ThreeScaleApi::Resources::SettingsManager)
  end
end