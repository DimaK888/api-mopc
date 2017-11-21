module ApplicationHelper
  def random_mobile_phone
    formats = [
      '8-9##-###-####',
      '8-9##-###-##-##',
      '+7 9## ### ####',
      '+7 9## ## ## ###'
    ]
    formats.sample.number_generator
  end

  def number_generator
    self.gsub('#') { rand(10).to_s }
  end

  def random_name_rest
    %w(ООО ПТ ИП ОДО ОАО ЗАО ПК КФХ ГУП).sample
  end
end
