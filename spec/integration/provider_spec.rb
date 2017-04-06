# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Provider Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @manager = @client.providers
    @resource = create_provider
  end

  after(:all) do
    clean_resource(@resource)
  end

  context '#provider CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'username' }
    it 'should create provider' do
      expect(entity).to include(base_attr => @name)
    end

    it 'should list provider' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read provider' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete provider' do
      res_name = SecureRandom.uuid
      resource = create_provider(name: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should update provider' do
      new_name = SecureRandom.uuid
      @resource[base_attr] = new_name
      expect(@resource.update.entity).to include(base_attr => new_name)
      expect(@resource.entity).to include(base_attr => new_name)
    end

    it 'should activate provider' do
      expect(@resource['state']).to eq('pending')
      @resource.activate
      expect(@manager[@resource['id']].entity).to include('state' => 'active')
    end

    it 'should set provider as admin' do
      expect(@resource['role']).to eq('member')
      @resource.as_admin
      expect(@manager[@resource['id']].entity).to include('role' => 'admin')
    end
  end
end