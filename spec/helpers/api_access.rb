require 'rest-client'
require 'json'

module ApiAccess

  def get(url, headers={})
    begin
      RestClient.get(url, headers)
    rescue RestClient::ExceptionWithResponse => err
      return err.response
    end
  end

  def post(url, payload, headers={})
    begin
      RestClient.post(url, payload, headers)
    rescue RestClient::ExceptionWithResponse => err
      return err.response
    end
  end

  def parse_body
    JSON.parse(self.body)
  end
end
