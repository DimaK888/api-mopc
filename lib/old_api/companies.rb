module OldApi
  class Companies
    def registration(params)
      # params <= name, name_rest, city_id, code, number
      req_param = {
        method: :post,
        url: "#{old_api_url}/company/registration",
        payload: params
      }
      SignOldApi.signed_request(req_param)
    end

    def company_request(params)
      # params <= company_id, name, contacts
      req_param = {
        method: :post,
        url: "#{old_api_url}/company/request",
        payload: params
      }
      SignOldApi.signed_request(req_param)
    end
  end
end
