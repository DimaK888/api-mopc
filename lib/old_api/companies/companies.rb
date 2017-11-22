module OldApi
  class Companies
    def registration(params = {})
      # params <= name, name_rest, city_id, code, number
      rand_city = OldApi::Regions.new.random_city

      default_params = {
        name: Ryba::Company.name,
        name_rest: random_name_rest,
        city_id: rand_city[:id],
        code: rand_city[:phone_code],
        number: rand_city[:phone_number].number_generator
      }

      req_param = {
        method: :post,
        url: "#{old_api_url}/company/registration",
        payload: default_params.merge(params)
      }
      SignOldApi.signed_request(req_param).request
    end

    def request(params)
      # params <= company_id, name, contacts
      default_params = {
        name: Ryba::Name.full_name,
        contacts: random_mobile_phone
      }

      req_param = {
        method: :post,
        url: "#{old_api_url}/company/request",
        payload: default_params.merge(params)
      }
      SignOldApi.signed_request(req_param).request
    end

    def company_list
      OldApi::Users.new.user_info.parse['content']['companies']
    end

    class << self
      attr_accessor :company_id
    end
  end
end
