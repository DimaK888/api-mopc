module NewApi
  class Authorization
    def basic_auth(email, password)
      self.merge(
        {
          user: email,
          password: password
        }
      ).request(sign: false)
    end

    def auth_url
      "#{new_api_url}/clients"
    end

    def auth(login, password)
      option = {
        method: :post,
        url: auth_url,
        payload: {
          session: {
            login: login,
            password: password
          },
          device_id: SecureRandom.uuid
        }
      }
      req = option.request(sign: false)
      unless req.parse['client'].nil?
        Tokens.init(req.parse['client'])
      end
      req
    end

    def refresh_token
      option = {
        method: :post,
        url: "#{auth_url}/#{Tokens.access_id}/tokens",
        payload: { refresh_token: Tokens.refresh_token }
      }
      req = option.request
      unless req.parse['client'].nil?
        Tokens.init(req.parse['client'])
      end
      req
    end

    def auth_as(role)
      auth(CREDENTIALS[role]['email'], CREDENTIALS[role]['pswd'])
    end
  end
end
