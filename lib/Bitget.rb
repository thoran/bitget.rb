# Bitget.rb
# Bitget

# 20250207, 08, 09
# 0.0.0

require_relative 'Hash/to_parameter_string'
gem 'http.rb'; require 'http.rb'
require 'json'
require 'openssl'

module Bitget
  module V2
    class Client
      API_HOST = 'api.bitget.com'

      class << self
        def path_prefix
          '/api/v2'
        end
      end # class << self

      def spot_public_coins(
        coin: nil
      )
        get(
          path: '/spot/public/coins',
          args: {
            coin: coin
          }
        )
      end

      private

      def initialize(api_key:, api_secret:, api_passphrase:)
        @api_key = api_key.encode('UTF-8')
        @api_secret = api_secret.encode('UTF-8')
        @api_passphrase = api_passphrase.encode('UTF-8')
      end

      def full_path(path)
        self.class.path_prefix + path
      end

      def encoded_payload(args)
        args.reject!{|k,v| v.nil?}
        OpenSSL::Digest::SHA512.hexdigest(JSON.dump(args))
      end

      def timestamp
        @timestamp ||= Time.now.to_i.to_s
      end

      def message(verb:, path:, args:)
        query_string = (
          case verb
          when 'GET'
            args.to_parameter_string
          when 'POST'
            nil
          else
            raise "The verb, #{verb}, is not acceptable."
          end
        )
        body = JSON.dump(args)
        if query_string.nil?
          [timestamp, verb, full_path(path), body].join
        else
          [timestamp, verb, full_path(path), '?', query_string, body].join
        end
      end

      def signature(message)
        OpenSSL::HMAC.hexdigest('SHA512', @api_secret, message)
      end

      def request_string(path)
        "https://#{API_HOST}#{self.class.path_prefix}#{path}"
      end

      def headers(signature)
        {
          'ACCESS-KEY' => @api_key,
          'ACCESS-SIGN' => signature,
          'ACCESS-TIMESTAMP' => timestamp,
          'ACCESS-PASSPHRASE' => @api_passphrase,
          'Content-type' => 'application/json',
          'locale' =>'en-AU',
          'Accept' => 'application/json',
        }
      end

      def do_request(verb:, path:, args: {})
        message = message(verb: verb, path: path, args: args)
        signature = signature(message)
        response = HTTP.send(verb.to_s.downcase, request_string(path), args, headers(signature))
        JSON.parse(response.body)
      end

      def get(path:, args: {})
        do_request(verb: 'GET', path: path, args: args)
      end

      def post(path:, args: {})
        do_request(verb: 'POST', path: path, args: args)
      end
    end
  end

  class Client < Bitget::V2::Client; end
end
