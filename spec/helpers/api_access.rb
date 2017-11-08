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

  def dont_check_signature
    if self.class == Hash
      url = "#{self[:url]}&check_signature=0"
      self.merge!({url: url})
    elsif self.class == String
      "#{self}&check_signature=0"
    else
      '&check_signature=0'
    end
  end

  def perform
    self.execute
  rescue RestClient::ExceptionWithResponse => err
    return err.response
  end

  def parse_body
    JSON.parse(self.body)
  end

  def null
    nil
  end
end