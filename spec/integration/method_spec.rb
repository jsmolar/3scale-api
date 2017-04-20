# frozen_string_literal: true

require_relative '../shared_tests_config'

RSpec.describe 'Method Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @service = create_service
    @metric = @service.metrics.list.first
    @manager = @metric.methods
    @resource = @manager.create(friendly_name: @name)
  end

  after(:all) do
    clean_resource(@service)
  end

  context '#method' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'friendly_name' }

    it 'has valid references' do
      expect(@resource.service).to eq(@service)
      expect(@resource.metric).to eq(@metric)
      expect(@resource.manager).to eq(@manager)
    end

    it 'should create method' do
      expect(entity).to include(base_attr => @name)
    end

    it 'should list methods' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read method' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete method' do
      res_name = SecureRandom.uuid
      resource = @manager.create(friendly_name: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should find method' do
      resource = @manager[@resource['system_name']]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'should update method' do
      unit_name = @name + 'Updated'
      @resource['system_name'] = unit_name
      expect(@resource.update.entity).to include('system_name' => unit_name)
      expect(@resource.entity).to include('system_name' => unit_name)
    end
  end

end