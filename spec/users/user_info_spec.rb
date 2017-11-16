new_auth = AuthNewApi.new
old_auth = AuthOldApi.new
new_users = Users::NewApiUsers.new
old_users = Users::OldApiUsers.new

describe 'Просмотр пользовательских данных' do
  before(:all) do
    log_out

    @email = Faker::Internet.email
    param = {
      email: @email,
      phone: random_mobile_phone,
      password: 'qwer',
      profile_attributes: {
        name: Ryba::Name.full_name
      }
    }
    new_users.registration(param)

    new_auth.auth(@email, 'qwer')
    @user_id ||= Tokens.user_id
  end

  context 'Новое АПИ GET(/users)' do
    shared_examples 'data availability' do |role, show|
      before(:all) do
        log_out

        if role.empty?
          new_auth.auth(@email, 'qwer')
        else
          new_auth.auth_as(role)
        end
      end

      context 'api/v1/users/{user_id}' do
        let(:res_by_user_id) { new_users.users(@user_id) }

        it { expect(res_by_user_id).to response_code(200) }

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
        let(:res_by_email) { new_users.user_info(email: @email) }

        it { expect(res_by_email).to response_code(200) }

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
    end

    context 'когда владелец' do
      include_examples 'data availability', '', true
    end

    context 'когда сторонний пользователь' do
      include_examples 'data availability', 'user', false
    end

    context 'когда админ' do
      include_examples 'data availability', 'company', true
    end

    context 'когда неавторизован' do
      before(:all) { log_out }

      let(:res_by_user_id) { new_users.users(@user_id) }
      let(:res_by_email) { new_users.user_info(email: @email) }

      it '/{user_id} 403' do
        expect(res_by_user_id).to response_code(403)
      end

      it '?email={email} 200' do
        expect(res_by_email).to response_code(200)
      end

      it '?email={email} show_email?=false' do
        expect(res_by_email.parse_body['users'][0]['email'])
          .to include('*')
      end
    end
  end

  context 'Старое АПИ GET(/user_info)' do
    shared_examples 'user_info' do |role, show|
      before(:all) do
        log_out

        if role.empty?
          old_auth.auth(@email, 'qwer')
        else
          old_auth.auth_as(role)
        end
      end

      it { expect(old_users.user_info).to response_code(200) }

      it "show user info? #=> #{show}" do
        expect(old_users.user_info.parse_body['content'].nil?).not_to eql(show)
      end
    end

    context 'когда владелец' do
      include_examples 'user_info', '', true
    end

    context 'когда сторонний пользователь' do
      include_examples 'user_info', 'user', false
    end

    context 'когда админ' do
      include_examples 'user_info', 'company', true
    end

    context 'когда неавторизован' do
      include_examples 'user_info', 'incorrect', false
    end
  end

  after(:all) { log_out }
end
