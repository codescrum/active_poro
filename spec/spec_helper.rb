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
