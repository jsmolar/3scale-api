require 'three_scale_api/http_client'
require 'three_scale_api/tools'
require 'three_scale_api/resources/service'
module ThreeScaleApi
  def self.main()
    http = ThreeScaleApi::HttpClient.new(endpoint: 'https://redhatpstanko-admin.3scale.net',
      provider_key: '57877316219261f26f84448bb27ecd30aad25284beed54c103b8941e73413f35')

    serv_mgr = ThreeScaleApi::Resources::ServiceManager.new(http)
    serv_mgr.list

    serv = serv_mgr['api']
    serv.proxy.read
    serv.service_plans.list
    serv.metrics.list
  end
end

ThreeScaleApi.main
