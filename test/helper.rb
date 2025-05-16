require 'minitest/autorun'
require 'minitest-spec-context'
require 'minitest/spec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../fixtures/vcr_cassettes', __FILE__)
  config.hook_into :webmock

  config.filter_sensitive_data('<API_KEY>'){ENV['BITGET_API_KEY']}
  config.filter_sensitive_data('<API_SECRET>'){ENV['BITGET_API_SECRET'] }
  config.filter_sensitive_data('<API_PASSPHRASE>'){ENV['BITGET_API_PASSPHRASE']}
end
