require_relative '../spec/helpers/api_access'
require_relative '../spec/helpers/db_access'

include ApiAccess

module Authorization
  class AuthNewApi
    def auth_url
      "#{URL}/api/v1/clients"
    end

    def dont_check_signature(url)
      url + '&check_signature=0'
    end

    def auth(email, password)
      payload = {
        session: { login: email, password: password }
      }
      option = {method: :post, url: auth_url, payload: payload}
      req = option.request.perform
      Token.token = req.parse_body['client']
      req
    end

    def log_out
      Token.token = {}
    end
  end

  class AuthOldApi
  end
end
