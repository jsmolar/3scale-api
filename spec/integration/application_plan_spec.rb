# frozen_string_literal: true

require_relative '../shared_tests_config'

RSpec.describe 'Application plan Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @service = create_service
    @manager =  @service.application_plans
    @resource = @manager.create(name: @name, system_name: @name)
  end

  after(:all) do
    clean_resource(@service)
  end

  context '#application_plan CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'name' }

    it 'should create application plan' do
      expect(entity).to include(base_attr => @name)
    end

    it 'should list all plans' do
      res_name = @resource[base_attr]
      expect(@manager.list_all.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should list app. plans' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read application plan' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete application plan' do
      res_name = SecureRandom.uuid
      resource = @manager.create( name: res_name )
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should find application plan' do
      resource = @manager[@resource[base_attr]]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'should update application plan' do
      res_name = SecureRandom.uuid
      @resource[base_attr] = res_name
      expect(@resource.update.entity).to include(base_attr => res_name)
      expect(@resource.entity).to include(base_attr => res_name)
    end

    it 'should set default and get_default app. plan' do
      old_default = @manager.get_default
      if old_default
        expect(@manager[old_default['id']].entity).to include('default' => true)
      end

      @resource.set_default
      
      expect(@manager[@resource['id']].entity).to include('default' => true)
      if old_default
        old_default.set_default
        expect(@manager[old_default['id']].entity).to include('default' => true)
      end
    end
  end
end