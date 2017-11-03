require 'spec_helper'

include ApiAccess
include Authorization

auth = AuthNewApi.new
users = Users.new
response = {}

describe 'Авторизация в новом АПИ' do
  shared_examples 'Авторизация с неверными данными' do |email, pswd|
    context 'Получим личные данные неавторизованного пользователя' do
      before(:all) { response[:users] = users.user_info("email=#{email}").request.perform }

      it 'response 200' do
        expect(response[:users].code).to eq(200)
      end

      it 'пользоватей с таким email нет' do
        expect(response[:users].parse_body['users']).to be_empty
      end
    end

    context 'Авторизация' do
      before(:all) { response[:auth] = auth.auth(email, pswd) }

      it 'response 404' do
        expect(auth.auth(email, pswd).code).to eq(404)
      end
    end

    after(:all) { response.clear }
  end

  shared_examples 'Авторизация с корректными данными' do |email, pswd|
    context 'Получим личные данные неавторизованного пользователя' do
      before(:all) do
        response[:users] = users.user_info("email=#{email}").request.perform
        user = response[:users].parse_body['users'][0]
        response[:user] = users.users(user['id']).request.perform
        response[:user_email] = user['email']
      end

      it 'response 200' do
        expect(response[:users].code).to eq(200)
      end

      it 'список пользоватей с email не пуст' do
        expect(response[:users].parse_body['users']).not_to be_empty
      end

      it 'email скрыт' do
        expect(response[:user_email]).to include('*')
      end

      it 'данные пользователя по user_id (403)' do
        expect(response[:user].code).to eq(403)
      end
    end

    context 'Авторизация' do
      before(:all) { response[:auth] = auth.auth(email, pswd) }
      it 'response 200' do
        expect(response[:auth].code).to eq(200)
      end
    end

    context 'Получим личные данные пользователя' do
      before(:all) do
        response[:users] = users.user_info("email=#{email}").request.perform
        user_id = response[:users].parse_body['users'][0]['id']
        response[:user] = users.users(user_id).signed_request.perform
      end

      it 'email читаем' do
        expect(response[:user].parse_body['user']['email']).not_to include('*')
      end

      it 'данные пользователя по user_id (200)' do
        expect(response[:user].code).to eq(200)
      end
    end

    after(:all) do
      response.clear
      auth.log_out
    end
  end

  context 'под не существующим email' do
    include_examples 'Авторизация с неверными данными',
                     CREDENTIALS['not_exists']['email'],
                     CREDENTIALS['not_exists']['pswd']
  end

  context 'под не верным email' do
    include_examples 'Авторизация с неверными данными',
                     CREDENTIALS['incorrect']['email'],
                     CREDENTIALS['incorrect']['pswd']
  end

  context 'с пустым паролем' do
    include_examples 'Авторизация с неверными данными',
                     CREDENTIALS['not_exists']['email'],
                     ''
  end

  context 'с пустым email' do
    include_examples 'Авторизация с неверными данными',
                     '',
                     CREDENTIALS['company']['pswd']
  end

  context 'с пустыми полями' do
    include_examples 'Авторизация с неверными данными',
                     '',
                     ''
  end

  context 'как компания' do
    include_examples 'Авторизация с корректными данными',
                     CREDENTIALS['company']['email'],
                     CREDENTIALS['company']['pswd']
  end

  context 'как пользователь' do
    include_examples 'Авторизация с корректными данными',
                     CREDENTIALS['user']['email'],
                     CREDENTIALS['user']['pswd']
  end
end