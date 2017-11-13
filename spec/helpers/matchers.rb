require 'rspec/expectations'

RSpec::Matchers.define :response_code do |expected|
  match do |actual|
    actual.code == expected
  end

  failure_message do |actual|
    "response code #{actual.code} is not equal to #{expected}"
  end
end
