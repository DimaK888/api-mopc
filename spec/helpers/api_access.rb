require 'rest-client'
require 'api-auth'
require 'json'

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

  class Token
    class << self
      attr_accessor :token
    end
  end
end