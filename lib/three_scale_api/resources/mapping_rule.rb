# TODO# frozen_string_literal: true

require 'three_scale_api/resources/default'
require 'three_scale_api/resources/application_plan_limit'
require 'three_scale_api/resources/method'

module ThreeScaleApi
  module Resources
    # Mapping rules resource manager wrapper for the mapping rule entity received by REST API
    class MappingRuleManager < DefaultManager
      attr_accessor :service, :metric

      # Creates instance of the mapping rules resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client, service, metric: nil)
        super(http_client, entity_name: 'mapping_rule', collection_name: 'mapping_rules')
        @service = service
        @metric = metric
        @resource_instance = MappingRule
      end

      # Binds metric
      #
      # @param [Metric] metric Service metric
      def set_metric(metric)
        @metric = metric
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super + "/services/#{@service['id']}/proxy/mapping_rules"
      end

      # Creates new mapping rule
      #
      # @param [Hash] attributes Mapping Rule Attributes
      # @option attributes [String] :http_method HTTP Method
      # @option attributes [String] :pattern Pattern
      # @option attributes [Fixnum] :delta Increase the metric by delta.
      # @option attributes [Fixnum] :metric_id Metric ID
      def create(attributes)
        attributes[:metric_id] ||= @metric['id']
        super(attributes)
      end

      # Updates mapping rule
      #
      # @param [Fixnum] id Mapping rule id
      # @param [Hash] attributes Mapping Rule Attributes
      # @option attributes [String] :http_method HTTP Method
      # @option attributes [String] :pattern Pattern
      # @option attributes [Fixnum] :delta Increase the metric by delta.
      # @option attributes [Fixnum] :metric_id Metric ID
      def update(attributes, id: nil)
        attributes[:metric_id] ||= @metric['id']
        super(attributes, id: id)
      end
    end

    # MappingRule resource wrapper for the MappingRule entity received by the REST API
    class MappingRule < DefaultResource
      attr_accessor :service, :metric

      # Construct the MappingRule resource
      #
      # @param [ThreeScaleApi::HttpClient] client Instance of http client
      # @param [ThreeScaleApi::Resources::MappingRuleManager] manager Mapping rule manager
      # @param [Hash] entity Entity Hash from the API client of the MappingRule
      def initialize(client, manager, entity)
        super(client, manager, entity)
        @service = manager.service
        @metric = manager.metric
      end
    end
  end
end