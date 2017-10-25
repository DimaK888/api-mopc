require_relative '../spec/helpers/api_access'
require_relative '../spec/helpers/db_access'

include ApiAccess
include DBAccess

module Authorization
  class AuthNewApi
    def auth_url
      "#{URL}/api/v1/clients"
    end

    def url_auth_token(user_id)
      auth_token(user_id)
    end

    def signed_url(url, user_id)
      url + "?u=#{auth_token(user_id)}"
    end

    def auth(email, password)
      payload = {
        session: { login: email, password: password }
      }
      execute(method: :post, url: auth_url, payload: payload)
    end
  end

  class AuthOldApi

  end
end
