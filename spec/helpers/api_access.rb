require 'rest-client'
require 'json'

module ApiAccess

  def execute(opts = {})
    begin
      RestClient::Request.execute(opts)
    rescue RestClient::ExceptionWithResponse => err
      return err.response
    end
  end

  def parse_body
    JSON.parse(self.body)
  end
end
