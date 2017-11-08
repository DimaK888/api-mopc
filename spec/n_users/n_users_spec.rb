include Authorization

auth = AuthNewApi.new
users = Users.new

describe 'Просмотр пользовательских данных api/v1/users' do
  before(:all) do
    @email = Faker::Internet.email
    param = {
      email: @email,
      phone: random_mobile_phone,
      password: 'qwer',
      profile_attributes: {
        name: Ryba::Name.full_name
      }
    }
    users.user_registration(param).request.perform
    auth.auth(@email, 'qwer')
    @user_id ||= Token.token['user_id']
  end

  shared_examples 'data availability' do |role, show|
    before(:all) { auth.auth_as(role) }

    context 'api/v1/users/{user_id}' do
      before(:all) do
        @res_by_user_id = users.users(@user_id).signed_request.perform
      end

      it 'response code 200' do
        expect(@res_by_user_id.code).to eql(200)
      end

      it "show_email?=#{show}" do
        expect(@res_by_user_id.parse_body['user']['email'].include?('*'))
          .to be(!show)
      end

      it "show_phone?=#{show}" do
        expect(@res_by_user_id.parse_body['user']['phone'].include?('*'))
          .to be(!show)
      end

      it "show_profile[contacts]?=#{show}" do
        expect(
          @res_by_user_id.parse_body['user']['profile']['contacts'].include?('*')
        ).to be(!show)
      end
    end

    context 'api/v1/users?email={email}' do
      before(:all) do
        @res_by_email = users.user_info(email: @email).signed_request.perform
      end

      it 'response code 200' do
        expect(@res_by_email.code).to eql(200)
      end

      it "show_email?=#{show}" do
        expect(@res_by_email.parse_body['users'][0]['email'].include?('*'))
          .to be(!show)
      end

      it "show_phone?=#{show}" do
        expect(@res_by_email.parse_body['users'][0]['phone'].include?('*'))
          .to be(!show)
      end

      it "show_profile[contacts]?=#{show}" do
        expect(
          @res_by_email.parse_body['users'][0]['profile']['contacts'].include?('*')
        ).to be(!show)
      end
    end
  end

  context 'Владельцем' do
    include_examples 'data availability', 'incorrect', true
  end

  context 'Сторонним пользователем' do
    include_examples 'data availability', 'user', false
    context 'когда владелец разрешил просмотр данных' do
      before(:all) do
        auth.auth(@email, 'qwer')
        param = {profile_attributes: {show_email: true}}
        users.user_update(param).signed_request.perform.parse_body['user']
        auth.log_out
      end

      include_examples 'data availability', 'user', true

      after(:all) do
        auth.auth(@email, 'qwer')
        param = {profile_attributes: {show_email: false}}
        users.user_update(param).signed_request.perform.parse_body['user']
        auth.log_out
      end
    end
  end

  context 'Админом' do
    include_examples 'data availability', 'company', true
  end

  context 'Неавторизованнм пользователем' do
    before(:all) do
      auth.auth_as('user')
      @res_by_user_id = users.users(@user_id).request.perform
      @res_by_email = users.user_info(email: @email).request.perform
    end

    it '/{user_id} 403' do
      expect(@res_by_user_id.code).to eql(403)
    end

    it '?email={email} 200' do
      expect(@res_by_email.code).to eql(200)
    end

    it '?email={email} show_email?=false' do
      expect(@res_by_email.parse_body['users'][0]['email'])
        .to include('*')
    end
  end
end
