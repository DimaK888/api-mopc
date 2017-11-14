class Region
  def city_by_ip
    url = "#{new_api_url}/cities/current"
    res = { method: :get, url: url }.request.parse_body['city']
    {
      city_id: res['id'],
      city_name: res['name'],
      province_id: res['province']['id'],
      province_name: res['province']['name'],
      country_id: res['province']['country']['id'],
      country_name: res['province']['country']['name']
    }
  end
end