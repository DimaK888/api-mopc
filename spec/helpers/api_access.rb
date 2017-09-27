require 'net/http'
require 'net/https'
require 'json'

module ApiAccess
  def authorization(opt)
    if opt['token'].nil?
      self['Authorization'] = opt['token']
    else
      self.basic_auth(opt['email'], opt['pswd'])
    end
  end

  def get(auth = {})
    request = Net::HTTP::Get.new(URI(self).request_uri)
    request.authorization(auth) unless auth.empty?

    URI(self).http.request(request)
  end

  def post(opt = {})
    request = Net::HTTP::Post.new(URI(self).request_uri)
    request.authorization(opt) unless opt['email'].nil? && opt['token'].nil?
    request.set_form_data(opt)

    URI(self).http.request(request)
  end

  def response_body
    JSON.parse(self.body)
  end

  def http
    Net::HTTP.start(self.host, self.port)
  end
end
