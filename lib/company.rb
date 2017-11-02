require_relative '../spec/helpers/api_access'
require 'users'

include ApiAccess

class Company
  def user_company_list_url(user_id)
    Users.new.user_companies(user_id)
  end
end
