module OldApi
  class Authorization
    def auth_url
      "#{old_api_url}/login"
    end

    def auth(login, password)
      option = {
        method: :post,
        url: auth_url,
        payload: {
          email: login,
          password: password,
          device_id: SecureRandom.uuid
        }
      }
      req = SignOldApi.signed_request(option).request(sign: false)
      SignOldApi.cookies = req.cookies
      unless req.parse['content'].nil? || req.parse['content']['client'].nil?
        Tokens.init(req.parse['content']['client'])
      end
      req
    end

    def auth_as(role)
      auth(CREDENTIALS[role]['email'], CREDENTIALS[role]['pswd'])
    end

    def auth_as_new_user(params = {})
      reg_req = OldApi::Users.new.registration(params)
      email = reg_req.parse['content']['user']['email']
      password = params.fetch :password, 'qwer'
      auth(email, password)
    end
  end
end
