include Regions

auth = AuthNewApi.new
old_auth = AuthOldApi.new
new_regions = NewApiRegions.new
old_regions = OldApiRegions.new

describe 'Список регионов' do
  context 'Новое АПИ'  do
    context 'Доступ' do
      context 'когда не авторизован' do
        it { expect(new_regions.countries).to response_code(200) }
      end

      context 'когда авторизован' do
        before { auth.auth_as('user') }

        it { expect(new_regions.countries).to response_code(200) }

        after { log_out }
      end
    end

    context 'Выбор случайного города' do
      let (:city) { new_regions.random_city[:id] }

      it 'successfully' do
        expect(city).not_to be_nil
      end
    end

    it 'Определение местоположения по ip' do
      expect(new_regions.city_by_ip).not_to be_empty
    end
  end

  context 'Старое АПИ'  do
    context 'Доступ' do
      context 'когда не авторизован' do
        it { expect(old_regions.countries).to response_code(200) }
      end

      context 'когда авторизован' do
        before { old_auth.auth_as('user') }

        it { expect(old_regions.countries).to response_code(200) }

        after { log_out }
      end
    end

    context 'Выбор случайного города' do
      let (:city) { old_regions.random_city[:id] }

      it 'successfully' do
        expect(city).not_to be_nil
      end
    end
  end

  after(:all) { log_out }
end
