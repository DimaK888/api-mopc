require_relative '../spec/helpers/api_access'

include ApiAccess

class Users
  def users_url
    "#{URL}/api/v1/users"
  end

  def users(user_id)
    {method: :get, url: "#{users_url}/#{user_id}"}
  end

  def user_info(param)
    {method: :get, url: "#{users_url}?#{param}"}
  end

  def user_update(user_id)
    {method: :put, url: "#{users_url}/#{user_id}"}
  end

  def user_companies(user_id)
    {method: :get, url: "#{users_url}/#{user_id}/companies"}
  end
end
