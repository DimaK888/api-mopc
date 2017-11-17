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
        }
      }
      req = SignOldApi.signed_request(option).request(sign: false)
      SignOldApi.cookies = req.cookies
      req
    end

    def auth_as(role)
      auth(CREDENTIALS[role]['email'], CREDENTIALS[role]['pswd'])
    end
  end
end
