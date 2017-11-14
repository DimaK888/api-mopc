require 'rest-client'
require 'api-auth'
require 'json'

require_relative '../../lib/auth'

module ApiAccess
  def new_api_url
    normalize_url("#{URL}/api/v1")
  end

  def old_api_url
    normalize_url(URL.sub('www', 'api'))
  end

  def normalize_url(url)
    url = 'http://' + url unless url.match(%r{\A[a-z][a-z0-9+.-]*://}i)
    url
  end

  def url_collector(url, param={})
    str = url
    if param.empty?
      str
    else
      str << '?' << param.sort.
        map{ |key, value| "#{key}=#{URI.encode(value.to_s)}" }.join('&')
    end
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
      attr_accessor :token, :cookies, :ttl

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

      def get_token
        if @token.nil? || @ttl.nil? || @ttl <= Time.now
          res = {method: :get, url: "#{old_api_url}/hello"}.request(sign: false)
          @ttl = Time.now + res.parse_body['content']['ttl']
          @token = res.parse_body['content']['token']
          @cookies = res.cookies
        end
      end

      def old_api_sign(url, params = {})
        get_token
        str = url
        str << params.
          reject{ |key, _| %W{img sign}.include?(key.to_s) }.sort.
          map{ |key, value| [key.to_s, URI.encode(value.to_s)] }.join
        if str.size > @token.size
          str.insert(@token.size, @token)
        else
          str << @token
        end
        Digest::MD5.hexdigest(str)
      end
    end
  end
end
