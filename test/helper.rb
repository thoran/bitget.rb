require 'minitest/autorun'
require 'minitest-spec-context'
require 'minitest/spec'
require 'ostruct'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../fixtures/vcr_cassettes', __FILE__)
  config.hook_into :webmock
end

def api_key
  if ENV['BITGET_API_KEY']
    ENV['BITGET_API_KEY']
  else
    'api_key0'
  end
end

def api_secret
  if ENV['BITGET_API_SECRET']
    ENV['BITGET_API_SECRET']
  else
    'api_secret0'
  end
end

def api_passphrase
  if ENV['BITGET_API_PASSPHRASE']
    ENV['BITGET_API_PASSPHRASE']
  else
    'api_passphrase0'
  end
end
