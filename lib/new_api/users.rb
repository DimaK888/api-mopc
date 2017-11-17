module NewApi
  class Users
    def users_url
      "#{new_api_url}/users"
    end

    def users(user_id = Tokens.user_id)
      { method: :get, url: "#{users_url}/#{user_id}" }.request
    end

    def user_info(params)
      # params <= email, phone, contacts
      { method: :get, url: url_collector(users_url, params) }.request
    end

    def update(payload, user_id = Tokens.user_id)
      { method: :put, url: "#{users_url}/#{user_id}", payload: payload }.request
    end

    def user_companies(user_id)
      { method: :get, url: "#{users_url}/#{user_id}/companies" }.request
    end

    def registration(params)
      # params <= email, phone, password, profile_attributes: { name, contacts }
      { method: :post, url: users_url, payload: params }.request
    end

    def expected_phone(phone = random_mobile_phone)
      phone[0] = '+7' if phone[0] == '8'
      phone.delete('- ')
    end
  end
end
