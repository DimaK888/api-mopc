module ApplicationHelper
  def random_mobile_phone
    formats = [
      '8-9##-###-####',
      '8-9##-###-##-##',
      '+7 9## ### ####',
      '+7 9## ## ## ###'
    ]
    formats.sample.gsub('#') { rand(10).to_s }
  end
end
