module OldApi
  class Regions
    include Extensions::Regions

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
      countries.parse['content']['countries']
    end

    def provinces_list(country_id)
      req = provinces(country_id).parse['content']
      if req.nil? || req['provinces'].nil? || req['provinces'].empty?
        raise('PROVINCES LIST IS EMPTY!')
      end
      req['provinces']
    end

    def cities_list(province_id)
      req = cities(province_id).parse['content']
      if req.nil? || req['cities'].nil? || req['cities'].empty?
        raise('CITIES LIST IS EMPTY!')
      end
      req['cities']
    end

    def random_city(country = {})
      path = []
      country = country.empty? ? main_countries.sample : country
      path << country[:name].to_s
      province = provinces_list(country[:id]).sample
      path << province['title'].to_s
      city = cities_list(province['id']).sample
      path << city['title'].to_s
      number_length = country[:phone_length] - city['phone_code'].size
      {
        id: city['id'],
        name: city['name'],
        path: path,
        phone_code: city['phone_code'],
        phone_number: '#' * number_length,
        phone_length: country[:phone_length]
      }
    end
  end
end
