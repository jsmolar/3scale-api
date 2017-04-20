# frozen_string_literal: true

require_relative '../shared_tests_config'

RSpec.describe 'Application Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @service = create_service
    @app_plan = @service.application_plans.create(name: @name)
    @acc_resource = create_account
    @manager = @acc_resource.applications
    @resource = @manager.create(name: @name, description: @name, plan_id: @app_plan['id'])

    # Keys initialization
    @keys_manager = @resource.keys
    @key = @keys_manager.create(key: @name)
  end

  after(:all) do
    clean_resource(@acc_resource)
    clean_resource(@app_plan)
    clean_resource(@service)
  end

  context '#application CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'name' }
    it 'should create application' do
      expect(entity).to include(base_attr => @name)
      expect(entity).to include('description' => @name)
      expect(entity).to include('plan_id' => @app_plan['id'])
    end

    it 'should list applications' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read application' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete application' do
      res_name = SecureRandom.uuid
      resource = @manager.create(name: res_name, description: res_name, plan_id: @app_plan['id'])
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should update application' do
      new_name = SecureRandom.uuid
      @resource['description'] = new_name
      expect(@resource.update.entity).to include('description' => new_name)
      expect(@resource.entity).to include('description' => new_name)
    end

    it 'should activate application' do
      @resource.suspend
      expect(@manager[@resource['id']].entity).to include('state' => 'suspended')
      @resource.resume
      expect(@manager[@resource['id']].entity).to include('state' => 'live')
    end

    context 'keys' do
      it 'should create key' do
        expect(@keys_manager.list.any? { |res| res['value'] == @name }).to be(true)
      end

      it 'should list keys' do
        expect(@keys_manager.list.any? { |res| res['value'] == @name }).to be(true)
      end

      it 'should delete key' do
        res_name = SecureRandom.uuid
        resource = @keys_manager.create(key: res_name)
        expect(resource['value']).to eq(res_name)
        expect(@keys_manager.list.any? { |res| res['value'] == res_name }).to be(true)
        resource.delete
        expect(@manager.list.any? { |r| r['value'] == res_name }).to be(false)
      end

    end

  end
end