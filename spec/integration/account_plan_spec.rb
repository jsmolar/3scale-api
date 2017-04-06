# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Account plan Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @manager = @client.account_plans
    @resource = @manager.create(name: @name)
  end

  after(:all) do
    clean_resource(@resource)
  end

  context '#account_plan CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'name' }

    it 'should create account plan' do
      expect(entity).to include(base_attr => @name)
    end


    it 'should list account plan' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read account plan' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete account plan' do
      res_name = SecureRandom.uuid
      resource = @manager.create(name: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should find account plan' do
      resource = @manager[@resource[base_attr]]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'should update account plan' do
      res_name = SecureRandom.uuid
      @resource[base_attr] = res_name
      expect(@resource.update.entity).to include(base_attr => res_name)
      expect(@resource.entity).to include(base_attr => res_name)
    end

    it 'should set_default and get_default account plan' do
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