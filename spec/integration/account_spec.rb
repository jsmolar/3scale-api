# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Account Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @manager = @client.accounts
    @resource = create_account
  end

  after(:all) do
    clean_resource(@resource)
  end

  context '#account CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'org_name' }

    it 'should create account' do
      expect(entity).to include(base_attr => @name)
    end

    it 'should list accounts' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read accounts' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete account' do
      res_name = SecureRandom.uuid
      resource = @manager.sign_up(org_name: res_name, username: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should find account' do
      resource = @manager[@resource[base_attr]]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'should update account' do
      expect(@resource.entity).to include('state' => 'created')
      @resource['state'] = 'approved'
      expect(@resource.update.entity).to include('state' => 'approved')
      expect(@resource.entity).to include('state' => 'approved')
    end

    it 'should set state of the account' do
      @resource.reject
      expect(@manager[@resource['id']].entity).to include('state' => 'rejected')
    end
  end
end