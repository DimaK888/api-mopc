auth = AuthNewApi.new
users = Users.new
phone = random_mobile_phone
auth_data = {
  phone: phone,
  email: "#{users.expected_phone(phone).delete('+')}@pulscen.ru",
  pswd: 'qwer'
}

describe 'Регистрация пользователя POST(/users)' do
  shared_examples 'successfully post api/v1/users' do |param|
    it 'регистрация прошла успешно' do
      expect(
        users.user_registration(param).request(sign: false)
      ).to response_code(200)
    end

    context 'авторизация прошла' do
      before(:all) do
        log_out
        login = param[:email] || param[:phone]
        auth.auth(login, param[:password])

        user_id = Tokens.user_id
        @new_user_email = users.users(user_id).
          request.parse_body['user']

        @login = users.expected_phone(login)
      end

      it 'успешно!' do
        expect(Tokens.secret_token).not_to be_empty
        expect(@new_user_email).to have_value(@login)
      end
    end
  end

  shared_examples 'unsuccessfully post api/v1/users' do |param|
    before(:all) { @response = users.user_registration(param).request(sign: false) }

    it 'регистрация прошла с ошибкой' do
      expect(@response).to response_code(422)
    end
  end

  context 'когда регистрируем по email' do
    include_examples 'successfully post api/v1/users',
                     {
                       email: Faker::Internet.email,
                       password: 'qwer',
                       profile_attributes: {
                         name: Ryba::Name.full_name
                       }
                     }
  end

  context 'когда регистрируем по телефону' do
    context 'без указания поля contacts' do
      include_examples 'successfully post api/v1/users',
                       {
                         phone: auth_data[:phone],
                         password: auth_data[:pswd],
                         profile_attributes: {
                           name: Ryba::Name.full_name
                         }
                       }
    end

    context 'с полями phone & profile[contacts]' do
      include_examples 'successfully post api/v1/users',
                       {
                         phone: random_mobile_phone,
                         password: 'qwer',
                         profile_attributes: {
                           name: Ryba::Name.full_name,
                           contacts: random_mobile_phone
                         }
                       }
      context 'Получим информацию о пользователе' do
        before(:all) do
          @info = users.users(Tokens.user_id).request.parse_body['user']
        end

        it 'phone != profile[contacts]' do
          expect(@info['phone']).not_to eql(@info['profile']['contacts'])
        end
      end
    end

    context 'когда регистрируем по example@pulscen.ru' do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                         email: "#{users.expected_phone.delete('+')}@pulscen.ru",
                         password: 'qwer',
                         profile_attributes: {
                             name: Ryba::Name.full_name
                         }
                       }
    end

    context 'когда регистрируем по занятому example@pulscen.ru' do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                         email: auth_data[:email],
                         password: auth_data[:pswd],
                         profile_attributes: {
                           name: Ryba::Name.full_name
                         }
                       }
    end

    context "когда регистрируем по занятому телефону #{auth_data[:phone]}" do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                         phone: auth_data[:phone],
                         password: auth_data[:pswd],
                         profile_attributes: {
                           name: Ryba::Name.full_name
                         }
                       }
    end
  end

  context 'когда регистрируем с указанием email и phone' do
    include_examples 'successfully post api/v1/users',
                     {
                       email: Faker::Internet.email,
                       phone: random_mobile_phone,
                       password: 'qwer',
                       profile_attributes: {
                         name: Ryba::Name.full_name,
                         contacts: random_mobile_phone
                       }
                     }
    context 'primary_provider: email' do
      before(:all) do
        @user_info = users.users(Tokens.user_id).request.parse_body['user']
      end

      it { expect(@user_info['primary_provider']).to eql('email') }
    end
  end

  context 'когда пользователь(email) существует' do
    include_examples 'unsuccessfully post api/v1/users',
                     {
                       email: CREDENTIALS['company']['email'],
                       password: 'qwer',
                       profile_attributes: {
                           name: Ryba::Name.full_name
                       }
                     }
  end

  context 'когда регистрируем без указания имени' do
    context 'только email & password' do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                         email: Faker::Internet.email,
                         password: 'qwer'
                       }
    end

    context 'только phone & password' do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                         phone: random_mobile_phone,
                         password: 'qwer'
                       }
    end
  end

  context 'когда ничего не передаем' do
    include_examples 'unsuccessfully post api/v1/users',
                     {}
  end

  after(:all) { log_out }
end
