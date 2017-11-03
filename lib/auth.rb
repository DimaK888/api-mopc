require_relative '../spec/helpers/api_access'
require_relative '../spec/helpers/db_access'

include ApiAccess

module Authorization
  class AuthNewApi
    def auth_url
      "#{URL}/api/v1/clients"
    end

    def dont_check_signature
      "#{self}&check_signature=0"
    end

    def auth(email, password)
      option = {
        method: :post,
        url: auth_url,
        payload: {
          session: {
            login: email,
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
