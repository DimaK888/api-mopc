module Company
  class NewApiCompany
    def user_company_list_url(user_id)
      Users::NewApiUsers.new.user_companies(user_id)
    end
  end
end