include Authorization

auth = AuthNewApi.new
users = Users.new

describe 'Просмотр пользовательских данных GET(/users)' do
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
    users.user_registration(param).request
    auth.auth(@email, 'qwer')
    @user_id ||= Tokens.user_id
  end

  shared_examples 'data availability' do |role, show|
    before(:all) { auth.auth_as(role) }

    context 'api/v1/users/{user_id}' do
      let(:res_by_user_id) { users.users(@user_id).request }

      it 'response code 200' do
        expect(res_by_user_id.code).to eql(200)
      end

      it "show_email?=#{show}" do
        expect(res_by_user_id.parse_body['user']['email'].include?('*'))
          .to be(!show)
      end

      it "show_phone?=#{show}" do
        expect(res_by_user_id.parse_body['user']['phone'].include?('*'))
          .to be(!show)
      end

      it "show_profile[contacts]?=#{show}" do
        expect(
          res_by_user_id.parse_body['user']['profile']['contacts'].include?('*')
        ).to be(!show)
      end
    end

    context 'api/v1/users?email={email}' do
      let(:res_by_email) { users.user_info(email: @email).request }

      it 'response code 200' do
        expect(res_by_email.code).to eql(200)
      end

      it "show_email?=#{show}" do
        expect(res_by_email.parse_body['users'][0]['email'].include?('*'))
          .to be(!show)
      end

      it "show_phone?=#{show}" do
        expect(res_by_email.parse_body['users'][0]['phone'].include?('*'))
          .to be(!show)
      end

      it "show_profile[contacts]?=#{show}" do
        expect(
          res_by_email.parse_body['users'][0]['profile']['contacts'].include?('*')
        ).to be(!show)
      end
    end

    after(:all) { auth.log_out }
  end

  context 'когда владелец' do
    include_examples 'data availability', 'incorrect', true
  end

  context 'когда сторонний пользователь' do
    include_examples 'data availability', 'user', false
  end

  context 'когда админ' do
    include_examples 'data availability', 'company', true
  end

  context 'когда неавторизован' do
    let(:res_by_user_id) { users.users(@user_id).request(sign: false) }
    let(:res_by_email) { users.user_info(email: @email).request(sign: false) }

    it '/{user_id} 403' do
      expect(res_by_user_id.code).to eql(403)
    end

    it '?email={email} 200' do
      expect(res_by_email.code).to eql(200)
    end

    it '?email={email} show_email?=false' do
      expect(res_by_email.parse_body['users'][0]['email'])
        .to include('*')
    end
  end
end
