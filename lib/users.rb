require_relative '../spec/helpers/api_access'

include ApiAccess

module UserInfo
  def users_url
    "#{URL}/api/v1/users"
  end

  def users_with_(opts = {})
    url = users_url
    if opts[:email]
      url += "?email=#{opts[:email].sub('@', '%40')}"
    elsif opts[:user_id]
      url += "/#{opts[:user_id]}"
    end
    if opts[:token]
      url += "?u=#{opts[:token]}"
    end
    get(url)
  end
end