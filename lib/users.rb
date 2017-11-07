class Users
  def users_url
    "#{URL}/api/v1/users"
  end

  def users(user_id)
    {method: :get, url: "#{users_url}/#{user_id}"}
  end

  def user_info(param)
    @url = "#{users_url}?"
    param.each_pair do |key, value|
      unless value.nil? || value.empty?
        @url += '&' if @url[-1] != '?'
        @url += "#{key}=#{value}"
      end
    end
    {method: :get, url: @url}
  end

  def user_update(user_id)
    {method: :put, url: "#{users_url}/#{user_id}"}
  end

  def user_companies(user_id)
    {method: :get, url: "#{users_url}/#{user_id}/companies"}
  end

  def user_registration(arg)
    {method: :post, url: users_url, payload: arg}
  end
end
