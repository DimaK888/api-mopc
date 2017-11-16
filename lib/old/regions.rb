module Regions
  class OldApiRegions
    def countries
      req_param = { method: :get, url: "#{old_api_url}/countries" }
      SignOldApi.signed_request(req_param).request
    end

    def provinces(country_id)
      req_param = {
        method: :get,
        url: "#{old_api_url}/provinces",
        url_params: { parent_id: country_id }
      }
      SignOldApi.signed_request(req_param).request
    end

    def cities(province_id)
      req_param = {
        method: :get,
        url: "#{old_api_url}/cities",
        url_params: { parent_id: province_id }
      }
      SignOldApi.signed_request(req_param).request
    end

    def countries_list
      countries.parse_body['content']['countries']
    end

    def provinces_list(country_id)
      provinces(country_id).parse_body['content']['provinces']
    end

    def cities_list(province_id)
      cities(province_id).parse_body['content']['cities']
    end

    def random_city
      path = []
      country = main_countries.sample
      path << country[:name]
      province = provinces_list(country[:id]).sample
      path << province['name']
      city = cities_list(province['id']).sample
      path << city['name']
      { id: city['id'], name: city['name'], path: path }
    end
  end
end