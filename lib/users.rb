class Users
  def users_url
    "#{new_api_url}/users"
  end

  def users(user_id = Tokens.user_id)
    { method: :get, url: "#{users_url}/#{user_id}" }
  end

  def user_info(params)
    { method: :get, url: url_collector(users_url, params) }
  end

  def user_update(payload, user_id = Tokens.user_id)
    { method: :put, url: "#{users_url}/#{user_id}", payload: payload }
  end

  def user_companies(user_id)
    { method: :get, url: "#{users_url}/#{user_id}/companies" }
  end

  def user_registration(params)
    { method: :post, url: users_url, payload: params }
  end

  def expected_phone(phone = random_mobile_phone)
    phone[0] = '+7' if phone[0] == '8'
    phone.delete('- ')
  end
end
