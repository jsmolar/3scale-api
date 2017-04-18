# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'WebHooks Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @manager = @client.webhooks
  end

  context '#WebHooks read and update' do
    subject(:entity) { @manager.read }

    it 'should read webhooks' do
      expect(entity).to be_truthy
      expect(entity.entity).to include('account_created_on')
      expect(entity.entity).to include('url')
      expect(entity.entity).to include('active')
    end

    it 'should update webhooks url' do
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