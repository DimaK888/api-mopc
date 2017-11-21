module NewApi
  class Regions
    include Extensions::Regions

    def city_by_ip
      url = "#{new_api_url}/cities/current"
      res = { method: :get, url: url }.request.parse['city']
      {
        city_id: res['id'],
        city_name: res['name'],
        province_id: res['province']['id'],
        province_name: res['province']['name'],
        country_id: res['province']['country']['id'],
        country_name: res['province']['country']['name']
      }
    end

    def countries
      url = "#{new_api_url}/countries"
      { method: :get, url: url }.request
    end

    def provinces(country_id)
      url = url_collector("#{new_api_url}/provinces", country_id: country_id)
      { method: :get, url: url }.request
    end

    def cities(province_id)
      url = url_collector("#{new_api_url}/cities", province_id: province_id)
      { method: :get, url: url }.request
    end

    def countries_list
      countries.parse['countries']
    end

    def provinces_list(country_id)
      provinces(country_id).parse['provinces']
    end

    def cities_list(province_id)
      cities(province_id).parse['cities']
    end

    def random_city
      path = []
      country = main_countries.sample
      path << country[:name]
      province = provinces_list(country[:id]).sample
      path << province['name']
      city = cities_list(province['id']).sample
      path << city['name']
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
