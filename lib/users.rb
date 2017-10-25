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

    url += "?u=#{opts[:token]}" if opts[:token]

    param = {
        method: :get,
        url: url
    }

    if opts[:user] && opts[:pswd]
      param.merge!(
        user: opts[:user],
        password: opts[:pswd]
      )
    end

    execute(param)
  end
end
