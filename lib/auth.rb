module Authorization
  class AuthNewApi
    def auth_url
      "#{URL}/api/v1/clients"
    end

    def basic_auth(email, password)
      self.merge(
        {
          user: email,
          password: password
        }
      ).request.perform
    end

    def auth(login, password)
      option = {
        method: :post,
        url: auth_url,
        payload: {
          session: {
            login: login,
            password: password
          }
        }
      }
      req = option.request.perform
      unless req.parse_body['client'].nil?
        Token.token = req.parse_body['client']
      end
      req
    end

    def auth_as(role)
      auth(CREDENTIALS[role]['email'], CREDENTIALS[role]['pswd'])
    end

    def refresh_token
      option = {
        method: :post,
        url: "#{auth_url}/#{Token.token['access_id']}/tokens",
        payload: {refresh_token: Token.token['refresh_token']}
      }
      req = option.request.perform
      unless req.parse_body['client'].nil?
        Token.token = req.parse_body['client']
      end
      req
    end

    def log_out
      Token.token = {}
    end
  end

  class AuthOldApi
  end

  class Token
    class << self
      attr_accessor :token
    end
  end
end
