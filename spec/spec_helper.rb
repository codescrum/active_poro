# Add coverage with simple_cov and codeclimate
# These must be the first lines in the file
require 'codeclimate-test-reporter'
require 'simplecov'

formatters = [SimpleCov::Formatter::HTMLFormatter]
formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
SimpleCov.start do
  add_filter '/spec/'
end

#######################################################################

require 'rubygems'
require 'pry'

######################
require 'active_poro'#
######################

# require everything in spec/support
Dir[File.expand_path('spec/support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
