require 'rest-client'
require 'api-auth'
require 'json'

require_relative '../../lib/auth'

module ApiAccess
  def request
    RestClient::Request.new(self)
  end

  def signed_request
    access_id = Token.token['access_id']
    secret_key = Token.token['secret_token']
    if access_id && secret_key
      ApiAuth.sign!(request, access_id, secret_key)
    else
      puts 'NOT AUTHORIZED'
      request
    end
  end

  def perform
    begin
      self.execute
    rescue RestClient::ExceptionWithResponse => err
      return err.response
    end
  end

  def parse_body
    JSON.parse(self.body)
  end
end