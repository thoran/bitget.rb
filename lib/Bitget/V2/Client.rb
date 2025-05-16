# Bitget/V2/Client.rb
# Bitget::V2::Client

require 'fileutils'
gem 'http.rb'; require 'http.rb'
require 'json'
require 'logger'
require 'openssl'

require_relative '../Error'
require_relative '../../Hash/to_parameter_string'
require_relative '../../Hash/x_www_form_urlencode'

module Bitget
  module V2
    class Client

      API_HOST = 'api.bitget.com'

      class << self
        attr_writer :log_file_path

        def path_prefix
          '/api/v2'
        end

        def default_log_file_path
          File.join(%w{~ log bitget log.txt})
        end

        def log_file_path
          File.expand_path(@log_file_path || default_log_file_path)
        end

        def log_file
          FileUtils.mkdir_p(File.dirname(log_file_path))
          File.open(log_file_path, File::WRONLY | File::APPEND | File::CREAT)
        end

        def logger
          @logger ||= Logger.new(log_file, 'daily')
        end
      end # class << self

      # Get Coin Info
      # GET /api/v2/spot
      def spot_public_coins(coin: nil)
        response = get(path: '/spot/public/coins', args: {coin: coin})
        handle_response(response)
      end

      # Get Account Information
      # GET /api/v2/spot/account/info
      def spot_account_info
        response = get(path: '/spot/account/info')
        handle_response(response)
      end

      # Get Account Assets
      # GET /api/v2/spot/account/assets
      def spot_account_assets(**args)
        response = get(path: '/spot/account/assets', args: args)
        handle_response(response)
      end

      private

      def initialize(api_key:, api_secret:, api_passphrase:)
        @api_key = api_key
        @api_secret = api_secret
        @api_passphrase = api_passphrase
      end

      def full_path(path)
        self.class.path_prefix + path
      end

      def encoded_payload(args)
        args.reject!{|k,v| v.nil?}
        OpenSSL::Digest::SHA512.hexdigest(JSON.dump(args))
      end

      def timestamp
        @timestamp ||= (Time.now.to_f * 1000).to_i.to_s
      end

      def message(verb:, path:, args:)
        case verb
        when 'GET'
          if args.empty?
            [timestamp, verb, full_path(path)].join
          else
            query_string = args.to_parameter_string
            [timestamp, verb, full_path(path), '?', query_string].join
          end
        when 'POST'
          body = args.to_json
          [timestamp, verb, full_path(path), body].join
        end
      end

      def signature(message)
        digest = OpenSSL::Digest.new('SHA256')
        hmac = OpenSSL::HMAC.digest(digest, @api_secret, message)
        Base64.strict_encode64(hmac)
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
          'Content-Type' => 'application/json',
          'X-CHANNEL-API-CODE' => 'spot',
        }
      end

      def log_args?(args)
        !args.values.all?(&:nil?)
      end

      def log_request(verb:, request_string:, args:)
        log_string = "#{verb} #{request_string}"
        if log_args?(args)
          log_string << "?#{args.x_www_form_urlencode}"
        end
        self.class.logger.info(log_string)
      end

      def log_error(code:, message:, body:)
        log_string = "#{code}\n#{message}\n#{body}"
        self.class.logger.error(log_string)
      end

      def do_request(verb:, path:, args: {})
        log_request(verb: verb, request_string: request_string(path), args: args)
        message = message(verb: verb, path: path, args: args)
        signature = signature(message)
        headers = headers(signature)
        @timestamp = nil
        HTTP.send(verb.to_s.downcase, request_string(path), args, headers)
      end

      def get(path:, args: {})
        do_request(verb: 'GET', path: path, args: args)
      end

      def post(path:, args: {})
        do_request(verb: 'POST', path: path, args: args)
      end

      def handle_response(response)
        if response.success?
          JSON.parse(response.body)
        else
          log_error(
            code: response.code,
            message: response.message,
            body: response.body
          )
          raise Bitget::Error.new(
            code: response.code,
            message: response.message,
            body: response.body
          )
        end
      end
    end
  end
end
