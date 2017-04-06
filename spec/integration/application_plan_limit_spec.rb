# frozen_string_literal: true

require_relative '../shared_stuff'

RSpec.describe 'Application plan limit resource', type: :integration do

  include_context 'Shared initialization'

  before(:all) do
    @service = create_service
    @unit = 'click'
    @metric = @service.metrics.create(friendly_name: @name, unit: @unit)
    @app_plan = @service.application_plans.create(name: @name, system_name: @name)
    @manager = @app_plan.limits(@metric)
    @resource = @manager.create(period: 'minute', value: 10)
  end

  after(:all) do
    clean_resource(@app_plan)
    clean_resource(@metric)
    clean_resource(@service)
  end

  context '#application_limit_plan CRUD' do
    subject(:entity) { @resource.entity }
    it 'should create application plan limit' do
      expect(entity).to include('period' => 'minute')
      expect(entity).to include('value' => 10)
    end

    it 'should list application plan limits' do
      expect(@manager.list.length).to be >= 1
    end

    it 'should read application plan limit' do
      expect(@manager.read(@resource['id']).entity).to include('period' => 'minute')
    end

    it 'should delete application plan limit' do
      resource = @manager.create(period: 'hour', value: 100)
      expect(resource.entity).to include('period' => 'hour')
      resource.delete
      expect(@manager.list.any? { |r| r['period'] == 'hour' }).to be(false)
    end

    it 'should update application plan limit' do
      @resource['value'] = 100
      expect(@resource.update.entity).to include('value' => 100)
      expect(@resource.entity).to include('value' => 100)
    end
  end
end