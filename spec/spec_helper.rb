require 'rest-client'
require 'rspec'
require 'allure-rspec'
require 'faker'
require 'ryba'
require 'yaml'

Dir['helpers/*.rb'].each { |file| require file[4..-1] }
Dir['**/lib/**/*.rb'].each { |file| require file[4..-1] }

::CREDENTIALS = YAML.safe_load(File.read('lib/configs/credentials.yml'))
::DB_CONF = YAML.safe_load(File.read('lib/configs/db_connect.yml'))
::URL = DB_CONF['host']

RSpec.configure do |config|
  config.include AllureRSpec::Adaptor
  config.formatter = 'doc'
  config.color = true
  config.tty = true
  config.example_status_persistence_file_path = 'examples.txt'
  config.expect_with :rspec
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

AllureRSpec.configure do |config|
  config.output_dir = 'allure'
  config.clean_dir = false
  config.logging_level = Logger::INFO
end