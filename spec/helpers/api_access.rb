require 'rest-client'
require 'api-auth'
require 'json'

require_relative '../../lib/auth'

module ApiAccess
  def new_api_url
    RestClient.normalize_url("#{URL}/api/v1")
  end

  def old_api_url
    RestClient.normalize_url(URL.sub('www', 'api'))
  end

  def request(param = {})
    request = RestClient::Request.new(self)
    access_id = param.fetch :access_id, Tokens.access_id
    secret_key = param.fetch :secret_token, Tokens.secret_token
    sign = param.fetch :sign, true

    if !sign || access_id.nil? || secret_key.nil?
      request.perform
    else
      ApiAuth.sign!(request, access_id, secret_key).perform
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

  class SignOldApi
    class << self
      attr_accessor :token, :cookies

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

      def get_sign
        res = {method: :get, url: "#{old_api_url}/hello"}.request(sign: false)
        @token = res.parse_body['content']['token']
        @cookies = res.cookies
      end

      def old_api_signature(url)
        get_sign
        temp_url =
            if url.size > @token.size
              url[@token.size - 1] += @token
              url
            else
              url += @token
            end
        Digest::MD5.hexdigest temp_url.to_s
      end

      def info # example
        url = "#{old_api_url}/info"
        sign = old_api_signature(url.dup)
        {method: :get, url: "#{url}?sign=#{sign}", cookies: @cookies}.request
      end
    end
  end
end
