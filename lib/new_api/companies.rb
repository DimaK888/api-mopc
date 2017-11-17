module NewApi
  class Companies
    def user_company_list_url(user_id)
      NewApi::Users.new.user_companies(user_id)
    end
  end
end