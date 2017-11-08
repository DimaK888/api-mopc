class Region
  def city_by_ip
    url = "#{URL}/api/v1/cities/current"
    res = {method: :get, url: url}.request.
      perform.parse_body['city']
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