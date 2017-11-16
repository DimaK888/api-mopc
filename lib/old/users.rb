module Users
  class OldApiUsers
    def registration(params)
      # params <= fio, email, password, password_confirmation
      req_param = {
        method: :post,
        url: "#{old_api_url}/registration",
        payload: params
      }
      SignOldApi.signed_request(req_param).request
    end

    def user_info
      req_param = { method: :get, url: "#{old_api_url}/user_info" }
      SignOldApi.signed_request(req_param).request
    end
  end
end
