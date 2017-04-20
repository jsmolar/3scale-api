# frozen_string_literal: true

require_relative '../shared_tests_config'

RSpec.describe 'Metric Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @service = create_service
    @manager = @service.metrics
    @unit = 'click'
    @resource = @manager.create(friendly_name: @name, unit: @unit)
  end

  after(:all) do
    clean_resource(@service)
  end

  context '#metric' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'friendly_name' }

    it 'has valid references' do
      expect(@resource.service).to eq(@service)
    end

    it 'should create metric' do
      expect(entity).to include(base_attr => @name)
    end

    it 'should list metrics' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read metric' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete metric' do
      res_name = SecureRandom.uuid
      resource = @manager.create(unit: @unit, friendly_name: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should find metric' do
      resource = @manager[@resource['system_name']]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'should update metric' do
      unit_name = @unit + 'Updated'
      @resource['unit'] = unit_name
      expect(@resource.update.entity).to include('unit' => unit_name)
      expect(@resource.entity).to include('unit' => unit_name)
    end
  end

end