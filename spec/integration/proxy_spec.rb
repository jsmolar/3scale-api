# frozen_string_literal: true

require_relative '../shared_tests_config'

RSpec.describe 'Proxy API', type: :integration do
  include_context 'Shared initialization'

  before(:all) do
    @service = create_service
    @manager = @service.proxy
    @proxy = @manager.read
    @url = "http://#{@name}.com:7777"
  end

  after(:all) do
    clean_resource(@service)
  end

  context '#proxy CRUD' do

    it 'has valid references' do
      expect(@proxy.service).to eq(@service)
      expect(@proxy.manager).to eq(@manager)
    end

    it 'should read proxy' do
      expect(@proxy.entity).to include('service_id' => @service['id'])
    end

    it 'should update proxy' do
      @proxy['endpoint'] = @url
      expect(@proxy.update.entity).to include('endpoint' => @url)
      expect(@proxy.entity).to include('endpoint' => @url)
    end
  end
end