# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Service Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @manager = @client.services
    @resource = create_service
  end

  after(:all) do
    clean_resource(@resource)
  end

  context '#service CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'system_name' }

    it 'has valid references' do
      expect(@resource.manager).to eq(@manager)
    end

    it 'should create service' do
      expect(entity).to include(base_attr => @name)
    end

    it 'should list services' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read service' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete service' do
      res_name = SecureRandom.uuid
      resource = create_service(name: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should find service' do
      resource = @manager[@resource[base_attr]]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'should update service' do
      new_name = @name + '-updated'
      @resource['name'] = new_name
      expect(@resource.update.entity).to include('name' => new_name)
      expect(@resource.entity).to include('name' => new_name)
    end
  end
end