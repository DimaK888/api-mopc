require 'spec_helper'

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

        login[0] = '+7' if login[0] == '8'
        @login = login.delete('- ')
      end

      it 'успешно!' do
        expect(Token.token).not_to be_empty
        expect(@new_user_email.has_value?(@login)).to be(true)
      end
    end
  end

  shared_examples 'unsuccessfully post api/v1/users' do |param|
    before(:all) { @response = users.user_registration(param).request.perform }

    it 'регистрация прошла с ошибкой' do
      expect(@response.code).to eql(422)
    end

    after(:all) do
      body = @response.parse_body
      puts body['errors'] if body['errors']
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
    email = "#{auth_data[:phone].delete('- ')}@pulscen.ru"
    if email[0] == '8'
      email[0] = '7'
    elsif email[0] == '+'
      email[0] = ''
    end
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
                       }
    end

    context "Повторно зарегистрируем пользователя #{auth_data[:phone]}" do
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
                     }
  end

  after(:all) { auth.log_out }
end
