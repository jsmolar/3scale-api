# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Mapping rule Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @service = create_service
    @metric = @service.metrics.list.first
    @manager = @service.mapping_rules(@metric)
    @pattern = "/#{@name}"
    @resource = @manager.create(http_method: 'DELETE', pattern: @pattern, delta: 1)
  end

  after(:all) do
    clean_resource(@service)
  end

  context '#mapping_rule CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'pattern' }

    it 'has valid references' do
      expect(@resource.service).to eq(@service)
      expect(@resource.metric).to eq(@metric)
      expect(@resource.manager).to eq(@manager)
    end

    it 'should create entity' do
      expect(entity).to include(base_attr => @pattern)
    end

    it 'should list entity' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read entity' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @pattern)
    end

    it 'should delete entity' do
      res_name = "/#{SecureRandom.uuid}"
      resource = @manager.create(http_method: 'PATCH', pattern: res_name, delta: 1)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should update entity' do
      updated = 100
      @resource['delta'] = updated
      expect(@resource.update.entity).to include('delta' => updated)
      expect(@resource.entity).to include('delta' => updated)
    end
  end
end