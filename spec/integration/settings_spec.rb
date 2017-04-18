# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Settings Resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @manager = @client.settings
  end

  context '#settings read and update' do
    subject(:entity) { @manager.read }

    it 'should read settings' do
      expect(entity).to be_truthy
      expect(entity.entity).to include('signups_enabled')
      expect(entity.entity).to include('strong_passwords_enabled')
    end

    it 'should update settings' do
      entity['strong_passwords_enabled'] = true
      entity.update
      res = @manager.read
      expect(res.entity).to include('strong_passwords_enabled' => true)
      res['strong_passwords_enabled'] = false
      res.update
      expect(@manager.read.entity).to include('strong_passwords_enabled' => false)
    end
  end

end