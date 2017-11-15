module Authorization
  def basic_auth(email, password)
    self.merge(
        {
            user: email,
            password: password
        }
    ).request(sign: false)
  end

  def log_out
    Tokens.init({})
    SignOldApi.cookies = nil
    SignOldApi.ttl = nil
  end

  class AuthNewApi
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
          }
        }
      }
      req = option.request(sign: false)
      unless req.parse_body['client'].nil?
        Tokens.init(req.parse_body['client'])
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
      unless req.parse_body['client'].nil?
        Tokens.init(req.parse_body['client'])
      end
      req
    end

    def auth_as(role)
      auth(CREDENTIALS[role]['email'], CREDENTIALS[role]['pswd'])
    end
  end

  class AuthOldApi
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
          sign: SignOldApi.old_api_sign(auth_url, {email: login, password: password})
        },
        cookies: SignOldApi.cookies
      }
      req = option.request(sign: false)
      SignOldApi.cookies = {'X-Test': '1728'}.merge!(req.cookies)
      req
    end

    def auth_as(role)
      auth(CREDENTIALS[role]['email'], CREDENTIALS[role]['pswd'])
    end
  end

  class Tokens
    class << self
      attr_accessor :user_id, :access_id, :secret_token, :refresh_token

      def init(token)
        @user_id = token['user_id']
        @access_id = token['access_id']
        @secret_token = token['secret_token']
        @refresh_token = token['refresh_token']
      end
    end
  end
end
