# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Account user Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @endpoint = ENV.fetch('ENDPOINT')
    @provider_key = ENV.fetch('PROVIDER_KEY')
    @acc_name = SecureRandom.uuid
    @name = SecureRandom.uuid
    @acc_resource = create_account(name: @acc_name)
    @manager = @acc_resource.users
    @resource = @manager.create(username: @name,
                                password: @name,
                                email: "#{@name}@example.com")
  end

  after(:all) do
    clean_resource(@acc_resource)
  end

  context '#account_user CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'username' }

    it 'should create account user' do
      expect(entity).to include(base_attr => @name)
    end

    it 'should list account users' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read account user' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete account user' do
      res_name = SecureRandom.uuid
      resource = @manager.create(username: res_name,
                                 email: "#{res_name}@example.com",
                                 password: res_name)
      expect(resource.entity).to include(base_attr => res_name)
      resource.delete
      expect(@manager.list.any? { |r| r[base_attr] == res_name }).to be(false)
    end

    it 'should update account user' do
      new_name = SecureRandom.uuid
      @resource[base_attr] = new_name
      expect(@resource.update.entity).to include(base_attr => new_name)
      expect(@resource.entity).to include(base_attr => new_name)
    end

    it 'should activate account user' do
      expect(@resource['state']).to eq('pending')
      @resource.activate
      expect(@manager[@resource['id']].entity).to include('state' => 'active')
    end

    it 'should set as admin' do
      expect(@resource['role']).to eq('member')
      @resource.as_admin
      expect(@manager[@resource['id']].entity).to include('role' => 'admin')
    end
  end
end