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

      # Market

      # Get Coin Info
      # GET /api/v2/spot
      def spot_public_coins(coin: nil)
        response = get(path: '/spot/public/coins', args: {coin: coin})
        handle_response(response)
      end

      def spot_public_symbols(symbol: nil)
        response = get(path: '/spot/public/symbols', args: {symbol: symbol})
        handle_response(response)
      end

      def spot_market_vip_free_rate
        response = get(path: '/spot/market/vip-fee-rate')
        handle_response(response)
      end

      def spot_market_tickers(symbol: nil)
        response = get(path: '/spot/market/tickers', args: {symbol: symbol})
        handle_response(response)
      end

      def spot_market_merge_depth(symbol:, precision: nil, limit: nil)
        response = get(path: '/spot/market/merge-depth', args: {symbol: symbol, precision: precision, limit: limit})
        handle_response(response)
      end

      def spot_market_orderbook(symbol:, type: nil, limit: nil)
        response = get(path: '/spot/market/orderbook', args: {symbol: symbol, type: type, limit: limit})
        handle_response(response)
      end

      def spot_market_candles(symbol:, granularity:, start_time: nil, end_time: nil, limit: nil)
        response = get(
          path: '/spot/market/candles',
          args: {symbol: symbol, granularity: granularity, startTime: start_time, endTime: end_time, limit: limit}
        )
        handle_response(response)
      end

      def spot_market_history_candles(symbol:, granularity:, end_time: nil, limit: nil)
        response = get(
          path: '/spot/market/history-candles',
          args: {symbol: symbol, granularity: granularity, endTime: end_time, limit: limit}
        )
        handle_response(response)
      end

      def spot_market_fills(symbol:, limit: nil)
        response = get(path: '/spot/market/fills', args: {symbol: symbol, limit: limit})
        handle_response(response)
      end

      def spot_market_fills_history(symbol:, limit: nil, id_less_than: nil, start_time: nil, end_time: nil)
        response = get(
          path: '/spot/market/fills-history',
          args: {symbol: symbol, limit: limit, idLessThan: id_less_than, startTime: start_time, endTime: end_time}
        )
        handle_response(response)
      end

      # Trade

      def trade_place_order(
        symbol:,
        side:,
        order_type:,
        force:,
        price: nil,
        size:,
        client_order_id: nil,
        trigger_price: nil,
        tpsl_type: nil,
        request_time: nil,
        receive_window: nil,
        stp_mode: nil,
        preset_take_profit_price: nil,
        execute_take_profit_price: nil,
        preset_stop_loss_price: nil,
        execute_stop_loss_price: nil
      )
        response = post(
          path: '/trade/place-order',
          args: {
            symbol: symbol,
            side: side,
            orderType: order_type,
            force: force,
            price: price,
            size: size,
            client_order_id: clientOid,
            trigger_price: triggerPrice,
            tpsl_type: tpslType,
            request_time: requestTime,
            receive_window: receiveWindow,
            stp_mode: stpMode,
            preset_take_profit_price: presetTakeProfitPrice,
            execute_take_profit_price: executeTakeProfitPrice,
            preset_stop_loss_price: presetStopLossPrice,
            execute_stop_loss_price: executeStopLossPrice,
          }
        )
        handle_response(response)
      end

      def trade_cancel_replace_order(
        symbol:,
        price:,
        size:,
        client_order_id: nil,
        order_id: nil,
        new_client_order_id: nil,
        preset_take_profit_price: nil,
        execute_take_profit_price: nil,
        preset_stop_loss_price: nil,
        execute_stop_loss_price: nil
      )
        response = post(
          path: '/trade/cancel-replace-order',
          args: {
            symbol: symbol,
            price: price,
            size: size,
            client_order_id: clientOid,
            order_id: orderId,
            newClientOid: new_client_order_id,
            preset_take_profit_price: presetTakeProfitPrice,
            execute_take_profit_price: executeTakeProfitPrice,
            preset_stop_loss_price: presetStopLossPrice,
            execute_stop_loss_price: executeStopLossPrice,
          }
        )
        handle_response(response)
      end

      # I got lazy... (with specifying the args)

      def trade_batch_cancel_replace_order(**args)
        response = post(path: '/trade/batch-cancel-replace-order', args: args)
        handle_response(response)
      end

      def trade_cancel_order(**args)
        response = post(path: '/trade/cancel-order', args: args)
        handle_response(response)
      end

      def trade_batch_orders(**args)
        response = post(path: '/trade/batch-orders', args: args)
        handle_response(response)
      end

      def trade_batch_cancel_order
        response = post(path: '/trade/batch-cancel-order', args: args)
        handle_response(response)
      end

      def trade_cancel_symbol_order(symbol:)
        response = post(path: '/trade/cancel-symbol-order', args: {symbol: symbol})
        handle_response(response)
      end

      def trade_order_info(**args)
        response = get(path: '/trade/orderInfo', args: args)
        handle_response(response)
      end

      def trade_unfilled_orders(**args)
        response = get(path: '/trade/unfilled-orders', args: args)
        handle_response(response)
      end

      def trade_history_orders(**args)
        response = get(path: '/trade/history-orders', args: args)
        handle_response(response)
      end

      def trade_fills(**args)
        response = get(path: '/trade/fills', args: args)
        handle_response(response)
      end

      # Trigger

      # Place Plan Order
      # POST /api/v2/spot/trade/place-plan-order

      # Modify Plan Order
      # POST /api/v2/spot/trade/modify-plan-order

      # Cancel Plan Order
      # POST /api/v2/spot/trade/cancel-plan-order

      # Get Current Plan Orders
      # GET /api/v2/spot/trade/current-plan-order

      # Get Plan Sub Order
      # GET /api/v2/spot/trade/plan-sub-order

      # Get History Plan Orders
      # GET /api/v2/spot/trade/history-plan-order

      # Cancel Plan Orders in Batch
      # POST /api/v2/spot/trade/batch-cancel-plan-order

      # Account

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

      # Get Sub-accounts Assets
      # GET /api/v2/spot/account/subaccount-assets
      def spot_account_subaccount_assets(**args)
        response = get(path: '/spot/account/subaccount-assets', args: args)
        handle_response(response)
      end

      # Modify Deposit Account
      # POST /api/v2/spot/wallet/modify-deposit-account
      def spot_wallet_modify_deposit_account(**args)
        response = post(path: '/spot/wallet/modify-deposit-account', args: args)
        handle_response(response)
      end

      # Get Account Bills
      # GET /api/v2/spot/account/bills
      def spot_account_bills(**args)
        response = get(path: '/spot/account/bills', args: args)
        handle_response(response)
      end

      # Transfer
      # POST /api/v2/spot/wallet/transfer
      def spot_wallet_transfer(**args)
        response = post(path: '/spot/wallet/transfer', args: args)
        handle_response(response)
      end

      # GET Transferable Coin List
      # GET /api/v2/spot/wallet/transfer-coin-info
      def spot_wallet_transfer_coin_info(**args)
        response = get(path: '/spot/wallet/transfer-coin-info', args: args)
        handle_response(response)
      end

      # Sub Transfer
      # POST /api/v2/spot/wallet/subaccount-transfer
      def spot_wallet_subaccount_transer(**args)
        response = post(path: '/spot/wallet/subaccount-transfer', args: args)
        handle_response(response)
      end

      # Withdraw
      # POST /api/v2/spot/wallet/withdrawal
      def spot_wallet_withdrawal(**args)
        response = post(path: '/spot/wallet/withdrawal', args: args)
        handle_response(response)
      end

      # Get MainSub Transfer Record
      # GET /api/v2/spot/account/sub-main-trans-record
      def spot_account_sub_main_trans_record(**args)
        response = get(path: '/spot/account/sub-main-trans-record', args: args)
        handle_response(response)
      end

      # Get Transfer Record
      # GET /api/v2/spot/account/transferRecords
      def spot_account_transfer_records(**args)
        response = get(path: '/spot/account/transferRecords', args: args)
        handle_response(response)
      end

      # Switch BGB Deduct
      # POST /api/v2/spot/account/switch-deduct
      def spot_account_switch_deduct(deduct:)
        response = post(path: '/spot/account/switch-deduct', args: {deduct: deduct})
        handle_response(response)
      end

      # Get Deposit Address
      # GET /api/v2/spot/wallet/deposit-address
      def spot_wallet_deposit_address(**args)
        response = get(path: '/spot/wallet/deposit-address', args: args)
        handle_response(response)
      end

      # Get SubAccount Deposit Address
      # GET /api/v2/spot/wallet/subaccount-deposit-address
      def spot_wallet_subaccount_deposit_address(**args)
        response = get(path: '/spot/wallet/subaccount-deposit-address', args: args)
        handle_response(response)
      end

      # Get BGB Deduct Info
      # GET /api/v2/spot/account/deduct-info
      def spot_account_deduct_info
        response = get(path: '/spot/account/deduct-info')
        handle_response(response)
      end

      # Cancel Withdrawal
      # POST /api/v2/spot/wallet/cancel-withdrawal
      def spot_wallet_cancel_withdrawal(order_id:)
        response = post(path: '/spot/wallet/cancel-withdrawal', args: {order_id: order_id})
        handle_response(response)
      end

      # Get SubAccount Deposit Records
      # GET /api/v2/spot/wallet/subaccount-deposit-records
      def spot_wallet_subaccount_deposit_records(**args)
        response = get(path: '/spot/wallet/subaccount-deposit-records', args: args)
        handle_response(response)
      end

      # Get Withdrawal Records
      # GET /api/v2/spot/wallet/withdrawal-records
      def spot_wallet_withdrawal_records(**args)
        response = get(path: '/spot/wallet/withdrawal-records', args: args)
        handle_response(response)
      end

      # Get Deposit Records
      # GET /api/v2/spot/wallet/deposit-records
      def spot_wallet_deposit_records(**args)
        response = get(path: '/spot/wallet/deposit-records', args: args)
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
