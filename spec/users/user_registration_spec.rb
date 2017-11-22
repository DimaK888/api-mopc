new_api_auth = NewApi::Authorization.new
new_api_users = NewApi::Users.new
old_api_users = OldApi::Users.new
phone = random_mobile_phone
auth_data = {
  phone: phone,
  email: "#{new_api_users.expected_phone(phone).delete('+')}@pulscen.ru",
  pswd: 'qwer'
}

describe 'Регистрация пользователя' do
  context 'Новое АПИ POST(/users)' do
    shared_examples 'successfully post api/v1/users' do |param|
      before(:all) { log_out }

      it 'регистрация прошла успешно' do
        expect(new_api_users.registration(param)).to response_code(200)
      end

      context 'авторизация прошла' do
        before(:all) do
          login = param[:email] || param[:phone]
          new_api_auth.auth(login, param[:password])

          user_id = Tokens.user_id
          @new_user_email = new_api_users.users(user_id).parse['user']

          @login = new_api_users.expected_phone(login)
        end

        it 'успешно!' do
          expect(Tokens.secret_token).not_to be_empty
          expect(@new_user_email).to have_value(@login)
        end
      end
    end

    shared_examples 'unsuccessfully post api/v1/users' do |param|
      before(:all) do
        log_out

        @response = new_api_users.registration(param)
      end

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

      context 'primary_provider is email' do
        before(:all) do
          @user_info = new_api_users.users(Tokens.user_id).parse['user']
        end

        it { expect(@user_info['primary_provider']).to eql('email') }
      end
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

        context 'primary_provider is phone' do
          before(:all) do
            @user_info = new_api_users.users(Tokens.user_id).parse['user']
          end

          it { expect(@user_info['primary_provider']).to eql('phone') }

          context 'когда добавили email' do
            before(:all) do
              new_api_users.update(email: Faker::Internet.email)
              @user_info = new_api_users.users(Tokens.user_id).parse['user']
            end

            it 'primary_provider is email' do
              expect(@user_info['primary_provider']).to eql('email')
            end
          end
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
        context 'primary_provider is email' do
          before(:all) do
            @user_info = new_api_users.users(Tokens.user_id).parse['user']
          end

          it { expect(@user_info['primary_provider']).to eql('email') }
        end
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
            @info = new_api_users.users(Tokens.user_id).parse['user']
          end

          it 'phone != profile[contacts]' do
            expect(@info['phone']).not_to eql(@info['profile']['contacts'])
          end
        end
      end

      context 'когда регистрируем по example@pulscen.ru' do
        include_examples 'unsuccessfully post api/v1/users',
                         {
                           email: "#{new_api_users.expected_phone.delete('+')}@pulscen.ru",
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
  end

  context 'Старое АПИ POST(/registration)' do
    shared_examples 'successfully post /registration' do |param|
      before(:all) do
        log_out
        @response = old_api_users.registration(param)
      end

      it { expect(@response).to response_code(200) }

      it 'message OK' do
        expect(@response.parse['status']['message']).to eql('OK')
      end

      it 'successful registration' do
        expect(@response.parse['content']['user']).not_to be_empty
      end
    end

    shared_examples 'unsuccessfully post /registration' do |param|
      before(:all) do
        log_out
        @response = old_api_users.registration(param)
      end

      it { expect(@response).to response_code(200) }

      it 'error message' do
        expect(@response.parse['status']['message']).not_to eql('OK')
      end

      it 'unsuccessful registration' do
        expect(@response.parse['content']).to be_nil
      end
    end

    context 'когда ввел все верно' do
      include_examples 'successfully post /registration',
                       {}
    end

    context 'когда пользователь существует' do
      include_examples 'unsuccessfully post /registration',
                       { email: CREDENTIALS['company']['email'] }
    end

    context 'когда email' do
      context 'неправильный' do
        include_examples 'unsuccessfully post /registration',
                         { email: CREDENTIALS['incorrect']['email'] }
      end

      context 'phone@pulscen.ru' do
        include_examples 'unsuccessfully post /registration',
                         {
                           email: "#{new_api_users.expected_phone.delete('+')}@pulscen.ru"
                         }
      end
    end

    context 'когда password' do
      context 'короткий' do
        include_examples 'unsuccessfully post /registration',
                         { password: 'qwe' }
      end

      context 'не равен password_confirmation' do
        include_examples 'successfully post /registration',
                         {
                           password: 'qwer',
                           password_confirmation: 'qwerty'
                         }
      end
    end

    context 'когда fio' do
      context 'не заполнено' do
        include_examples 'unsuccessfully post /registration',
                         { fio: '' }
      end

      context 'содержит английские буквы' do
        include_examples 'successfully post /registration',
                         { fio: Faker::Name.name }
      end

      context 'содержит иные символы (!"№%:,.;()_+=")' do
        include_examples 'unsuccessfully post /registration',
                         { fio: '!"№%:,.;()_+="' }
      end
    end
  end

  after(:all) { log_out }
end
