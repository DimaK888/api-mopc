require_relative '../spec/helpers/api_access'
require 'users'

include ApiAccess
include UserInfo

module Company
  def user_company_list_url(user_id)
    users_url + "/#{user_id}/companies"
  end
end