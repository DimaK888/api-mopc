auth = AuthNewApi.new
regions = Regions.new

describe 'Список регионов' do
  context 'Доступ' do
    context 'когда не авторизован' do
      it { expect(regions.countries).to response_code(200) }
    end

    context 'когда авторизован' do
      before { auth.auth_as('user') }

      it { expect(regions.countries).to response_code(200) }

      after { log_out }
    end
  end

  context 'Выбор случайного города' do
    let (:city) do
      country_id = regions.countries_list.sample['id']
      province_id = regions.provinces_list(country_id).sample['id']
      regions.cities_list(province_id).sample['id']
    end

    it 'successfully' do
      expect(city).not_to be_nil
    end
  end

  it 'Определение местоположения по ip' do
    expect(regions.city_by_ip).not_to be_empty
  end
end