# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Active Doc Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @manager = @client.active_docs
    @resource = create_active_doc
  end

  after(:all) do
    clean_resource(@resource)
  end

  context '#Active doc CRUD' do
    subject(:entity) { @resource.entity }
    let(:base_attr) { 'name' }
    it 'should create active doc' do
      expect(entity).to include(base_attr => @name)
      expect(entity).to include('published' => false)
    end

    it 'should list active docs' do
      res_name = @resource[base_attr]
      expect(@manager.list.any? { |res| res[base_attr] == res_name }).to be(true)
    end

    it 'should read active doc' do
      expect(@manager.read(@resource['id']).entity).to include(base_attr => @name)
    end

    it 'should delete active doc' do
      res_name = SecureRandom.uuid
      res = create_active_doc(name: res_name)
      expect(res.entity).to include(base_attr => res_name)
      res.delete
      expect(@manager.list.any? { |s| s[base_attr] == res[base_attr] }).to be(false)
    end

    it 'should find active doc' do
      resource = @manager[@resource[base_attr]]
      expect(resource.entity).to include('id' => @resource['id'])
      resource_id = @manager[@resource['id']]
      expect(resource_id.entity).to include(base_attr => @name)
    end

    it 'should update active doc' do
      @resource['published'] = true
      expect(@resource.update.entity).to include('published' => true)
      expect(@resource.entity).to include('published' => true)
    end
  end
end