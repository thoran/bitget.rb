# Bitget/V2/Client.rb
# Bitget::V2::Client

require 'base64'
require 'fileutils'
gem 'http.rb'; require 'http.rb'
require 'json'
require 'logger'
require 'openssl'

require_relative '../Error'
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
      #
      # Rate Limit: 3 times/1s (IP)
      # Note: This endpoint retrieves information about supported cryptocurrencies
      #
      # @param coin [String] Optional. Filter by cryptocurrency code e.g. 'BTC', 'USDT'
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success, error description for failure)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of coin information:
      #     - coinId [String] Internal coin ID (e.g. '1' for BTC)
      #     - coin [String] Cryptocurrency code (e.g. 'BTC', 'USDT')
      #     - transfer [String] Whether transfers are enabled ('true'/'false')
      #     - areaCoin [String] Area coin status ('yes'/'no') - Note: Not documented in official API
      #     - chains [Array<Hash>] List of supported blockchain networks:
      #       - chain [String] Blockchain network name (e.g. 'BTC', 'BEP20', 'LIGHTNING')
      #       - needTag [String] Whether memo/tag is required ('true'/'false')
      #       - withdrawable [String] Whether withdrawals are enabled ('true'/'false')
      #       - rechargeable [String] Whether deposits are enabled ('true'/'false')
      #       - withdrawFee [String] Base withdrawal fee (e.g. '0.005')
      #       - extraWithdrawFee [String] Additional withdrawal fee (e.g. '0')
      #       - depositConfirm [String] Required confirmations for deposit (e.g. '1')
      #       - withdrawConfirm [String] Required confirmations for withdrawal (e.g. '1', '5', '15')
      #       - minDepositAmount [String] Minimum deposit amount (e.g. '0.00001')
      #       - minWithdrawAmount [String] Minimum withdrawal amount (e.g. '0.0005')
      #       - browserUrl [String] Block explorer URL (e.g. 'https://www.blockchain.com/explorer/transactions/btc/')
      #       - contractAddress [String] Token contract address if applicable (e.g. '0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c')
      #       - withdrawStep [String] Withdrawal step (e.g. '0')
      #       - withdrawMinScale [String] Withdrawal amount precision (e.g. '8')
      #       - congestion [String] Network congestion status ('normal'/'congested')
      def spot_public_coins(coin: nil)
        response = get(path: '/spot/public/coins', args: {coin: coin})
        handle_response(response)
      end

      # Get Symbol Info
      # GET /api/v2/spot/public/symbols
      #
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves information about supported trading pairs
      #
      # @param symbol [String] Optional. Filter by trading pair e.g. 'BTCUSDT'
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success, error description for failure)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of symbol information:
      #     - symbol [String] Trading pair name (e.g. 'BTCUSDT')
      #     - baseCoin [String] Base currency code (e.g. 'BTC')
      #     - quoteCoin [String] Quote currency code (e.g. 'USDT')
      #     - minTradeAmount [String] Minimum trade amount (e.g. '0')
      #     - maxTradeAmount [String] Maximum trade amount (e.g. '900000000000000000000')
      #     - takerFeeRate [String] Taker fee rate (e.g. '0.002')
      #     - makerFeeRate [String] Maker fee rate (e.g. '0.002')
      #     - pricePrecision [String] Price precision (decimal places) (e.g. '2')
      #     - quantityPrecision [String] Quantity precision (decimal places) (e.g. '6')
      #     - quotePrecision [String] Quote precision (decimal places) (e.g. '8')
      #     - status [String] Trading pair status (e.g. 'online')
      #     - minTradeUSDT [String] Minimum trade amount in USDT (e.g. '1')
      #     - buyLimitPriceRatio [String] Maximum buy price ratio (e.g. '0.05')
      #     - sellLimitPriceRatio [String] Maximum sell price ratio (e.g. '0.05')
      #     - areaSymbol [String] Area symbol status ('yes'/'no')
      #     - orderQuantity [String] Maximum order quantity (e.g. '200')
      #     - openTime [String] Trading pair open time in milliseconds (e.g. '1532454360000')
      #     - offTime [String] Trading pair off time in milliseconds (empty if active)
      def spot_public_symbols(symbol: nil)
        response = get(path: '/spot/public/symbols', args: {symbol: symbol})
        handle_response(response)
      end

      # Get VIP Fee Rate
      # GET /api/v2/spot/market/vip-fee-rate
      #
      # Rate Limit: 10 times/1s (IP)
      # Note: This endpoint retrieves the current VIP fee rates for the user
      #
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success, error description for failure)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of VIP level information:
      #     - level [Integer] VIP level (e.g. 1)
      #     - dealAmount [String] Trading volume requirement (e.g. '1000000')
      #     - assetAmount [String] Asset requirement (e.g. '50000')
      #     - takerFeeRate [String] Taker fee rate (e.g. '0')
      #     - makerFeeRate [String] Maker fee rate (e.g. '0')
      #     - btcWithdrawAmount [String] BTC withdrawal limit (e.g. '300')
      #     - usdtWithdrawAmount [String] USDT withdrawal limit (e.g. '5000000')
      def spot_market_vip_fee_rate
        response = get(path: '/spot/market/vip-fee-rate')
        handle_response(response)
      end

      # Get Ticker Information
      # GET /api/v2/spot/market/tickers
      #
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves 24-hour trading information for trading pairs
      #
      # @param symbol [String] Optional. Filter by trading pair e.g. 'BTCUSDT'
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success, error description for failure)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of ticker information:
      #     - symbol [String] Trading pair name (e.g. 'BTCUSDT')
      #     - high24h [String] Highest price in last 24 hours (e.g. '37775.65')
      #     - open [String] Opening price (e.g. '35134.2')
      #     - low24h [String] Lowest price in last 24 hours (e.g. '34413.1')
      #     - lastPr [String] Latest price (e.g. '34413.1')
      #     - quoteVolume [String] Quote currency volume (e.g. '0')
      #     - baseVolume [String] Base currency volume (e.g. '0')
      #     - usdtVolume [String] Volume in USDT equivalent (e.g. '0')
      #     - bidPr [String] Best bid price (e.g. '0')
      #     - askPr [String] Best ask price (e.g. '0')
      #     - bidSz [String] Best bid size (e.g. '0.0663')
      #     - askSz [String] Best ask size (e.g. '0.0119')
      #     - openUtc [String] UTC opening price (e.g. '23856.72')
      #     - ts [String] Timestamp in milliseconds (e.g. '1625125755277')
      #     - changeUtc24h [String] 24h price change in UTC (e.g. '0.00301')
      #     - change24h [String] 24h price change (e.g. '0.00069')
      def spot_market_tickers(symbol: nil)
        response = get(path: '/spot/market/tickers', args: {symbol: symbol})
        handle_response(response)
      end

      # Get Merge Depth
      # GET /api/v2/spot/market/merge-depth
      #
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves the merged order book depth for a trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. BTCUSDT
      # @param precision [String] Optional. Price aggregation level (default: scale0)
      #   - scale0: No merge
      #   - scale1: Merge by quotation accuracy 10
      #   - scale2: Merge by quotation accuracy 100
      #   Note: Some pairs may not support all scales. Requests for unavailable
      #   scales will use the maximum available scale for that pair.
      # @param limit [Integer] Optional. Number of bids and asks to return
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order book data containing:
      #     - asks [Array<Array>] Array of ask orders [price, size]
      #     - bids [Array<Array>] Array of bid orders [price, size]
      #     - ts [String] Timestamp in milliseconds
      #     - scale [String] Price scale (e.g. '0.01')
      #     - precision [String] Price aggregation level used (e.g. 'scale0')
      #     - isMaxPrecision [String] Whether maximum precision is used ('YES'/'NO')
      def spot_market_merge_depth(symbol:, precision: nil, limit: nil)
        response = get(
          path: '/spot/market/merge-depth',
          args: {
            symbol: symbol,
            precision: precision,
            limit: limit,
          }
        )
        handle_response(response)
      end

      # Get OrderBook Depth
      # GET /api/v2/spot/market/orderbook
      #
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves the order book depth for a trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. BTCUSDT
      # @param type [String] Optional. Price aggregation level (default: step0)
      #   Values: step0, step1, step2, step3, step4, step5
      # @param limit [Integer] Optional. Number of bids and asks to return (default: 100, max: 200)
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order book data containing:
      #     - asks [Array<Array>] Array of ask orders [price, size]
      #     - bids [Array<Array>] Array of bid orders [price, size]
      #     - ts [String] Timestamp in milliseconds
      def spot_market_orderbook(symbol:, type: nil, limit: nil)
        response = get(
          path: '/spot/market/orderbook',
          args: {
            symbol: symbol,
            type: type,
            limit: limit,
          }
        )
        handle_response(response)
      end

      # Get Candlestick Data
      # GET /api/v2/spot/market/candles
      #
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves candlestick/kline data for a trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. BTCUSDT
      # @param granularity [String] Required. Time interval for candles
      #   Common values: '1min', '5min', '15min', '30min', '1h', '4h', '6h', '12h', '1d', '1w'
      # @param start_time [Integer] Optional. Start time in Unix milliseconds e.g. 1659076670000
      # @param end_time [Integer] Optional. End time in Unix milliseconds e.g. 1659080270000
      # @param limit [Integer] Optional. Number of candles to return (default: 100)
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Array>] Array of candles, each array containing:
      #     - [0] [String] Timestamp in milliseconds
      #     - [1] [String] Opening price
      #     - [2] [String] Highest price
      #     - [3] [String] Lowest price
      #     - [4] [String] Closing price
      #     - [5] [String] Volume
      #     - [6] [String] Quote currency volume
      #     - [7] [String] Quote currency volume (duplicate)
      def spot_market_candles(symbol:, granularity:, start_time: nil, end_time: nil, limit: nil)
        response = get(
          path: '/spot/market/candles',
          args: {
            symbol: symbol,
            granularity: granularity,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
          }
        )
        handle_response(response)
      end

      # Get History Candlestick Data
      # GET /api/v2/spot/market/history-candles
      #
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves historical candlestick/kline data for a trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. BTCUSDT
      # @param granularity [String] Required. Time interval for candles
      #   Common values: '1min', '5min', '15min', '30min', '1h', '4h', '6h', '12h', '1d', '1w'
      # @param end_time [Integer] Required. End time in Unix milliseconds e.g. 1659080270000
      # @param limit [Integer] Optional. Number of candles to return (default: 100)
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Array>] Array of candles, each array containing:
      #     - [0] [String] Timestamp in milliseconds
      #     - [1] [String] Opening price
      #     - [2] [String] Highest price
      #     - [3] [String] Lowest price
      #     - [4] [String] Closing price
      #     - [5] [String] Volume
      #     - [6] [String] Quote currency volume
      #     - [7] [String] Quote currency volume (duplicate)
      def spot_market_history_candles(symbol:, granularity:, end_time:, limit: nil)
        response = get(
          path: '/spot/market/history-candles',
          args: {
            symbol: symbol,
            granularity: granularity,
            endTime: end_time,
            limit: limit,
          }
        )
        handle_response(response)
      end

      # Get Recent Trades
      # GET /api/v2/spot/market/fills
      #
      # Rate Limit: 10 times/1s (IP)
      # Note: This endpoint retrieves recent trades for a trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. BTCUSDT
      # @param limit [Integer] Optional. Number of trades to return (default: 100)
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of trades, each with:
      #     - symbol [String] Trading pair name
      #     - tradeId [String] Trade ID
      #     - side [String] Trade side ('buy' or 'sell')
      #     - price [String] Trade price
      #     - size [String] Trade size
      #     - ts [String] Timestamp in milliseconds
      def spot_market_fills(symbol:, limit: nil)
        response = get(path: '/spot/market/fills', args: {symbol: symbol, limit: limit})
        handle_response(response)
      end

      # Get Market Trades
      # GET /api/v2/spot/market/fills-history
      #
      # Rate Limit: 10 req/sec/IP
      # Note: This endpoint retrieves historical trades for a trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. BTCUSDT
      # @param limit [Integer] Optional. Number of trades to return (default: 100)
      # @param id_less_than [String] Optional. Return trades with ID less than this value
      # @param start_time [Integer] Optional. Start time in Unix milliseconds
      # @param end_time [Integer] Optional. End time in Unix milliseconds
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of trades, each with:
      #     - symbol [String] Trading pair name
      #     - tradeId [String] Trade ID
      #     - side [String] Trade side ('Buy' or 'Sell')
      #     - price [String] Trade price
      #     - size [String] Trade size
      #     - ts [String] Timestamp in milliseconds
      def spot_market_fills_history(symbol:, limit: nil, id_less_than: nil, start_time: nil, end_time: nil)
        response = get(
          path: '/spot/market/fills-history',
          args: {
            symbol: symbol,
            limit: limit,
            idLessThan: id_less_than,
            startTime: start_time,
            endTime: end_time,
          }
        )
        handle_response(response)
      end

      # Trade

      # Place Order
      # POST /api/v2/spot/trade/place-order
      #
      # Rate limit: 10 requests/second/UID
      # Rate limit: 1 request/second/UID for copy trading traders
      # Note: This endpoint places a new order for spot trading
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param side [String] Required. Order direction: 'buy' or 'sell'
      # @param order_type [String] Required. Order type:
      #   - limit: Limit order
      #   - market: Market order
      # @param size [String] Required. Order size
      # @param price [String] Optional. Order price, required for limit orders
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param force [String] Optional. Time in force:
      #   - gtc: Good till cancelled
      #   - fok: Fill or kill
      #   - ioc: Immediate or cancel
      #   - post_only: Post only
      # @param stp_mode [String] Optional. Self-trade prevention mode
      # @param stp_id [String] Optional. Self-trade prevention ID
      # @param request_time [Integer] Optional. Request timestamp in milliseconds
      # @param receive_window [Integer] Optional. Number of milliseconds after request_time the request is valid for
      # @param execute_take_profit_price [String] Optional. Execute take profit price
      # @param preset_stop_loss_price [String] Optional. Preset stop loss price
      # @param execute_stop_loss_price [String] Optional. Execute stop loss price
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order details:
      #     - orderId [String] Order ID
      #     - clientOid [String] Client order ID if provided
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
      #
      # Rate Limit: Rate limit: 5 requests/second/UID
      # Note: This endpoint cancels an existing order and places a new one atomically
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param price [String] Required. Price for the new order
      # @param size [String] Required. Size for the new order
      # @param client_order_id [String] Optional. Client order ID of the order to cancel
      # @param order_id [String] Optional. Order ID of the order to cancel
      #   Note: Either client_order_id or order_id must be provided
      # @param new_client_order_id [String] Optional. Client order ID for the new order
      # @param preset_take_profit_price [String] Optional. Preset take profit price
      # @param execute_take_profit_price [String] Optional. Execute take profit price
      # @param preset_stop_loss_price [String] Optional. Preset stop loss price
      # @param execute_stop_loss_price [String] Optional. Execute stop loss price
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order details:
      #     - orderId [String] Order ID
      #     - clientOid [String] Client order ID if provided
      #     - success [String] Operation result ('success' or 'failure')
      #     - msg [String] Additional message about the operation
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
        execute_stop_loss_price: nil
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
          }
        )
        handle_response(response)
      end

      # Batch Cancel Existing Order and Send New Orders
      # POST /api/v2/spot/trade/batch-cancel-replace-order
      #
      # Rate Limit: 5 requests/second/UID
      # Note: This endpoint cancels multiple existing orders and places new ones atomically
      #
      # @param order_list [Array<Hash>] Collection of orders to place (max 50)
      #   Each order hash must contain:
      #   - symbol: [String] Required. Trading pair name e.g. BTCUSDT
      #   - price: [String] Required. Limit price
      #   - size: [String] Required. Order size
      #   - clientOid: [String] Optional. Client Order ID
      #   - orderId: [String] Optional. Order ID to cancel (either orderId or clientOid required)
      #   - newClientOid: [String] Optional. New client order ID for the replacement order
      #   Example order hash:
      #   {
      #     symbol: 'BTCUSDT',
      #     price: '25000.1',
      #     size: '0.01',
      #     orderId: '123456',
      #     newClientOid: 'my_new_order_1'
      #   }
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of order results, each containing:
      #     - orderId [String] Order ID
      #     - clientOid [String] Client order ID if provided
      #     - success [String] Operation result ('success' or 'failure')
      #     - msg [String] Additional message about the operation
      def spot_trade_batch_cancel_replace_order(order_list:)
        response = post(path: '/spot/trade/batch-cancel-replace-order', args: {orderList: order_list})
        handle_response(response)
      end

      # Cancel Order
      # POST /api/v2/spot/trade/cancel-order
      #
      # Frequency limit:10 times/1s (UID)
      # Note: This endpoint cancels an existing order
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param tpsl_type [String] Optional. Take profit/stop loss type: 'normal' or 'tpsl'
      # @param order_id [String] Optional. Order ID to cancel
      # @param client_order_id [String] Optional. Client order ID to cancel
      #   Note: Either order_id or client_order_id must be provided
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - message [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order details:
      #     - orderId [String] Order ID
      #     - clientOid [String] Client order ID if provided
      def spot_trade_cancel_order(symbol:, tpsl_type: nil, order_id: nil, client_order_id: nil)
        response = post(
          path: '/spot/trade/cancel-order',
          args: {
            symbol: symbol,
            tpslType: tpsl_type,
            orderId: order_id,
            clientOid: client_order_id,
          }
        )
        handle_response(response)
      end

      # Batch Place Orders
      # POST /api/v2/spot/trade/batch-orders
      #
      # Rate limit: Frequency limit: 5 times/1s (UID)Trader frequency limit: 1 times/1s (UID)
      # Note: This endpoint places multiple orders in a single request
      #
      # @param symbol [String] Optional. Trading pair name e.g. 'BTCUSDT'
      # @param batch_mode [String] Optional. Batch mode type:
      #   - single: Single currency mode (symbol in orderList will be ignored)
      #   - multiple: Cross-currency mode
      # @param order_list [Array<Hash>] Collection of orders to place (max 50)
      #   Each order hash must contain:
      #   - side: [String] Required. Order direction ('buy' or 'sell')
      #   - orderType: [String] Required. Order type ('limit', 'market', 'post_only', 'fok', 'ioc')
      #   - force: [String] Required. Time in force ('gtc', 'ioc', 'fok', 'post_only')
      #   - price: [String] Required for limit orders. Order price
      #   - size: [String] Required. Order size
      #   - clientOid: [String] Optional. Client order ID
      #   - symbol: [String] Required if batch_mode is 'multiple'. Trading pair
      #   Example order hash:
      #   {
      #     side: 'buy',
      #     orderType: 'limit',
      #     force: 'normal',
      #     price: '25000.1',
      #     size: '0.01',
      #     clientOid: 'my_order_1'
      #   }
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order results:
      #     - successList [Array<Hash>] Successfully placed orders:
      #       - orderId [String] Order ID
      #       - clientOid [String] Client order ID if provided
      #     - failureList [Array<Hash>] Failed orders (if any)
      def spot_trade_batch_orders(symbol: nil, batch_mode: nil, order_list:)
        response = post(
          path: '/spot/trade/batch-orders',
          args: {
            symbol: symbol,
            batchMode: batch_mode,
            orderList: order_list,
          }
        )
        handle_response(response)
      end

      # Batch Cancel Orders
      # POST /api/v2/spot/trade/batch-cancel-order
      #
      # Frequency limit:10 times/1s (UID)
      # Note: This endpoint cancels multiple orders in a single request
      #
      # @param symbol [String] Optional. Trading pair name for single currency mode
      # @param batch_mode [String] Optional. Batch mode type: 'single' (default) or 'multiple'
      #   - single: single currency mode (symbol in orderList will be ignored)
      #   - multiple: cross-currency mode
      # @param order_list [Array<Hash>] Required. Collection of orders to cancel
      #   Each order hash must contain:
      #   - symbol: [String] Required. Trading pair name e.g. BTCUSDT
      #   - orderId: [String] Optional. Order ID (either orderId or clientOid required)
      #   - clientOid: [String] Optional. Client Order ID (either orderId or clientOid required)
      #   Example order hash:
      #   {
      #     symbol: 'BTCUSDT',
      #     orderId: '123456',
      #     clientOid: 'my_order_1'
      #   }
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - message [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order results:
      #     - successList [Array<Hash>] Successfully cancelled orders:
      #       - orderId [String] Order ID
      #       - clientOid [String] Client order ID if provided
      #     - failureList [Array<Hash>] Failed orders (if any):
      #       - orderId [String] Order ID
      #       - clientOid [String] Client order ID if provided
      #       - errorMsg [String] Error message explaining the failure
      def spot_trade_batch_cancel_order(symbol: nil, batch_mode: nil, order_list:)
        response = post(
          path: '/spot/trade/batch-cancel-order',
          args: {
            symbol: symbol,
            batchMode: batch_mode,
            orderList: order_list,
          }
        )
        handle_response(response)
      end

      # Cancel Order by Symbol
      # POST /api/v2/spot/trade/cancel-symbol-order
      #
      # Rate Limit: Frequency limit: 5 times/1s (UID)
      # Note: This endpoint cancels all orders for a specific trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Cancellation details:
      #     - symbol [String] Trading pair name
      #     - canceledList [Array<Hash>] List of cancelled orders
      #     - failedList [Array<Hash>] List of failed orders
      def spot_trade_cancel_symbol_order(symbol:)
        response = post(path: '/spot/trade/cancel-symbol-order', args: {symbol: symbol})
        handle_response(response)
      end

      # Get Order Info
      # GET /api/v2/spot/trade/orderInfo
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint retrieves detailed information about a specific order
      #
      # @param order_id [String] Optional. Order ID to query
      # @param client_order_id [String] Optional. Client order ID to query
      #   Note: Either order_id or client_order_id must be provided
      # @param request_time [Integer] Optional. Current timestamp in milliseconds
      # @param receive_window [Integer] Optional. The value cannot be greater than 60000
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of order details, each containing:
      #     - userId [String] User ID
      #     - symbol [String] Trading pair
      #     - orderId [String] Order ID
      #     - clientOid [String] Client order ID
      #     - price [String] Order price
      #     - size [String] Order size
      #     - orderType [String] Order type
      #     - side [String] Order side ('buy' or 'sell')
      #     - status [String] Order status
      #     - priceAvg [String] Average fill price
      #     - baseVolume [String] Base asset volume
      #     - quoteVolume [String] Quote asset volume
      #     - enterPointSource [String] Entry point source
      #     - feeDetail [String] Fee details JSON string
      #     - orderSource [String] Order source
      #     - cancelReason [String] Reason for cancellation if cancelled
      #     - cTime [String] Creation time
      #     - uTime [String] Update time
      def spot_trade_order_info(order_id: nil, client_order_id: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/trade/orderInfo',
          args: {
            orderId: order_id,
            clientOid: client_order_id,
            requestTime: request_time,
            receiveWindow: receive_window,
          }
        )
        handle_response(response)
      end

      # Get Current Orders
      # GET /api/v2/spot/trade/unfilled-orders
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint retrieves all unfilled (open) orders for the account
      #
      # @param symbol [String] Optional. Trading pair name e.g. 'BTCUSDT'
      # @param start_time [Integer] Optional. Start timestamp in milliseconds
      # @param end_time [Integer] Optional. End timestamp in milliseconds
      # @param id_less_than [String] Optional. Pagination of data to return records earlier than the requested orderId
      # @param limit [Integer] Optional. Number of results per request. Maximum 100. Default 100
      # @param order_id [String] Optional. Filter by order ID
      # @param tpsl_type [String] Optional. Take profit/stop loss type: 'normal' or 'tpsl'
      # @param request_time [Integer] Optional. Current timestamp in milliseconds
      # @param receive_window [Integer] Optional. The value cannot be greater than 60000
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - message [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of unfilled orders, each containing:
      #     - userId [String] User ID
      #     - symbol [String] Trading pair
      #     - orderId [String] Order ID
      #     - clientOid [String] Client order ID if provided
      #     - priceAvg [String] Average fill price
      #     - size [String] Order size
      #     - orderType [String] Order type
      #     - side [String] Order side ('buy' or 'sell')
      #     - status [String] Order status
      #     - basePrice [String] Base price
      #     - baseVolume [String] Base asset volume
      #     - quoteVolume [String] Quote asset volume
      #     - enterPointSource [String] Entry point source
      #     - presetTakeProfitPrice [String] Preset take profit price
      #     - executeTakeProfitPrice [String] Execute take profit price
      #     - presetStopLossPrice [String] Preset stop loss price
      #     - executeStopLossPrice [String] Execute stop loss price
      #     - cTime [String] Creation time
      #     - tpslType [String] Take profit/stop loss type
      #     - triggerPrice [String] Trigger price
      def spot_trade_unfilled_orders(symbol: nil, start_time: nil, end_time: nil, id_less_than: nil, limit: nil, order_id: nil, tpsl_type: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/trade/unfilled-orders',
          args: {
            symbol: symbol,
            startTime: start_time,
            endTime: end_time,
            idLessThan: id_less_than,
            limit: limit,
            orderId: order_id,
            tpslType: tpsl_type,
            requestTime: request_time,
            receiveWindow: receive_window,
          }
        )
        handle_response(response)
      end

      # Get History Orders
      # GET /api/v2/spot/trade/history-orders
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint retrieves historical orders (filled, cancelled, etc.)
      #
      # @param symbol [String] Optional. Trading pair name e.g. 'BTCUSDT'
      # @param start_time [Integer] Optional. Start timestamp in milliseconds
      # @param end_time [Integer] Optional. End timestamp in milliseconds
      # @param id_less_than [String] Optional. Pagination of data to return records earlier than the requested orderId
      # @param limit [Integer] Optional. Number of results per request. Maximum 100. Default 100
      # @param order_id [String] Optional. Filter by order ID
      # @param tpsl_type [String] Optional. Take profit/stop loss type: 'normal' or 'tpsl'
      # @param request_time [Integer] Optional. Current timestamp in milliseconds
      # @param receive_window [Integer] Optional. The value cannot be greater than 60000
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - message [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of historical orders, each containing:
      #     - userId [String] User ID
      #     - symbol [String] Trading pair
      #     - orderId [String] Order ID
      #     - clientOid [String] Client order ID if provided
      #     - price [String] Order price
      #     - size [String] Order size
      #     - orderType [String] Order type
      #     - side [String] Order side ('buy' or 'sell')
      #     - status [String] Order status
      #     - priceAvg [String] Average fill price
      #     - baseVolume [String] Base asset volume
      #     - quoteVolume [String] Quote asset volume
      #     - enterPointSource [String] Entry point source
      #     - feeDetail [String] Fee details JSON string
      #     - orderSource [String] Order source
      #     - cTime [String] Creation time
      #     - uTime [String] Update time
      #     - tpslType [String] Take profit/stop loss type
      #     - cancelReason [String] Reason for cancellation if cancelled
      #     - triggerPrice [String] Trigger price
      def spot_trade_history_orders(symbol: nil, start_time: nil, end_time: nil, id_less_than: nil, limit: nil, order_id: nil, tpsl_type: nil, request_time: nil, receive_window: nil)
        response = get(
          path: '/spot/trade/history-orders',
          args: {
            symbol: symbol,
            startTime: start_time,
            endTime: end_time,
            idLessThan: id_less_than,
            limit: limit,
            orderId: order_id,
            tpslType: tpsl_type,
            requestTime: request_time,
            receiveWindow: receive_window,
          }
        )
        handle_response(response)
      end

      # Get Fills
      # GET /api/v2/spot/trade/fills
      #
      # Frequency limit:10 times/1s (UID)
      # Note: This endpoint retrieves trade execution details for orders
      #
      # @param symbol [String] Optional. Trading pair name e.g. 'BTCUSDT'
      # @param order_id [String] Optional. Filter by order ID
      # @param start_time [Integer] Optional. Start timestamp in milliseconds
      # @param end_time [Integer] Optional. End timestamp in milliseconds
      # @param limit [Integer] Optional. Number of results per request. Maximum 100. Default 100
      # @param id_less_than [String] Optional. Pagination of data to return records earlier than the requested fillId
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] Array of fills, each containing:
      #     - userId [String] User ID
      #     - symbol [String] Trading pair
      #     - orderId [String] Order ID
      #     - tradeId [String] Trade ID
      #     - orderType [String] Order type
      #     - side [String] Trade side ('buy' or 'sell')
      #     - priceAvg [String] Average fill price
      #     - size [String] Fill size
      #     - amount [String] Fill amount
      #     - feeDetail [Hash] Fee details:
      #       - deduction [String] Fee deduction type
      #       - feeCoin [String] Fee currency
      #       - totalDeductionFee [String] Total deduction fee
      #       - totalFee [String] Total fee
      #     - tradeScope [String] Trade scope (e.g. 'taker')
      #     - cTime [String] Creation time
      #     - uTime [String] Update time
      def spot_trade_fills(symbol: nil, order_id: nil, start_time: nil, end_time: nil, limit: nil, id_less_than: nil)
        response = get(
          path: '/spot/trade/fills',
          args: {
            symbol: symbol,
            orderId: order_id,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            idLessThan: id_less_than,
          }
        )
        handle_response(response)
      end

      # Trigger

      # Place Plan Order
      # POST /api/v2/spot/trade/place-plan-order
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint places a trigger/plan order that executes when price conditions are met
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param side [String] Required. Order direction: 'buy' or 'sell'
      # @param trigger_price [String] Required. Price to trigger the order
      # @param order_type [String] Required. Order type: 'limit' or 'market'
      # @param execute_price [String] Optional. Order execution price (required for limit orders)
      # @param plan_type [String] Optional. Plan type: 'limit' or 'market'
      # @param size [String] Required. Order quantity
      # @param trigger_type [String] Optional. Trigger type: 'mark_price' or 'market_price'
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param stp_mode [String] Optional. STP mode: 'cancel_maker', 'cancel_taker', or 'cancel_both'
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order details containing:
      #     - orderId [String] Plan order ID
      #     - clientOid [String] Client order ID if provided
      def spot_trade_place_plan_order(symbol:, side:, trigger_price:, order_type:, execute_price: nil, plan_type: nil, size: nil, trigger_type: nil, client_order_id: nil, stp_mode: nil)
        response = post(
          path: '/spot/trade/place-plan-order',
          args: {
            symbol: symbol,
            side: side,
            triggerPrice: trigger_price,
            orderType: order_type,
            executePrice: execute_price,
            planType: plan_type,
            size: size,
            triggerType: trigger_type,
            clientOid: client_order_id,
            stpMode: stp_mode,
          }
        )
        handle_response(response)
      end

      # Modify Plan Order
      # POST /api/v2/spot/trade/modify-plan-order
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint modifies an existing trigger/plan order
      #
      # @param order_id [String] Required. Order ID to modify
      # @param trigger_price [String] Optional. New trigger price
      # @param execute_price [String] Optional. New execution price
      # @param size [String] Optional. New order quantity
      # @param order_type [String] Optional. Order type: 'limit' or 'market'
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order details containing:
      #     - orderId [String] Plan order ID
      #     - clientOid [String] Client order ID if provided
      def spot_trade_modify_plan_order(order_id:, trigger_price: nil, execute_price: nil, size: nil, order_type: nil)
        response = post(
          path: '/spot/trade/modify-plan-order',
          args: {
            orderId: order_id,
            triggerPrice: trigger_price,
            executePrice: execute_price,
            size: size,
            orderType: order_type,
          }
        )
        handle_response(response)
      end

      # Cancel Plan Order
      # POST /api/v2/spot/trade/cancel-plan-order
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint cancels an existing trigger/plan order
      #
      # @param order_id [String] Required. Plan order ID to cancel
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Cancellation result containing:
      #     - result [String] Cancellation result ('success' if successful)
      def spot_trade_cancel_plan_order(order_id:)
        response = post(
          path: '/spot/trade/cancel-plan-order',
          args: {orderId: order_id}
        )
        handle_response(response)
      end

      # Get Current Plan Orders
      # GET /api/v2/spot/trade/current-plan-order
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint retrieves all active trigger/plan orders
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param order_type [String] Optional. Order type: 'limit' or 'market'
      # @param side [String] Optional. Order direction: 'buy' or 'sell'
      # @param start_time [Integer] Optional. Start time in Unix milliseconds
      # @param end_time [Integer] Optional. End time in Unix milliseconds
      # @param limit [Integer] Optional. Number of results per request. Maximum 100. Default 100
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order list details containing:
      #     - nextFlag [Boolean] Whether there are more orders to fetch
      #     - idLessThan [String] ID to use for pagination
      #     - orderList [Array<Hash>] List of plan orders
      def spot_trade_current_plan_order(symbol:, order_type: nil, side: nil, start_time: nil, end_time: nil, limit: nil)
        response = get(
          path: '/spot/trade/current-plan-order',
          args: {
            symbol: symbol,
            orderType: order_type,
            side: side,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
          }
        )
        handle_response(response)
      end

      # Get Plan Sub Order
      # GET /api/v2/spot/trade/plan-sub-order
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint retrieves the executed sub-orders of a trigger/plan order
      #
      # @param order_id [String] Required. Plan order ID to query
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] List of sub-orders, each containing:
      #     - orderId [String] Sub-order ID
      #     - price [String] Order price
      #     - type [String] Order type
      #     - status [String] Order status
      def spot_trade_plan_sub_order(order_id:)
        response = get(
          path: '/spot/trade/plan-sub-order',
          args: {orderId: order_id}
        )
        handle_response(response)
      end

      # Get History Plan Orders
      # GET /api/v2/spot/trade/history-plan-order
      #
      # Frequency limit: 20 times/1s (UID)
      # Note: This endpoint retrieves historical trigger/plan orders (executed, cancelled, etc.)
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param start_time [Integer] Required. Start time in Unix milliseconds
      # @param end_time [Integer] Required. End time in Unix milliseconds
      # @param limit [Integer] Optional. Number of results per request. Maximum 100. Default 100
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Order list details containing:
      #     - nextFlag [Boolean] Whether there are more orders to fetch
      #     - idLessThan [String] ID to use for pagination
      #     - orderList [Array<Hash>] List of historical orders, each containing:
      #       - orderId [String] Plan order ID
      #       - clientOid [String] Client order ID if provided
      #       - symbol [String] Trading pair
      #       - size [String] Order size
      #       - executePrice [String] Execution price
      #       - triggerPrice [String] Trigger price
      #       - status [String] Order status
      #       - orderType [String] Order type
      #       - side [String] Order side ('buy' or 'sell')
      #       - planType [String] Plan type
      #       - triggerType [String] Trigger type
      #       - enterPointSource [String] Entry point source
      #       - uTime [String] Update time
      #       - cTime [String] Creation time
      def spot_trade_history_plan_order(symbol:, start_time:, end_time:, limit: nil)
        response = get(
          path: '/spot/trade/history-plan-order',
          args: {
            symbol: symbol,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
          }
        )
        handle_response(response)
      end

      # Cancel Plan Orders in Batch
      # POST /api/v2/spot/trade/batch-cancel-plan-order
      #
      # Rate limit: 5 req/sec/UID
      # Note: This endpoint cancels all trigger/plan orders for the specified trading pairs
      #
      # @param symbol_list [Array<String>] Required. List of trading pair names e.g. ['BTCUSDT', 'ETHUSDT']
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Cancellation results containing:
      #     - successList [Array<String>] List of successfully cancelled order IDs
      #     - failureList [Array<String>] List of failed order IDs
      def spot_trade_batch_cancel_plan_order(symbol_list:)
        response = post(
          path: '/spot/trade/batch-cancel-plan-order',
          args: {symbolList: symbol_list}
        )
        handle_response(response)
      end

      # Account

      # Get Account Information
      # GET /api/v2/spot/account/info
      #
      # Frequency limit: 1 time/1s (User ID)
      # Note: This endpoint retrieves basic information about the user's spot account
      #
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Hash] Account information containing:
      #     - userId [String] User ID
      #     - inviterId [String, nil] Inviter's ID if any
      #     - channelCode [String] Channel code
      #     - channel [String] Channel name
      #     - ips [String] IP addresses
      #     - authorities [Array<String>] List of user authorities
      #     - parentId [Integer] Parent account ID
      #     - traderType [String] Trader type
      #     - regisTime [String] Registration time in milliseconds
      def spot_account_info
        response = get(path: '/spot/account/info')
        handle_response(response)
      end

      # Get Account Assets
      # GET /api/v2/spot/account/assets
      #
      # Frequency limit: 10 times/1s (User ID)
      # Note: This endpoint retrieves detailed balance information for all assets in the spot account
      #
      # @param coin [String] Optional. Cryptocurrency code e.g. 'BTC'
      # @param asset_type [String] Optional. Type of asset
      # @return [Hash] Response containing:
      #   - code [String] Response code ('00000' for success)
      #   - msg [String] Response message ('success' for success)
      #   - requestTime [Integer] Request timestamp in milliseconds
      #   - data [Array<Hash>] List of account assets with the following fields:
      #     - coin [String] The coin symbol
      #     - available [String] Available balance
      #     - limitAvailable [String] Limit available balance
      #     - frozen [String] Frozen balance
      #     - locked [String] Locked balance
      #     - uTime [String] Last update time in Unix milliseconds
      def spot_account_assets(coin: nil, asset_type: nil)
        response = get(
          path: '/spot/account/assets',
          args: {
            coin: coin,
            assetType: asset_type,
          }
        )
        handle_response(response)
      end

      # Get Sub-accounts Assets
      # GET /api/v2/spot/account/subaccount-assets
      #
      # Frequency limit: 10 times/1s (User ID)
      # Note: This endpoint retrieves asset information for all sub-accounts
      # Returns only sub-accounts which have assets > 0
      # Note: ND Brokers are not allowed to call this endpoint
      #
      # @param id_less_than [String] Optional.
      # @param limit [String] Optional.
      # @return [Hash] Response hash
      #   * code [String] Response code, '00000' means success
      #   * msg [String] Response message
      #   * requestTime [Integer] Request timestamp
      #   * data [Array<Hash>] List of assets
      #     * id [Integer] Sub-account ID
      #     * userId [Integer] User ID of the sub-account
      #     * assetsList [Array<Hash>] List of assets
      #       * coin [String] Currency name
      #       * available [String] Available balance
      #       * limitAvailable [String] Limited available balance
      #       * frozen [String] Frozen balance
      #       * locked [String] Locked balance
      #       * uTime [String] Last update time in Unix milliseconds
      def spot_account_subaccount_assets(id_less_than: nil, limit: nil)
        response = get(path: '/spot/account/subaccount-assets',
          args: {
            idLessThan: id_less_than,
            limit: limit
          }
        )
        handle_response(response)
      end

      # Modify Deposit Account
      # POST /api/v2/spot/wallet/modify-deposit-account
      #
      # Frequency limit:10 times/1s (User ID)
      # Note: This endpoint modifies the deposit account type for a specific cryptocurrency
      #
      # @param account_type [String] Required. Account type. Valid values:
      #   - 'spot': Spot account
      #   - 'funding': Funding account
      #   - 'coin-futures': Coin-M futures account
      #   - 'mix_usdt': USDT-M futures account
      #   - 'usdc-futures': USDC-M futures account
      # @param coin [String] Required. The cryptocurrency code e.g. 'BTC', 'USDT'
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [String] 'success' if successful
      def spot_wallet_modify_deposit_account(account_type:, coin:)
        response = post(
          path: '/spot/wallet/modify-deposit-account',
          args: {
            accountType: account_type,
            coin: coin,
          }
        )
        handle_response(response)
      end

      # Get Account Bills
      # GET /api/v2/spot/account/bills
      #
      # Frequency limit: 10 times/1s (User ID)
      # Note: This endpoint retrieves the account's transaction history including deposits, withdrawals, trades, etc.
      #
      # @param coin [String] Optional coin name
      # @param group_type [String] Optional group type (e.g., 'transaction', 'withdraw', 'transfer', 'other')
      # @param business_type [String] Optional business type (e.g., 'ORDER_DEALT_FROZEN_OUT', 'ORDER_DEALT_IN', 'WITHDRAW', 'TRANSFER_IN')
      # @param start_time [Integer] Optional start time
      # @param end_time [Integer] Optional end time
      # @param limit [Integer] Optional limit
      # @param id_less_than [Integer] Optional filter for records with ID less than this value
      #
      # @return [Hash] Response hash
      #   * code [String] Response code, '00000' means success
      #   * msg [String] Response message
      #   * requestTime [Integer] Request timestamp
      #   * data [Array<Hash>] List of bills
      #     * cTime [String] Creation timestamp in Unix milliseconds
      #     * coin [String] Currency name
      #     * groupType [String] Group type (e.g., 'transaction', 'withdraw', 'transfer', 'other')
      #     * businessType [String] Business type (e.g., 'ORDER_DEALT_FROZEN_OUT', 'ORDER_DEALT_IN', 'WITHDRAW', 'TRANSFER_IN')
      #     * size [String] Transaction size/amount
      #     * balance [String] Account balance after transaction
      #     * fees [String] Transaction fees
      #     * billId [String] Bill ID
      #     * bizOrderId [String] Business order ID
      def spot_account_bills(coin: nil, group_type: nil, business_type: nil, start_time: nil, end_time: nil, limit: nil, id_less_than: nil)
        response = get(
          path: '/spot/account/bills',
          args: {
            coin: coin,
            groupType: group_type,
            businessType: business_type,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            idLessThan: id_less_than,
          }
        )
        handle_response(response)
      end

      # Transfer
      # POST /api/v2/spot/wallet/transfer
      #
      # RRate limit: 10 requests/second/UID
      # Note: This endpoint transfers assets between different account types within Bitget
      # Note: Only available for main accounts, not sub-accounts
      #
      # @param from_type [String] Required. Source account type. Valid values:
      #   - 'spot': Spot account
      #   - 'p2p': P2P/funding account
      #   - 'coin_futures': Coin-M futures account
      #   - 'usdt_futures': USDT-M futures account
      #   - 'usdc_futures': USDC-M futures account
      #   - 'crossed_margin': Cross margin account
      #   - 'isolated_margin': Isolated margin account
      # @param to_type [String] Required. Destination account type (same valid values as from_type)
      # @param amount [String] Required. Amount to transfer
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param symbol [String] Required. Trading pair symbol e.g. 'BTCUSDT'
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @return [Hash] Response containing:
      #   - transferId [String] Transfer ID assigned by Bitget
      #   - clientOid [String] Client-supplied order ID
      def spot_wallet_transfer(from_type:, to_type:, amount:, coin:, symbol:, client_order_id: nil)
        response = post(
          path: '/spot/wallet/transfer',
          args: {
            fromType: from_type,
            toType: to_type,
            amount: amount,
            coin: coin,
            symbol: symbol,
            clientOid: client_order_id,
          }
        )
        handle_response(response)
      end

      # GET Transferable Coin List
      # GET /api/v2/spot/wallet/transfer-coin-info
      #
      # Frequency limit:10 times/1s (User ID)
      # Note: This endpoint retrieves the list of coins that can be transferred between specified account types
      #
      # @param from_type [String] Required. Source account type. Valid values:
      #   - 'spot': Spot account
      #   - 'p2p': P2P/funding account
      #   - 'coin_futures': Coin-M futures account
      #   - 'usdt_futures': USDT-M futures account
      #   - 'usdc_futures': USDC-M futures account
      #   - 'crossed_margin': Cross margin account
      #   - 'isolated_margin': Isolated margin account
      # @param to_type [String] Required. Destination account type (same valid values as from_type)
      # @return [Array<Hash>] List of transferable coins with their details:
      #   - coin [String] Cryptocurrency code
      #   - chain [String] Blockchain network
      #   - fromMin [String] Minimum transfer amount from source account
      #   - toMin [String] Minimum transfer amount to destination account
      def spot_wallet_transfer_coin_info(from_type:, to_type:)
        response = get(
          path: '/spot/wallet/transfer-coin-info',
          args: {
            fromType: from_type,
            toType: to_type,
          }
        )
        handle_response(response)
      end

      # Sub Transfer
      # POST /api/v2/spot/wallet/subaccount-transfer
      #
      # Rate limit: 10 req/sec/UID
      # Note: This endpoint requires IP whitelist. Transfer between fromUserId and toUserId
      # should have direct/brother relationship.
      #
      # @param from_type [String] Required. Source account type. Valid values:
      #   - 'spot': Spot account
      #   - 'p2p': P2P/funding account
      #   - 'coin_futures': Coin-M futures account
      #   - 'usdt_futures': USDT-M futures account
      #   - 'usdc_futures': USDC-M futures account
      #   - 'crossed_margin': Cross margin account
      #   - 'isolated_margin': Isolated margin account
      # @param to_type [String] Required. Destination account type (same valid values as from_type)
      # @param amount [String] Required. Amount to transfer
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param symbol [String] Optional. Trading pair symbol e.g. 'BTCUSDT'
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param from_user_id [String] Optional. Source user ID. Required for cross-user transfers
      # @param to_user_id [String] Optional. Destination user ID. Required for cross-user transfers
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Hash] Response data
      #     - transferId [String] Transfer ID assigned by Bitget
      #     - clientOid [String] Client-supplied order ID
      def spot_wallet_subaccount_transfer(from_type:, to_type:, amount:, coin:, symbol: nil, client_order_id: nil, from_user_id: nil, to_user_id: nil)
        response = post(
          path: '/spot/wallet/subaccount-transfer',
          args: {
            fromType: from_type,
            toType: to_type,
            amount: amount,
            coin: coin,
            clientOid: client_order_id,
            fromUserId: from_user_id,
            toUserId: to_user_id,
          }
        )
        handle_response(response)
      end

      # Withdraw
      # POST /api/v2/spot/wallet/withdrawal
      #
      # Rate limit:5 req/sec/UID
      # Note: This endpoint requires withdrawal permission and IP whitelist.
      #
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param transfer_type [String] Required. Type of withdrawal. Valid values:
      #   - 'on_chain': Withdraw to external address
      #   - 'internal_transfer': Internal transfer
      # @param address [String] Required. Withdrawal address
      # @param chain [String] Optional. Blockchain network e.g. 'BTC-Bitcoin', 'ETH-ERC20'
      # @param inner_to_type [String] Optional. Type of address for internal withdrawals. Valid values:
      #   - 'email': Email address
      #   - 'mobile': Mobile phone number
      #   - 'uid': UID (default)
      # @param area_code [String] Optional. Area code for the recipient
      # @param tag [String] Optional. Memo/Tag for coins that require it
      # @param size [String] Required. Withdrawal amount
      # @param remark [String] Optional. Withdrawal remark/note
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param member_code [String] Optional. Member code
      # @param identity_type [String] Optional. Identity type
      # @param company_name [String] Optional. Company name for business accounts
      # @param first_name [String] Optional. First name for individual accounts
      # @param last_name [String] Optional. Last name for individual accounts
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Hash] Response data
      #     - orderId [String] Withdrawal ID
      #     - clientOid [String] Client-supplied order ID
      def spot_wallet_withdrawal(coin:, transfer_type:, address:, chain: nil, inner_to_type: nil, area_code: nil, tag: nil, size:, remark: nil, client_order_id: nil, member_code: nil, identity_type: nil, company_name: nil, first_name: nil, last_name: nil)
        response = post(
          path: '/spot/wallet/withdrawal',
          args: {
            coin: coin,
            transferType: transfer_type,
            address: address,
            chain: chain,
            innerToType: inner_to_type,
            areaCode: area_code,
            tag: tag,
            size: size,
            remark: remark,
            clientOid: client_order_id,
            memberCode: member_code,
            identityType: identity_type,
            companyName: company_name,
            firstName: first_name,
            lastName: last_name,
          }
        )
        handle_response(response)
      end

      # Get MainSub Transfer Record
      # GET /api/v2/spot/account/sub-main-trans-record
      #
      # Rate limit: 20 req/sec/UID
      # Note: This endpoint retrieves transfer records between main and sub-accounts
      #
      # @param coin [String] Optional. Cryptocurrency code e.g. 'BTC'
      # @param role [String] Optional. Account role
      # @param subaccount_user_id [String] Optional. Sub-account user ID
      # @param start_time [Integer] Optional. Start time in Unix milliseconds
      # @param end_time [Integer] Optional. End time in Unix milliseconds
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param limit [Integer] Optional. Number of results per request. Default: 100
      # @param id_less_than [String] Optional. Filter records with ID less than this value
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Array<Hash>] List of transfer records
      #     - coin [String] Cryptocurrency code
      #     - status [String] Transfer status. Valid values:
      #       - 'Successful': Successful
      #       - 'Failed': Failed
      #       - 'Processing': Processing
      #     - toType [String] Destination account type
      #     - fromType [String] Source account type
      #     - size [String] Transfer amount
      #     - ts [String] Timestamp in Unix milliseconds
      #     - clientOid [String] Client order ID
      #     - transferId [String] Transfer ID
      #     - fromUserId [String] Source account ID
      #     - toUserId [String] Target account ID
      def spot_account_sub_main_trans_record(coin: nil, role: nil, subaccount_user_id: nil, start_time: nil, end_time: nil, client_order_id: nil, limit: nil, id_less_than: nil)
        response = get(
          path: '/spot/account/sub-main-trans-record',
          args: {
            coin: coin,
            role: role,
            subUid: subaccount_user_id,
            startTime: start_time,
            endTime: end_time,
            clientOid: client_order_id,
            limit: limit,
            idLessThan: id_less_than,
          }
        )
        handle_response(response)
      end

      # Get Transfer Record
      # GET /api/v2/spot/account/transferRecords
      #
      # Frequency limit: 20 times/1s (User ID)
      # Note: This endpoint retrieves transfer records between different account types
      #
      # @param coin [String] Optional. Cryptocurrency code e.g. 'BTC'
      # @param from_type [String] Optional. Source account type. Valid values:
      #   - 'spot': Spot account
      #   - 'p2p': P2P/funding account
      #   - 'coin_futures': Coin-M futures account
      #   - 'usdt_futures': USDT-M futures account
      #   - 'usdc_futures': USDC-M futures account
      #   - 'crossed_margin': Cross margin account
      #   - 'isolated_margin': Isolated margin account
      # @param start_time [Integer] Optional. Start time in Unix milliseconds
      # @param end_time [Integer] Optional. End time in Unix milliseconds
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param page_number [Integer] Optional. Page number for pagination
      # @param limit [Integer] Optional. Number of results per request. Default: 100
      # @param id_less_than [String] Optional. Filter records with ID less than this value
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Array<Hash>] List of transfer records
      #     - coin [String] Cryptocurrency code
      #     - status [String] Transfer status. Valid values:
      #       - 'Successful': Successful
      #       - 'Failed': Failed
      #       - 'Processing': Processing
      #     - toType [String] Target account type
      #     - toSymbol [String] Target symbol
      #     - fromType [String] Source account type
      #     - fromSymbol [String] Source symbol
      #     - size [String] Transfer amount
      #     - ts [String] Timestamp in Unix milliseconds
      #     - clientOid [String] Client order ID
      #     - transferId [String] Transfer ID
      def spot_account_transfer_records(coin: nil, from_type: nil, start_time: nil, end_time: nil, client_order_id: nil, page_number: nil, limit: nil, id_less_than: nil)
        response = get(
          path: '/spot/account/transferRecords',
          args: {
            coin: coin,
            fromType: from_type,
            startTime: start_time,
            endTime: end_time,
            clientOid: client_order_id,
            pageNum: page_number,
            limit: limit,
            idLessThan: id_less_than,
          }
        )
        handle_response(response)
      end

      # Switch BGB Deduct
      # POST /api/v2/spot/account/switch-deduct
      #
      # Rate Limit: 1 req/sec/UID
      # Note: This endpoint enables or disables BGB fee deduction for spot trading
      #
      # @param deduct [String] Required. Whether to enable BGB fee deduction. Valid values:
      #   - 'on': Enable BGB fee deduction
      #   - 'off': Disable BGB fee deduction
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Hash] Response data
      #     - deduct [String] Current BGB fee deduction status ('on' or 'off')
      def spot_account_switch_deduct(deduct:)
        response = post(path: '/spot/account/switch-deduct', args: {deduct: deduct})
        handle_response(response)
      end

      # Get Deposit Address
      # GET /api/v2/spot/wallet/deposit-address
      #
      # Frequency limit: 10 times/1s (User ID)
      # Note: This endpoint retrieves the deposit address for a specific cryptocurrency
      #
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param chain [String] Optional. Blockchain network e.g. 'BTC-Bitcoin', 'ETH-ERC20'
      # @param size [Integer] Optional. Number of addresses to generate
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Hash] Response data
      #     - coin [String] Cryptocurrency code
      #     - chain [String] Blockchain network
      #     - address [String] Deposit address
      #     - tag [String, nil] Memo/Tag if required by the coin
      #     - url [String] Block explorer URL
      def spot_wallet_deposit_address(coin:, chain: nil, size: nil)
        response = get(
          path: '/spot/wallet/deposit-address',
          args: {
            coin: coin,
            chain: chain,
            size: size,
          }
        )
        handle_response(response)
      end

      # Get SubAccount Deposit Address
      # GET /api/v2/spot/wallet/subaccount-deposit-address
      #
      # Rate limit: 10 req/sec/UID
      # Note: This endpoint retrieves the deposit address for a specific cryptocurrency in a sub-account
      #
      # @param subaccount_user_id [String] Required. Sub-account user ID (uid)
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param chain [String] Optional. Blockchain network e.g. 'BTC-Bitcoin', 'ETH-ERC20'
      # @param size [Integer] Optional. Number of addresses to generate
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Hash] Response data
      #     - coin [String] Cryptocurrency code
      #     - chain [String] Blockchain network
      #     - address [String] Deposit address
      #     - tag [String, nil] Memo/Tag if required by the coin
      #     - url [String] Block explorer URL
      def spot_wallet_subaccount_deposit_address(subaccount_user_id:, coin:, chain: nil, size: nil)
        response = get(
          path: '/spot/wallet/subaccount-deposit-address',
          args: {
            subUid: subaccount_user_id,
            coin: coin,
            chain: chain,
            size: size,
         }
        )
        handle_response(response)
      end

      # Get BGB Deduct Info
      # GET /api/v2/spot/account/deduct-info
      #
      # Rate limit: 5 req/sec/UID
      # Note: This endpoint retrieves the current BGB fee deduction settings
      #
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Hash] Response data
      #     - deduct [String] Current BGB fee deduction status ('on' or 'off')
      def spot_account_deduct_info
        response = get(path: '/spot/account/deduct-info')
        handle_response(response)
      end

      # Cancel Withdrawal
      # POST /api/v2/spot/wallet/cancel-withdrawal
      #
      # Frequency limit:10 times/1s (User ID)
      # Note: This endpoint cancels a pending withdrawal request
      #
      # @param order_id [String] Required. The withdrawal order ID to cancel
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [String] 'success' if withdrawal was cancelled
      def spot_wallet_cancel_withdrawal(order_id:)
        response = post(path: '/spot/wallet/cancel-withdrawal', args: {orderId: order_id})
        handle_response(response)
      end

      # Get SubAccount Deposit Records
      # GET /api/v2/spot/wallet/subaccount-deposit-records
      #
      # Frequency limit:10 times/1s (UID)
      # Note: This endpoint retrieves deposit records for a specific sub-account
      #
      # @param subaccount_user_id [String] Required. Sub-account user ID (uid)
      # @param coin [String] Optional. Filter by cryptocurrency code e.g. 'BTC', 'USDT'
      # @param start_time [Integer] Optional. Filter by start time in milliseconds
      # @param end_time [Integer] Optional. Filter by end time in milliseconds
      # @param id_less_than [Integer] Optional. Filter by records with ID less than this value
      # @param limit [Integer] Optional. Number of records to return (default: 100, max: 500)
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Array<Hash>] List of deposit records containing:
      #     - orderId [String] Record ID
      #     - tradeId [String] Trade ID
      #     - coin [String] Cryptocurrency code
      #     - size [String] Deposit amount
      #     - status [String] Deposit status (e.g. 'success')
      #     - toAddress [String] Destination address
      #     - dest [String] Destination type (e.g. 'on_chain')
      #     - chain [String] Blockchain network
      #     - fromAddress [String] Source address
      #     - cTime [String] Creation timestamp
      #     - uTime [String] Last update timestamp
      def spot_wallet_subaccount_deposit_records(subaccount_user_id:, coin: nil, start_time: nil, end_time: nil, id_less_than: nil, limit: nil)
        response = get(
          path: '/spot/wallet/subaccount-deposit-records',
          args: {
            subUid: subaccount_user_id,
            coin: coin,
            startTime: start_time,
            endTime: end_time,
            idLessThan: id_less_than,
            limit: limit,
          }
        )
        handle_response(response)
      end

      # Get Withdrawal Records
      # GET /api/v2/spot/wallet/withdrawal-records
      #
      # Frequency limit:10 times/1s (User ID)
      # Note: This endpoint retrieves withdrawal records for the account
      #
      # @param coin [String] Optional. Filter by cryptocurrency code e.g. 'BTC', 'USDT'
      # @param client_order_id [String] Optional. Filter by client order ID
      # @param start_time [Integer] Required. Filter by start time in milliseconds
      # @param end_time [Integer] Optional. Filter by end time in milliseconds
      # @param id_less_than [Integer] Optional. Filter by records with ID less than this value
      # @param order_id [String] Optional. Filter by withdrawal order ID
      # @param limit [Integer] Optional. Number of records to return (default: 100, max: 500)
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Array<Hash>] List of withdrawal records containing:
      #     - orderId [String] Withdrawal order ID
      #     - tradeId [String] Trade ID
      #     - coin [String] Cryptocurrency code
      #     - dest [String] Destination type
      #     - clientOid [String] Client order ID if provided
      #     - type [String] Operation type (e.g. 'withdraw')
      #     - tag [String] Memo/Tag if applicable
      #     - size [String] Withdrawal amount
      #     - fee [String] Withdrawal fee
      #     - status [String] Withdrawal status (e.g. 'success')
      #     - toAddress [String] Destination address
      #     - fromAddress [String] Source address
      #     - confirm [String] Number of confirmations
      #     - chain [String] Blockchain network
      #     - cTime [String] Creation timestamp
      #     - uTime [String] Last update timestamp
      def spot_wallet_withdrawal_records(coin: nil, client_order_id: nil, start_time:, end_time:, id_less_than: nil, order_id: nil, limit: nil)
        response = get(
          path: '/spot/wallet/withdrawal-records',
          args: {
            coin: coin,
            clientOid: client_order_id,
            startTime: start_time,
            endTime: end_time,
            idLessThan: id_less_than,
            orderId: order_id,
            limit: limit,
          }
        )
        handle_response(response)
      end

      # Get Deposit Records
      # GET /api/v2/spot/wallet/deposit-records
      #
      # Frequency limit:10 times/1s (UID)
      # Note: This endpoint retrieves deposit records for the account
      #
      # @param coin [String] Optional. Filter by cryptocurrency code e.g. 'BTC', 'USDT'
      # @param order_id [String] Optional. Filter by deposit order ID
      # @param start_time [Integer] Required. Filter by start time in milliseconds
      # @param end_time [Integer] Required. Filter by end time in milliseconds
      # @param id_less_than [Integer] Optional. Filter by records with ID less than this value
      # @param limit [Integer] Optional. Number of records to return (default: 100, max: 500)
      # @return [Hash] Response containing:
      #   - code [String] Response code, '00000' means success
      #   - msg [String] Response message
      #   - requestTime [Integer] Request timestamp
      #   - data [Array<Hash>] List of deposit records containing:
      #     - orderId [String] Deposit order ID
      #     - tradeId [String] TX ID
      #     - coin [String] Cryptocurrency code
      #     - type [String] 'deposit'
      #     - size [String] Quantity
      #     - status [String] Deposit status (e.g. 'success')
      #     - toAddress [String] Chain address if dest is on_chain or UID, email, or phone number if dest is internal_transfer
      #     - dest [String] Destination type (e.g. 'on_chain')
      #     - chain [String] Blockchain network
      #     - fromAddress [String] Chain address if dest is on_chain or UID, email, or phone number if dest is internal_transfer
      #     - cTime [String] Creation timestamp
      #     - uTime [String] Last update timestamp
      def spot_wallet_deposit_records(coin: nil, order_id: nil, start_time:, end_time:, id_less_than: nil, limit: nil)
        response = get(
          path: '/spot/wallet/deposit-records',
          args: {
            coin: coin,
            orderId: order_id,
            startTime: start_time,
            endTime: end_time,
            idLessThan: id_less_than,
            limit: limit,
          }
        )
        handle_response(response)
      end

      attr_accessor\
        :api_key,
        :api_secret,
        :api_passphrase,
        :use_logging

      private

      def initialize(api_key:, api_secret:, api_passphrase:, use_logging: false)
        @api_key = api_key
        @api_secret = api_secret
        @api_passphrase = api_passphrase
        @use_logging = use_logging
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
            query_string = args.x_www_form_urlencode
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

      def log_request(verb:, request_string:, args:, headers:)
        log_string = "#{verb} #{request_string}\n"
        if log_args?(args)
          log_string << "  Args: #{args}\n"
        end
        log_string << "  Headers: #{headers}\n"
        self.class.logger.info(log_string)
      end

      def log_response(code:, message:, body:)
        log_string = "Code: #{code}\n"
        log_string << "Message: #{message}\n"
        log_string << "Body: #{body}\n"
        self.class.logger.info(log_string)
      end

      def log_error(code:, message:, body:)
        log_string = "Code: #{code}\n"
        log_string << "Message: #{message}\n"
        log_string << "Body: #{body}\n"
        self.class.logger.error(log_string)
      end

      def do_request(verb:, path:, args: {})
        sorted_args = args.reject{|_, v| v.nil?}.sort.to_h
        message = message(verb: verb, path: path, args: sorted_args)
        signature = signature(message)
        headers = headers(signature)
        log_request(verb: verb, request_string: request_string(path), args: sorted_args, headers: headers) if @use_logging
        @timestamp = nil
        HTTP.send(verb.to_s.downcase, request_string(path), sorted_args, headers)
      end

      def get(path:, args: {})
        do_request(verb: 'GET', path: path, args: args)
      end

      def post(path:, args: {})
        do_request(verb: 'POST', path: path, args: args)
      end

      def handle_response(response)
        if response.success?
          parsed_body = JSON.parse(response.body)
          log_response(
            code: response.code,
            message: response.message,
            body: response.body
          ) if @use_logging
          parsed_body
        else
          log_error(
            code: response.code,
            message: response.message,
            body: response.body
          ) if @use_logging
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
