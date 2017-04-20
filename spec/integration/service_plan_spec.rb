# frozen_string_literal: true

require_relative '../shared_tests_config'

RSpec.describe 'Service plan Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @service = create_service
    @manager =  @service.service_plans
    @resource = @manager.create(name: @name, system_name: @name)
  end

  after(:all) do
   clean_resource(@service)
  end

  context '#service_plan CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'name' }

    it 'should create service' do
      expect(entity).to include(base_attr => @name)
    end

    it 'should list service plan' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should list all service plans' do
      res_name = @resource[base_attr]
      expect(@manager.list_all.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read service plan' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete service plan' do
      res_name = SecureRandom.uuid
      resource = @manager.create(name: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should find service plan' do
      resource = @manager[@resource[base_attr]]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'should update service plan' do
      res_name = SecureRandom.uuid
      @resource[base_attr] = res_name
      expect(@resource.update.entity).to include(base_attr => res_name)
      expect(@resource.entity).to include(base_attr => res_name)
    end

    it 'should set_default and get_default service plan' do
      old_default = @manager.get_default
      if old_default
        expect(@manager[old_default['id']].to_h).to include('default' => true)
      end

      @resource.set_default

      expect(@manager[@resource['id']].to_h).to include('default' => true)
      if old_default
        old_default.set_default
        expect(@manager[old_default['id']].to_h).to include('default' => true)
      end
    end
  end

end