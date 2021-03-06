module OldApi
  class Users
    def registration(params = {})
      # params <= fio, email, password, password_confirmation
      default_params = {
        email: Faker::Internet.email,
        password: 'qwer',
        fio: Ryba::Name.full_name
      }

      req_param = {
        method: :post,
        url: "#{old_api_url}/registration",
        payload: default_params.merge(params)
      }
      SignOldApi.signed_request(req_param).request
    end

    def user_info
      req_param = { method: :get, url: "#{old_api_url}/user_info" }
      SignOldApi.signed_request(req_param).request
    end
  end
end
