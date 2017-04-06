# frozen_string_literal: true

require 'three_scale_api/tools'

module ThreeScaleApi
  module Resources
    # Default resource manager wrapper for default entity received by REST API
    # All other managers inherits from Default manager
    class DefaultManager
      attr_accessor :http_client, :resource_instance, :log

      # Creates instance of the Default resource manager
      #
      # @param [ThreeScaleApi::HttpClient] http_client Instance of http client
      def initialize(http_client, entity_name: nil, collection_name: nil)
        @http_client = http_client
        @log = http_client.logger_factory.get_instance(name: manager_name)
        @resource_instance = DefaultResource
        @entity_name = entity_name
        @collection_name = collection_name
      end

      # Base path for the REST call
      #
      # @return [String] Base URL for the REST call
      def base_path
        +'/admin/api'
      end

      # Extracts Hash from response
      #
      # @param [String] collection Collection name
      # @param [String] entity Entity name
      # @param [object] from Response
      def extract(collection: nil, entity:, from:)
        from = from.fetch(collection) if collection

        case from
        when Array then from.map { |e| e.fetch(entity) }
        when Hash then from.fetch(entity) { from }
        when nil then nil # raise exception?
        else
          raise "unknown #{from}"
        end
      end

      # Access entity by it's ID or name
      #
      # @param [String,Fixnum] key Id or name of the entity
      # @return [DefaultResource] Requested entity
      def [](key)
        if key.is_a? Numeric
          read(key)
        else
          read_by_name(key)
        end
      end

      # Update entity
      #
      # @param [String,Fixnum] key id or name of the entity
      # @param [DefaultEntity] value Entity to be updated
      # @return [DefaultEntity] Updated entity
      def []=(key, value)
        id = if key.is_a? Numeric
               key
             else
               read_by_name(key)['id']
             end
        update(value, id: id)
      end

      # Creates entity
      #
      # @param [Hash] attributes Attributes for service to be created
      # @return [DefaultResource] Created resource
      def <<(attributes)
        create(attributes)
      end

      # Default method to list all the resources by manager
      #
      # @return [Array<DefaultResource>] The list of the Resources
      # @param [Hash] params optional arguments
      def list(params: {})
        @log.debug('List')

        response = http_client.get(base_path, params: params)
        resource_list(response)
      end

      # Default delete function
      def delete(id, params: {})
        @log.debug("Delete #{resource_name}: #{id}")

        @http_client.delete("#{base_path}/#{id}", params: params)
        true
      end

      # Default read function
      #
      # @param [Fixnum] id Id of the entity
      # @return [DefaultResource] Instance of the default resource
      def read(id = nil)
        @log.debug("Read #{resource_name}: #{id}")
        response = http_client.get("#{base_path}/#{id}")
        resource_instance(response)
      end

      # Finds resource by it's system name
      #
      # @param [String] name System name
      # @return [DefaultResource] Resource instance
      def read_by_name(name)
        name = name.to_s
        find do |ent|
          ent['system_name'] == name || ent['name'] == name || ent['org_name'] == name || ent['friendly_name'] == name || ent['username'] == name
        end
      end

      # Finds resource by it's spec. attribute name
      #
      # @param [Block] block Condition block
      # @return [DefaultResource] Resource instance
      def find(params: {}, &block)
        @log.debug("Find #{resource_name}")
        response = @http_client.get(base_path, params: params)
        return nil unless response
        resources = resource_list(response)
        resources.find(&block)
      end

      # Selects resources by it's spec. conditions
      #
      # @param [Block] block System name
      # @return [Array<DefaultResource>] Array of Resources instance
      def select(&block)
        @log.debug("Select #{resource_name}")
        response = @http_client.get(base_path, params: params)
        return nil unless response
        resources = resource_list(response)
        resources.select(&block)
      end

      # Creates new resource
      #
      # @param [Hash] attributes Attributes of the created object
      # @return [DefaultResource] Created resource
      def create(attributes)
        @log.debug("Create #{resource_name}: #{attributes}")
        response = http_client.post(base_path, body: attributes)
        resource_instance(response)
      end

      # Updates existing resource
      #
      # @param [Hash, DefaultResource] attributes Attributes that will be updated
      # @return [DefaultResource] Updated resource
      def update(attributes, id: nil)
        id ||= attributes['id']
        @log.debug("Update [#{id}]: #{attributes}")
        response = http_client.put("#{base_path}/#{id}", body: attributes)
        resource_instance(response)
      end

      # Wrapper to create instance of the Resource
      # Requires to have @resource_instance initialized to correct Resource subtype
      #
      # @param [Hash] entity Entity received from REST call using API
      # @return [DefaultResource] Specific instance of the resource
      def instance(entity)
        inst = {}
        inst = @resource_instance.new(@http_client, self, entity) if @resource_instance.respond_to?(:new)
        @log.debug("[RES] #{inst.class.name.split('::').last}: #{entity}")
        inst
      end

      # Wrap result of the call to the instance
      #
      # @param [object] response Response from server
      def resource_instance(response)
        result = extract(entity: @entity_name, from: response)
        instance(result)
      end

      # Wrap result array of the call to the instance
      #
      # @param [object] response Response from server
      def resource_list(response)
        result = extract(collection: @collection_name, entity: @entity_name, from: response)
        result.map { |res| instance(res) }
      end

      # Gets manager name for logging purposes
      #
      # @return [String] Manager name
      def manager_name
        self.class.name.split('::').last
      end

      # Gets resource name for specific manager
      #
      # @return [String] Manager name
      def resource_name
        manager = manager_name.dup
        manager['Manager'] = ''
        manager
      end
    end

    # Default resource wrapper for any entity received by REST API
    # All other resources inherits from Default resource
    class DefaultResource
      attr_accessor :http_client,
                    :manager,
                    :api,
                    :entity

      # Construct the resource
      #
      # @param [ThreeScaleApi::HttpClient] client Instance of http client
      # @param [ThreeScaleApi::Resources::DefaultManager] manager Instance of test client
      # @param [Hash] entity Entity Hash from API client
      def initialize(client, manager, entity)
        @http_client = client
        @entity = entity
        @manager = manager
      end

      # Access properties of the resource contained in the entity
      #
      # @param [String] key Name of the property
      # @return [object] Value of the property
      def [](key)
        return nil unless entity
        @entity[key]
      end

      # Set property value of the resource contained in the entity
      #
      # @param [String] key Name of the property
      # @param [String] value Value of the property
      # @return [object] Value of the property
      def []=(key, value)
        return nil unless entity
        @entity[key] = value
      end

      # Deletes Resource if possible (method is implemented in the manager)
      def delete
        return false unless @entity
        @manager.delete(@entity['id']) if @manager.respond_to?(:delete)
      end

      # Updates Resource if possible (method is implemented in the manager)
      #
      # @return [DefaultEntity] Updated entity
      def update
        return nil unless @entity
        @manager.update(@entity) if @manager.respond_to?(:update)
      end

      # Reloads entity from remote server if possible
      #
      # @return [DefaultEntity] Entity
      def read
        return nil unless entity
        return nil unless @manager.respond_to?(:read)
        ent = @manager.read(@entity['id'])
        @entity = ent.entity
      end

      def to_s
        entity.to_s
      end

      # Wrapper to create manager instance
      #
      # @param [Class<DefaultManager>] which Manager which instance will be created
      # @param [Array<Symbol>] args Optional arguments
      # @return [DefaultManager] Instance of the specific manager
      def manager_instance(which, *args)
        which.new(@http_client, self, *args) if which.respond_to?(:new)
      end

      def include?(key)
        @entity.include?(key)
      end

      def to_h
        @entity
      end

    end
  end
end
