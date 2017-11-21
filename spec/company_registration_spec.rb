old_api_auth = OldApi::Authorization.new
old_api_company = OldApi::Companies.new

describe 'Регистрация компании' do
  context 'Старое АПИ POST(/company/registration)' do
    shared_examples 'add_company' do |params, create|
      before(:all) do
        @count = old_api_company.company_list.size
        old_api_company.registration(params)
      end

      it "registered a company? => #{create}" do
        expect(old_api_company.company_list.size == (@count + 1)).to be(create)
      end
    end

    context 'Создадим пользователя с компанией' do
      before(:all) do
        log_out
        email = Faker::Internet.email
        old_api_auth.auth_as_new_user(email: email)
      end

      include_context 'add_company',
                      {}, true

      context 'когда добавил вторую компанию' do
        include_context 'add_company',
                        {}, true
      end

      context 'когда не указал ОПФ' do
        include_context 'add_company',
                        { name_rest: '' }, true
      end

      context 'когда не указал название компании' do
        include_context 'add_company',
                        { name: '' }, false
      end

      context 'когда не указал город' do
        include_context 'add_company',
                        { city_id: '' }, false
      end

      context 'когда не указал номер' do
        include_context 'add_company',
                        { code: '', number: '' }, false
      end
    end

    context 'Привязка компании' do
      before(:all) do
        log_out

        old_api_auth.auth_as_new_user

        @phone_number = { code: '343', number: ('#' * 7).number_generator }
        old_api_company.registration(@phone_number)
      end

      context 'когда владелец' do
        before(:all) do
          @relevant_company = old_api_company.
            registration(@phone_number).
            parse['content']['relevant_companies'][0]
        end

        it 'relevant_companies not empty' do
          expect(@relevant_company).not_to be_empty
        end

        context 'создадим заявку на привязку' do
          before(:all) do
            @company_request = old_api_company.
              company_request(company_id: @relevant_company['id']).
              parse['status']
          end

          it 'status[code] 400' do
            expect(@company_request['code']).to eql(400)
          end

          it 'ошибка: Пользователь уже привязан к компании' do
            expect(@company_request['message']).not_to eql('OK')
          end
        end
      end

      context 'когда сторонний пользователь' do
        before(:all) do
          log_out

          old_api_auth.auth_as_new_user

          @relevant_company = old_api_company.
            registration(@phone_number).
            parse['content']['relevant_companies'][0]
        end

        it 'relevant_companies not empty' do
          expect(@relevant_company).not_to be_empty
        end

        context 'создадим заявку на привязку' do
          before(:all) do
            @company_request = old_api_company.
              company_request(company_id: @relevant_company['id']).
              parse['status']
          end

          it 'запрос на привязку создан' do
            expect(@company_request['message']).to eql('OK')
          end
        end
      end
    end
  end
end
