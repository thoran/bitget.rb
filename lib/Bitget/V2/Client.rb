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
      # GET /api/v2/spot/public/coins
      def spot_public_coins(coin: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/public/coins',
          args: {
            coin: coin,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Symbol Info
      # GET /api/v2/spot/public/symbols
      def spot_public_symbols(symbol: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/public/symbols',
          args: {
            symbol: symbol,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get VIP Fee Rate
      # GET /api/v2/spot/market/vip-fee-rate
      def spot_market_vip_free_rate(request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/market/vip-fee-rate',
          args: {
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Ticker Information
      # GET /api/v2/spot/market/tickers
      def spot_market_tickers(symbol: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/market/tickers',
          args: {
            symbol: symbol,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Merge Depth
      # GET /api/v2/spot/market/merge-depth
      def spot_market_merge_depth(symbol:, precision: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/market/merge-depth',
          args: {
            symbol: symbol,
            precision: precision,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get OrderBook Depth
      # GET /api/v2/spot/market/orderbook
      def spot_market_orderbook(symbol:, type: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/market/orderbook',
          args: {
            symbol: symbol,
            type: type,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Candlestick Data
      # GET /api/v2/spot/market/candles
      def spot_market_candles(symbol:, granularity:, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/market/candles',
          args: {
            symbol: symbol,
            granularity: granularity,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get History Candlestick Data
      # GET /api/v2/spot/market/history-candles
      def spot_market_history_candles(symbol:, granularity:, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/market/history-candles',
          args: {
            symbol: symbol,
            granularity: granularity,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Recent Trades
      # GET /api/v2/spot/market/fills
      def spot_market_fills(symbol:, limit: nil)
        response = get(path: '/spot/market/fills', args: {symbol: symbol, limit: limit})
        handle_response(response)
      end

      # Get Market Trades
      # GET /api/v2/spot/market/fills-history
      def spot_market_fills_history(symbol:, limit: nil, id_less_than: nil, start_time: nil, end_time: nil)
        response = get(
          path: '/spot/market/fills-history',
          args: {
            symbol: symbol,
            limit: limit,
            idLessThan: id_less_than,
            startTime: start_time,
            endTime: end_time
          }
        )
        handle_response(response)
      end

      # Trade

      # Place Order
      # POST /api/v2/spot/trade/place-order
      def spot_trade_place_order(
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
          path: '/spot/trade/place-order',
          args: {
            symbol: symbol,
            side: side,
            orderType: order_type,
            force: force,
            price: price,
            size: size,
            clientOid: client_order_id,
            triggerPrice: trigger_price,
            tpslType: tpsl_type,
            requestTime: request_time,
            receiveWindow: receive_window,
            stpMode: stp_mode,
            presetTakeProfitPrice: preset_take_profit_price,
            executeTakeProfitPrice: execute_take_profit_price,
            presetStopLossPrice: preset_stop_loss_price,
            executeStopLossPrice: execute_stop_loss_price,
          }
        )
        handle_response(response)
      end

      # Cancel an Existing Order and Send a New Order
      # POST /api/v2/spot/trade/cancel-replace-order
      def spot_trade_cancel_replace_order(
        symbol:,
        price:,
        size:,
        client_order_id: nil,
        order_id: nil,
        new_client_order_id: nil,
        preset_take_profit_price: nil,
        execute_take_profit_price: nil,
        preset_stop_loss_price: nil,
        execute_stop_loss_price: nil,
        request_time: nil,
        receive_window: nil
      )
        response = post(
          path: '/spot/trade/cancel-replace-order',
          args: {
            symbol: symbol,
            price: price,
            size: size,
            clientOid: client_order_id,
            orderId: order_id,
            newClientOid: new_client_order_id,
            presetTakeProfitPrice: preset_take_profit_price,
            executeTakeProfitPrice: execute_take_profit_price,
            presetStopLossPrice: preset_stop_loss_price,
            executeStopLossPrice: execute_stop_loss_price,
            requestTime: request_time,
            receiveWindow: receive_window,
          }
        )
        handle_response(response)
      end

      # Batch Cancel Existing Order and Send New Orders
      # POST /api/v2/spot/trade/batch-cancel-replace-order
      def spot_trade_batch_cancel_replace_order(orders:)
        response = post(
          path: '/spot/trade/batch-cancel-replace-order',
          args: {orders: orders}
        )
        handle_response(response)
      end

      # Cancel Order
      # POST /api/v2/spot/trade/cancel-order
      def spot_trade_cancel_order(symbol:, order_id: nil, client_order_id: nil, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/trade/cancel-order',
          args: {
            symbol: symbol,
            orderId: order_id,
            clientOrderId: client_order_id,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Batch Place Orders
      # POST /api/v2/spot/trade/batch-orders
      def spot_trade_batch_orders(orders:, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/trade/batch-orders',
          args: {
            orders: orders,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Batch Cancel Orders
      # POST /api/v2/spot/trade/batch-cancel-order
      def spot_trade_batch_cancel_order(symbol:, order_ids: nil, client_order_ids: nil, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/trade/batch-cancel-order',
          args: {
            symbol: symbol,
            orderIds: order_ids,
            clientOrderIds: client_order_ids,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Cancel Order by Symbol
      # POST /api/v2/spot/trade/cancel-symbol-order
      def spot_trade_cancel_symbol_order(symbol:, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/trade/cancel-symbol-order',
          args: {
            symbol: symbol,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Order Info
      # GET /api/v2/spot/trade/orderInfo
      def spot_trade_order_info(symbol:, order_id: nil, client_order_id: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/trade/order-info',
          args: {
            symbol: symbol,
            orderId: order_id,
            clientOrderId: client_order_id,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Current Orders
      # GET /api/v2/spot/trade/unfilled-orders
      def spot_trade_unfilled_orders(symbol:, order_type: nil, side: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/trade/unfilled-orders',
          args: {
            symbol: symbol,
            orderType: order_type,
            side: side,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get History Orders
      # GET /api/v2/spot/trade/history-orders
      def spot_trade_history_orders(symbol:, order_type: nil, side: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/trade/history-orders',
          args: {
            symbol: symbol,
            orderType: order_type,
            side: side,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Fills
      # GET /api/v2/spot/trade/fills
      def spot_trade_fills(symbol:, order_id: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/trade/fills',
          args: {
            symbol: symbol,
            orderId: order_id,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Trigger

      # Place Plan Order
      # POST /api/v2/spot/trade/place-plan-order
      def spot_trade_place_plan_order(symbol:, side:, order_type:, size:, trigger_price:, execute_price: nil, trigger_type: nil, time_in_force: nil, client_order_id: nil)
        response = post(
          path: '/spot/trade/place-plan-order',
          args: {
            symbol: symbol,
            side: side,
            orderType: order_type,
            size: size,
            triggerPrice: trigger_price,
            executePrice: execute_price,
            triggerType: trigger_type,
            timeInForce: time_in_force,
            clientOrderId: client_order_id
          }
        )
        handle_response(response)
      end

      # Modify Plan Order
      # POST /api/v2/spot/trade/modify-plan-order
      def spot_trade_modify_plan_order(order_id:, trigger_price: nil, execute_price: nil, size: nil)
        response = post(
          path: '/spot/trade/modify-plan-order',
          args: {
            orderId: order_id,
            triggerPrice: trigger_price,
            executePrice: execute_price,
            size: size
          }
        )
        handle_response(response)
      end

      # Cancel Plan Order
      # POST /api/v2/spot/trade/cancel-plan-order
      def spot_trade_cancel_plan_order(order_id:)
        response = post(
          path: '/spot/trade/cancel-plan-order',
          args: {orderId: order_id}
        )
        handle_response(response)
      end

      # Get Current Plan Orders
      # GET /api/v2/spot/trade/current-plan-order
      def spot_trade_current_plan_order(symbol:, order_type: nil, side: nil, start_time: nil, end_time: nil, limit: nil)
        response = get(
          path: '/spot/trade/current-plan-order',
          args: {
            symbol: symbol,
            orderType: order_type,
            side: side,
            startTime: start_time,
            endTime: end_time,
            limit: limit
          }
        )
        handle_response(response)
      end

      # Get Plan Sub Order
      # GET /api/v2/spot/trade/plan-sub-order
      def spot_trade_plan_sub_order(order_id:)
        response = get(
          path: '/spot/trade/plan-sub-order',
          args: {orderId: order_id}
        )
        handle_response(response)
      end

      # Get History Plan Orders
      # GET /api/v2/spot/trade/history-plan-order
      def spot_trade_history_plan_order(symbol:, order_type: nil, side: nil, start_time: nil, end_time: nil, limit: nil)
        response = get(
          path: '/spot/trade/history-plan-order',
          args: {
            symbol: symbol,
            orderType: order_type,
            side: side,
            startTime: start_time,
            endTime: end_time,
            limit: limit
          }
        )
        handle_response(response)
      end

      # Cancel Plan Orders in Batch
      # POST /api/v2/spot/trade/batch-cancel-plan-order
      def spot_trade_batch_cancel_plan_order(symbol:, order_ids:)
        response = post(
          path: '/spot/trade/batch-cancel-plan-order',
          args: {symbol: symbol, orderIds: order_ids}
        )
        handle_response(response)
      end

      # Account

      # Get Account Information
      # GET /api/v2/spot/account/info
      def spot_account_info(request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/account/info',
          args: {
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Account Assets
      # GET /api/v2/spot/account/assets
      def spot_account_assets(coin: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/account/assets',
          args: {
            coin: coin,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Sub-accounts Assets
      # GET /api/v2/spot/account/subaccount-assets
      def spot_account_subaccount_assets(subaccount_id:, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/account/subaccount-assets',
          args: {
            subaccountId: subaccount_id,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Modify Deposit Account
      # POST /api/v2/spot/wallet/modify-deposit-account
      def spot_wallet_modify_deposit_account(coin:, chain:, address:, tag: nil, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/wallet/modify-deposit-account',
          args: {
            coin: coin,
            chain: chain,
            address: address,
            tag: tag,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Account Bills
      # GET /api/v2/spot/account/bills
      def spot_account_bills(coin: nil, group: nil, business_type: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/account/bills',
          args: {
            coin: coin,
            group: group,
            businessType: business_type,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Transfer
      # POST /api/v2/spot/wallet/transfer
      def spot_wallet_transfer(from_account:, to_account:, coin:, amount:, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/wallet/transfer',
          args: {
            fromAccount: from_account,
            toAccount: to_account,
            coin: coin,
            amount: amount,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # GET Transferable Coin List
      # GET /api/v2/spot/wallet/transfer-coin-info
      def spot_wallet_transfer_coin_info(from_account:, to_account:, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/wallet/transfer-coin-info',
          args: {
            fromAccount: from_account,
            toAccount: to_account,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Sub Transfer
      # POST /api/v2/spot/wallet/subaccount-transfer
      def spot_wallet_subaccount_transfer(subaccount_id:, coin:, amount:, direction:, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/wallet/subaccount-transfer',
          args: {
            subaccountId: subaccount_id,
            coin: coin,
            amount: amount,
            direction: direction,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Withdraw
      # POST /api/v2/spot/wallet/withdrawal
      def spot_wallet_withdrawal(coin:, chain:, address:, amount:, tag: nil, remark: nil, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/wallet/withdrawal',
          args: {
            coin: coin,
            chain: chain,
            address: address,
            amount: amount,
            tag: tag,
            remark: remark,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get MainSub Transfer Record
      # GET /api/v2/spot/account/sub-main-trans-record
      def spot_account_sub_main_trans_record(subaccount_id: nil, coin: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/account/sub-main-trans-record',
          args: {
            subaccountId: subaccount_id,
            coin: coin,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Transfer Record
      # GET /api/v2/spot/account/transferRecords
      def spot_account_transfer_records(coin: nil, from_type: nil, to_type: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/account/transferRecords',
          args: {
            coin: coin,
            fromType: from_type,
            toType: to_type,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Switch BGB Deduct
      # POST /api/v2/spot/account/switch-deduct
      def spot_account_switch_deduct(deduct:, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/account/switch-deduct',
          args: {
            deduct: deduct,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Deposit Address
      # GET /api/v2/spot/wallet/deposit-address
      def spot_wallet_deposit_address(coin:, chain: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/wallet/deposit-address',
          args: {
            coin: coin,
            chain: chain,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get SubAccount Deposit Address
      # GET /api/v2/spot/wallet/subaccount-deposit-address
      def spot_wallet_subaccount_deposit_address(subaccount_id:, coin:, chain: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/wallet/subaccount-deposit-address',
          args: {
            subaccountId: subaccount_id,
            coin: coin,
            chain: chain,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get BGB Deduct Info
      # GET /api/v2/spot/account/deduct-info
      def spot_account_deduct_info(request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/account/deduct-info',
          args: {
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Cancel Withdrawal
      # POST /api/v2/spot/wallet/cancel-withdrawal
      def spot_wallet_cancel_withdrawal(order_id:, request_time: nil, receive_window: nil)
        response = post(
          path: '/spot/wallet/cancel-withdrawal',
          args: {
            orderId: order_id,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get SubAccount Deposit Records
      # GET /api/v2/spot/wallet/subaccount-deposit-records
      def spot_wallet_subaccount_deposit_records(subaccount_id: nil, coin: nil, status: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/wallet/subaccount-deposit-records',
          args: {
            subaccountId: subaccount_id,
            coin: coin,
            status: status,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Withdrawal Records
      # GET /api/v2/spot/wallet/withdrawal-records
      def spot_wallet_withdrawal_records(coin: nil, status: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/wallet/withdrawal-records',
          args: {
            coin: coin,
            status: status,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
        handle_response(response)
      end

      # Get Deposit Records
      # GET /api/v2/spot/wallet/deposit-records
      def spot_wallet_deposit_records(coin: nil, status: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/wallet/deposit-records',
          args: {
            coin: coin,
            status: status,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
            receiveWindow: receive_window
          }
        )
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
