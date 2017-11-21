require 'rspec'
require 'allure-rspec'
require 'rest-client'
require 'json'
require 'api-auth'
require 'faker'
require 'ryba'
require 'yaml'
require 'securerandom'

Dir['**/spec/helpers/*.rb'].each { |file| require file[5..-1] }
Dir['**/lib/**/*.rb'].each { |file| require file[4..-1] }

include ApiClient
include ApplicationHelper

::CREDENTIALS = YAML.safe_load(File.read('lib/configs/credentials.yml'))
::URL = YAML.safe_load(File.read('lib/configs/env.yml'))['url']

RSpec.configure do |config|
  config.include AllureRSpec::Adaptor
  config.formatter = 'doc'
  config.color = true
  config.tty = true
  config.example_status_persistence_file_path = 'examples.txt'
  config.expect_with :rspec
  config.raise_errors_for_deprecations!
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

# RestClient.proxy = 'http://127.0.0.1:8888'

AllureRSpec.configure do |config|
  config.output_dir = 'allure'
  config.clean_dir = false
  config.logging_level = Logger::INFO
end
