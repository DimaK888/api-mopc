include Authorization

auth = AuthNewApi.new
users = Users.new

describe 'Регистрация пользователя api/v1/users' do
  shared_examples 'successfully post api/v1/users' do |param|
    it 'регистрация прошла успешно' do
      expect(
        users.user_registration(param).
          request.perform.code
      ).to be(200)
    end

    context 'Авторизация нового пользователя' do
      before(:all) do
        auth.log_out
        login = param[:email] || param[:phone]
        auth.auth(login, param[:password])

        user_id = Token.token['user_id']
        @new_user_email = users.users(user_id).
          signed_request.perform.
          parse_body['user']

        @login = users.expected_phone(login)
      end

      it 'успешно!' do
        expect(Token.token).not_to be_empty
        expect(@new_user_email).to have_value(@login)
      end
    end
  end

  shared_examples 'unsuccessfully post api/v1/users' do |param, error|
    before(:all) { @response = users.user_registration(param).request.perform }

    it 'регистрация прошла с ошибкой' do
      expect(@response.code).to eql(422)
    end

    it 'текст ошибки соответсвует ожиданиям' do
      expect(@response.parse_body['errors'][0]). to include(error)
    end
  end

  context 'Зарегистрация пользователя по email' do
    include_examples 'successfully post api/v1/users',
                     {
                       email: Faker::Internet.email,
                       password: 'qwer',
                       profile_attributes: {
                         name: Ryba::Name.full_name
                       }
                     }
  end

  context 'Зарегистрация пользователя по телефону' do
    auth_data = {phone: random_mobile_phone, pswd: 'qwer'}
    email = "#{users.expected_phone(auth_data[:phone]).delete('+')}@pulscen.ru"
    context "#{auth_data[:phone]} без поля contacts" do
      include_examples 'successfully post api/v1/users',
                       {
                         phone: auth_data[:phone],
                         password: auth_data[:pswd],
                         profile_attributes: {
                           name: Ryba::Name.full_name
                         }
                       }
    end

    context 'вводим поля phone & profile[contacts]' do
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
          @info = users.users(Token.token['user_id']).
            signed_request.perform.parse_body['user']
        end

        it 'phone != profile[contacts]' do
          expect(@info['phone']).not_to eql(@info['profile']['contacts'])
        end
      end
    end

    context "Зарегистрируем пользователя #{email}" do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                         email: email,
                         password: auth_data[:pswd],
                         profile_attributes: {
                           name: Ryba::Name.full_name
                         }
                       }, {'email' => 'уже занят'}
    end

    context "Повторно зарегистрируем пользователя #{auth_data[:phone]}" do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                         phone: auth_data[:phone],
                         password: auth_data[:pswd],
                         profile_attributes: {
                           name: Ryba::Name.full_name
                         }
                       }, {'phone' => 'уже занят'}
    end
  end

  context 'Зарегистрация пользователя по email' do
    include_examples 'successfully post api/v1/users',
                     {
                       email: Faker::Internet.email,
                       password: 'qwer',
                       profile_attributes: {
                         name: Ryba::Name.full_name
                       }
                     }
  end

  context 'Регистрация пользователя (email & phone)' do
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
  end

  context 'Регистрация существующего пользователя (email)' do
    include_examples 'unsuccessfully post api/v1/users',
                     {
                       email: CREDENTIALS['company']['email'],
                       password: 'qwer',
                       profile_attributes: {
                         name: Ryba::Name.full_name
                       }
                     }, {'email' => 'уже занят'}
  end

  context 'Регистрация по паре логин/пароль' do
    context 'Передаем только email & password' do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                         email: Faker::Internet.email,
                         password: 'qwer'
                       }, {'profile.name'=>'ФИО может содержать только буквы, точки и дефисы'}
    end

    context 'Передаем только phone & password' do
      include_examples 'unsuccessfully post api/v1/users',
                       {
                           phone: random_mobile_phone,
                           password: 'qwer'
                       }, {'profile.name'=>'ФИО может содержать только буквы, точки и дефисы'}
    end
  end

  context 'Ничего не передаем' do
    include_examples 'unsuccessfully post api/v1/users',
                     {},
                     {
                       'email'=>'Неправильный email',
                       'primary_provider'=>'не может быть пустым',
                       'profile.name'=>'ФИО может содержать только буквы, точки и дефисы',
                       'password'=>'Пароль слишком короткий'
                     }
  end

  after(:all) { auth.log_out }
end
