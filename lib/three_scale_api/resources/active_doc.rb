# frozen_string_literal: true

require 'three_scale_api/resources/default'


module ThreeScaleApi
  module Resources
    # Active doc resource manager wrapper for the active doc entity received by the REST API
    class ActiveDocManager < DefaultManager
      # Creates instance of the Active doc resource manager
      #
      # @param [ThreeScaleQE::TestClient] http_client Instance of http client
      def initialize(http_client)
        super(http_client, entity_name: 'api_doc', collection_name: 'api_docs')
        @resource_instance = ActiveDoc
      end

      def read(id)
        @log.debug("Read #{resource_name}: #{id}")
        list.find { |doc| doc['id'] == id }
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        super + '/active_docs'
      end
    end

    # Active doc resource wrapper for the active doc entity received by REST API
    class ActiveDoc < DefaultResource
      # Creates instance of the Active doc resource
      #
      # @param [ThreeScaleQE::TestClient] client Instance of the test client
      # @param [ActiveDocManager] manager Instance of the manager
      # @param [Hash] entity Service Hash from API client
      def initialize(client, manager, entity)
        super(client, manager, entity)
      end
    end
  end
end
