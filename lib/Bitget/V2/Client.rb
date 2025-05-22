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
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves information about supported cryptocurrencies
      #
      # @param coin [String] Optional. Filter by cryptocurrency code e.g. 'BTC', 'USDT'
      # @return [Hash] Response containing array of:
      #   - coin [String] Cryptocurrency code
      #   - name [String] Full name of the cryptocurrency
      #   - chains [Array] List of supported blockchain networks
      #   - minDepositAmount [String] Minimum deposit amount
      #   - withdrawalMinFee [String] Minimum withdrawal fee
      #   - withdrawalMaxFee [String] Maximum withdrawal fee
      #   - precision [Integer] Number of decimal places
      #   - withdrawalPrecision [Integer] Withdrawal amount precision
      #   - minWithdrawAmount [String] Minimum withdrawal amount
      #   - maxWithdrawAmount [String] Maximum withdrawal amount
      #   - withdrawDisabled [Boolean] Whether withdrawals are disabled
      #   - depositDisabled [Boolean] Whether deposits are disabled
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
      # @return [Hash] Response containing array of:
      #   - symbol [String] Trading pair name
      #   - baseCoin [String] Base currency code
      #   - quoteCoin [String] Quote currency code
      #   - minTradeAmount [String] Minimum trade amount
      #   - maxTradeAmount [String] Maximum trade amount
      #   - takerFeeRate [String] Taker fee rate
      #   - makerFeeRate [String] Maker fee rate
      #   - priceScale [Integer] Price precision (decimal places)
      #   - quantityScale [Integer] Quantity precision (decimal places)
      #   - status [String] Trading pair status
      #   - buyLimitPriceRatio [String] Maximum buy price ratio
      #   - sellLimitPriceRatio [String] Maximum sell price ratio
      def spot_public_symbols(symbol: nil)
        response = get(path: '/spot/public/symbols', args: {symbol: symbol})
        handle_response(response)
      end

      # Get VIP Fee Rate
      # GET /api/v2/spot/market/vip-fee-rate
      #
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves the current VIP fee rates for the user
      #
      # @return [Hash] Response containing:
      #   - level [Integer] VIP level
      #   - maker [String] Maker fee rate for this level
      #   - taker [String] Taker fee rate for this level
      #   - makerUSDT [String] Maker fee rate in USDT
      #   - takerUSDT [String] Taker fee rate in USDT
      #   - takerBonus [String] Taker bonus rate
      #   - makerBonus [String] Maker bonus rate
      def spot_market_vip_free_rate
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
      # @return [Hash] Response containing array of:
      #   - symbol [String] Trading pair name
      #   - high24h [String] Highest price in last 24 hours
      #   - low24h [String] Lowest price in last 24 hours
      #   - close [String] Latest price
      #   - quoteVol [String] Quote currency volume in last 24 hours
      #   - baseVol [String] Base currency volume in last 24 hours
      #   - usdtVol [String] Volume in USDT equivalent
      #   - ts [Integer] Timestamp in milliseconds
      #   - buyOne [String] Best bid price
      #   - sellOne [String] Best ask price
      #   - bid1Price [String] Best bid price (same as buyOne)
      #   - ask1Price [String] Best ask price (same as sellOne)
      #   - bid1Vol [String] Best bid volume
      #   - ask1Vol [String] Best ask volume
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
      #   - symbol [String] Trading pair name
      #   - precision [String] Price aggregation level used
      #   - ts [Integer] Timestamp in milliseconds
      #   - bids [Array] Array of bid orders [price, size]
      #   - asks [Array] Array of ask orders [price, size]
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
      #   - symbol [String] Trading pair name
      #   - ts [Integer] Timestamp in milliseconds
      #   - checksum [Integer] Order book checksum
      #   - bids [Array] Array of bid orders [price, size, liquidated_orders, order_numbers]
      #   - asks [Array] Array of ask orders [price, size, liquidated_orders, order_numbers]
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
      # @return [Hash] Response containing array of candles, each with:
      #   - ts [Integer] Timestamp in milliseconds
      #   - open [String] Opening price
      #   - high [String] Highest price
      #   - low [String] Lowest price
      #   - close [String] Closing price
      #   - baseVol [String] Base currency volume
      #   - quoteVol [String] Quote currency volume
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
      # @return [Hash] Response containing array of candles, each with:
      #   - ts [Integer] Timestamp in milliseconds
      #   - open [String] Opening price
      #   - high [String] Highest price
      #   - low [String] Lowest price
      #   - close [String] Closing price
      #   - baseVol [String] Base currency volume
      #   - usdtVol [String] USDT volume
      #   - quoteVol [String] Quote currency volume
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
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves recent trades for a trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. BTCUSDT
      # @param limit [Integer] Optional. Number of trades to return (default: 100)
      # @return [Hash] Response containing array of trades, each with:
      #   - tradeId [String] Trade ID
      #   - price [String] Trade price
      #   - size [String] Trade size
      #   - side [String] Trade side (buy/sell)
      #   - ts [Integer] Timestamp in milliseconds
      def spot_market_fills(symbol:, limit: nil)
        response = get(path: '/spot/market/fills', args: {symbol: symbol, limit: limit})
        handle_response(response)
      end

      # Get Market Trades
      # GET /api/v2/spot/market/fills-history
      #
      # Rate Limit: 20 times/1s (IP)
      # Note: This endpoint retrieves historical trades for a trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. BTCUSDT
      # @param limit [Integer] Optional. Number of trades to return (default: 100)
      # @param id_less_than [String] Optional. Return trades with ID less than this value
      # @param start_time [Integer] Optional. Start time in Unix milliseconds
      # @param end_time [Integer] Optional. End time in Unix milliseconds
      # @return [Hash] Response containing array of trades, each with:
      #   - tradeId [String] Trade ID
      #   - price [String] Trade price
      #   - size [String] Trade size
      #   - side [String] Trade side (buy/sell)
      #   - ts [Integer] Timestamp in milliseconds
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
      # Rate Limit: 100 times/2s with user ID
      # Note: This endpoint places a new order for spot trading
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param side [String] Required. Order direction: 'buy' or 'sell'
      # @param order_type [String] Required. Order type:
      #   - limit: Limit order
      #   - market: Market order
      #   - post_only: Post only order
      #   - fok: Fill or kill order
      #   - ioc: Immediate or cancel order
      # @param force [String] Required. Time in force:
      #   - gtc: Good till cancelled
      #   - ioc: Immediate or cancel
      #   - fok: Fill or kill
      #   - post_only: Post only
      # @param price [String] Required for limit orders. Order price
      # @param size [String] Required. Order size
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param trigger_price [String] Optional. Required for stop orders. Trigger price
      # @param tpsl_type [String] Optional. Take profit/stop loss type: 'normal' or 'tpsl'
      # @param request_time [Integer] Optional. Request timestamp in milliseconds
      # @param receive_window [Integer] Optional. Number of milliseconds after timestamp the request is valid for
      # @param stp_mode [String] Optional. Self-trade prevention mode:
      #   - none: No self-trade prevention
      #   - cancel_taker: Cancel taker order
      #   - cancel_maker: Cancel maker order
      #   - cancel_both: Cancel both orders
      # @param preset_take_profit_price [String] Optional. Preset take profit price
      # @param execute_take_profit_price [String] Optional. Execute take profit price
      # @param preset_stop_loss_price [String] Optional. Preset stop loss price
      # @param execute_stop_loss_price [String] Optional. Execute stop loss price
      # @return [Hash] Response containing:
      #   - orderId [String] Order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status
      #   - side [String] Order side (buy/sell)
      #   - orderType [String] Order type
      #   - force [String] Time in force
      #   - price [String] Order price
      #   - size [String] Order size
      #   - filledSize [String] Filled size
      #   - filledAmount [String] Filled amount
      #   - avgPrice [String] Average fill price
      #   - fee [String] Trading fee
      #   - feeCoin [String] Fee currency
      #   - cTime [String] Creation time
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
      # Rate Limit: 100 times/2s with user ID
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
      #   - orderId [String] New order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status
      #   - cancelResult [String] Result of canceling the old order
      #   - newOrderResult [String] Result of placing the new order
      #   - oldOrderId [String] ID of the cancelled order
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
      # Rate Limit: 50 times/2s with user ID
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
      # @return [Hash] Response containing array of results, each with:
      #   - orderId [String] New order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status
      #   - cancelResult [String] Result of canceling the old order
      #   - newOrderResult [String] Result of placing the new order
      #   - oldOrderId [String] ID of the cancelled order
      #   - code [String] Result code
      #   - msg [String] Result message
      def spot_trade_batch_cancel_replace_order(order_list:)
        response = post(path: '/spot/trade/batch-cancel-replace-order', args: {orderList: order_list})
        handle_response(response)
      end

      # Cancel Order
      # POST /api/v2/spot/trade/cancel-order
      #
      # Rate Limit: 100 times/2s with user ID
      # Note: This endpoint cancels an existing order
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param tpsl_type [String] Optional. Take profit/stop loss type: 'normal' or 'tpsl'
      # @param order_id [String] Optional. Order ID to cancel
      # @param client_order_id [String] Optional. Client order ID to cancel
      #   Note: Either order_id or client_order_id must be provided
      # @return [Hash] Response containing:
      #   - orderId [String] Order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status ('cancelled')
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
      # Rate Limit: 50 times/2s with user ID
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
      # @return [Hash] Response containing array of results:
      #   - orderId [String] Order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status
      #   - code [String] Result code
      #   - msg [String] Result message
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
      # Rate Limit: 50 times/2s with user ID
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
      # @return [Hash] Response containing array of results, each with:
      #   - orderId [String] Order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status ('cancelled')
      #   - code [String] Result code
      #   - msg [String] Result message
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
      # Rate Limit: 100 times/2s with user ID
      # Note: This endpoint cancels all orders for a specific trading pair
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @return [Hash] Response containing:
      #   - result [Boolean] Whether the cancellation was successful
      #   - symbol [String] Trading pair name
      #   - code [String] Result code
      #   - msg [String] Result message
      def spot_trade_cancel_symbol_order(symbol:)
        response = post(path: '/spot/trade/cancel-symbol-order', args: {symbol: symbol})
        handle_response(response)
      end

      # Get Order Info
      # GET /api/v2/spot/trade/orderInfo
      #
      # Rate Limit: 20 times/2s with user ID
      # Note: This endpoint retrieves detailed information about a specific order
      #
      # @param order_id [String] Optional. Order ID to query
      # @param client_order_id [String] Optional. Client order ID to query
      #   Note: Either order_id or client_order_id must be provided
      # @param request_time [Integer] Optional. Current timestamp in milliseconds
      # @param receive_window [Integer] Optional. The value cannot be greater than 60000
      # @return [Hash] Response containing:
      #   - orderId [String] Order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - baseAsset [String] Base asset
      #   - quoteAsset [String] Quote asset
      #   - orderType [String] Order type
      #   - side [String] Order side ('buy' or 'sell')
      #   - force [String] Time in force
      #   - status [String] Order status
      #   - price [String] Order price
      #   - size [String] Order size
      #   - fillPrice [String] Fill price
      #   - fillSize [String] Fill size
      #   - fillFee [String] Fill fee
      #   - fillFeeCcy [String] Fill fee currency
      #   - cTime [String] Creation time
      #   - uTime [String] Update time
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
      # Rate Limit: 20 times/2s with user ID
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
      # @return [Hash] Response containing array of orders, each with:
      #   - orderId [String] Order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - baseAsset [String] Base asset
      #   - quoteAsset [String] Quote asset
      #   - orderType [String] Order type
      #   - side [String] Order side ('buy' or 'sell')
      #   - force [String] Time in force
      #   - status [String] Order status
      #   - price [String] Order price
      #   - size [String] Order size
      #   - fillPrice [String] Fill price
      #   - fillSize [String] Fill size
      #   - fillFee [String] Fill fee
      #   - fillFeeCcy [String] Fill fee currency
      #   - cTime [String] Creation time
      #   - uTime [String] Update time
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
      # Rate Limit: 20 times/2s with user ID
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
      # @return [Hash] Response containing array of orders, each with:
      #   - orderId [String] Order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - baseAsset [String] Base asset
      #   - quoteAsset [String] Quote asset
      #   - orderType [String] Order type
      #   - side [String] Order side ('buy' or 'sell')
      #   - force [String] Time in force
      #   - status [String] Order status
      #   - price [String] Order price
      #   - size [String] Order size
      #   - fillPrice [String] Fill price
      #   - fillSize [String] Fill size
      #   - fillFee [String] Fill fee
      #   - fillFeeCcy [String] Fill fee currency
      #   - cTime [String] Creation time
      #   - uTime [String] Update time
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
      # Rate Limit: 20 times/2s with user ID
      # Note: This endpoint retrieves trade execution details for orders
      #
      # @param symbol [String] Optional. Trading pair name e.g. 'BTCUSDT'
      # @param order_id [String] Optional. Filter by order ID
      # @param start_time [Integer] Optional. Start timestamp in milliseconds
      # @param end_time [Integer] Optional. End timestamp in milliseconds
      # @param limit [Integer] Optional. Number of results per request. Maximum 100. Default 100
      # @param id_less_than [String] Optional. Pagination of data to return records earlier than the requested fillId
      # @return [Hash] Response containing array of fills, each with:
      #   - fillId [String] Fill ID
      #   - orderId [String] Order ID
      #   - symbol [String] Trading pair
      #   - side [String] Trade side ('buy' or 'sell')
      #   - fillPrice [String] Fill price
      #   - fillSize [String] Fill size
      #   - fillValue [String] Fill value (fillPrice * fillSize)
      #   - fillFee [String] Fill fee
      #   - fillFeeCcy [String] Fill fee currency
      #   - cTime [String] Creation time
      #   - feeCcy [String] Fee currency
      #   - feeRate [String] Fee rate
      #   - makerTaker [String] Whether the fill was maker or taker
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
      # Rate Limit: 100 times/2s with user ID
      # Note: This endpoint places a trigger/plan order that executes when price conditions are met
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param side [String] Required. Order direction: 'buy' or 'sell'
      # @param trigger_price [String] Required. Price to trigger the order
      # @param order_type [String] Required. Order type: 'limit' or 'market'
      # @param execute_price [String] Optional. Order execution price (required for limit orders)
      # @param plan_type [String] Optional. Plan type: 'limit' or 'market'
      # @param size [String] Required. Order quantity
      # @param trigger_type [String] Optional. Trigger type: 'market_price' (default)
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param stp_mode [String] Optional. STP mode: 'cancel_maker', 'cancel_taker', or 'cancel_both'
      # @return [Hash] Response containing:
      #   - orderId [String] Plan order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status
      #   - triggerPrice [String] Price that triggers the order
      #   - executePrice [String] Price to execute at once triggered
      #   - size [String] Order size
      #   - orderType [String] Order type
      #   - planType [String] Plan type
      #   - side [String] Order side ('buy' or 'sell')
      #   - triggerType [String] Trigger type
      #   - cTime [String] Creation time
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
      # Rate Limit: 100 times/2s with user ID
      # Note: This endpoint modifies an existing trigger/plan order
      #
      # @param order_id [String] Required. Order ID to modify
      # @param trigger_price [String] Optional. New trigger price
      # @param execute_price [String] Optional. New execution price
      # @param size [String] Optional. New order quantity
      # @param order_type [String] Optional. Order type: 'limit' or 'market'
      # @return [Hash] Response containing:
      #   - orderId [String] Plan order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status
      #   - triggerPrice [String] Updated trigger price
      #   - executePrice [String] Updated execution price
      #   - size [String] Updated order size
      #   - orderType [String] Updated order type
      #   - planType [String] Plan type
      #   - side [String] Order side ('buy' or 'sell')
      #   - triggerType [String] Trigger type
      #   - cTime [String] Creation time
      #   - uTime [String] Update time
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
      # Rate Limit: 100 times/2s with user ID
      # Note: This endpoint cancels an existing trigger/plan order
      #
      # @param order_id [String] Required. Plan order ID to cancel
      # @return [Hash] Response containing:
      #   - orderId [String] Plan order ID that was cancelled
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status after cancellation
      #   - triggerPrice [String] Trigger price of the cancelled order
      #   - executePrice [String] Execution price of the cancelled order
      #   - size [String] Order size
      #   - orderType [String] Order type
      #   - planType [String] Plan type
      #   - side [String] Order side ('buy' or 'sell')
      #   - triggerType [String] Trigger type
      #   - cTime [String] Creation time
      #   - uTime [String] Update time
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
      # Rate Limit: 20 times/2s with user ID
      # Note: This endpoint retrieves all active trigger/plan orders
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param order_type [String] Optional. Order type: 'limit' or 'market'
      # @param side [String] Optional. Order direction: 'buy' or 'sell'
      # @param start_time [Integer] Optional. Start time in Unix milliseconds
      # @param end_time [Integer] Optional. End time in Unix milliseconds
      # @param limit [Integer] Optional. Number of results per request. Maximum 100. Default 100
      # @return [Hash] Response containing array of plan orders, each with:
      #   - orderId [String] Plan order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status
      #   - triggerPrice [String] Price that triggers the order
      #   - executePrice [String] Price to execute at once triggered
      #   - size [String] Order size
      #   - orderType [String] Order type
      #   - planType [String] Plan type
      #   - side [String] Order side ('buy' or 'sell')
      #   - triggerType [String] Trigger type
      #   - cTime [String] Creation time
      #   - uTime [String] Update time
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
      # Rate Limit: 20 times/2s with user ID
      # Note: This endpoint retrieves the executed sub-orders of a trigger/plan order
      #
      # @param order_id [String] Required. Plan order ID to query
      # @return [Hash] Response containing array of sub-orders, each with:
      #   - orderId [String] Sub-order ID
      #   - price [String] Order price
      #   - type [String] Order type
      #   - status [String] Order status
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
      # Rate Limit: 20 times/2s with user ID
      # Note: This endpoint retrieves historical trigger/plan orders (executed, cancelled, etc.)
      #
      # @param symbol [String] Required. Trading pair name e.g. 'BTCUSDT'
      # @param start_time [Integer] Required. Start time in Unix milliseconds
      # @param end_time [Integer] Required. End time in Unix milliseconds
      # @param limit [Integer] Optional. Number of results per request. Maximum 100. Default 100
      # @return [Hash] Response containing array of historical plan orders, each with:
      #   - orderId [String] Plan order ID
      #   - clientOid [String] Client order ID if provided
      #   - symbol [String] Trading pair
      #   - status [String] Order status
      #   - triggerPrice [String] Price that triggered the order
      #   - executePrice [String] Execution price
      #   - size [String] Order size
      #   - orderType [String] Order type
      #   - planType [String] Plan type
      #   - side [String] Order side ('buy' or 'sell')
      #   - triggerType [String] Trigger type
      #   - cTime [String] Creation time
      #   - uTime [String] Update time
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
      # Rate Limit: 100 times/2s with user ID
      # Note: This endpoint cancels all trigger/plan orders for the specified trading pairs
      #
      # @param symbol_list [Array<String>] Required. List of trading pair names e.g. ['BTCUSDT', 'ETHUSDT']
      # @return [Hash] Response containing:
      #   - success [Boolean] Whether the operation was successful
      #   - data [Array] List of cancelled orders, each with:
      #     - orderId [String] Plan order ID that was cancelled
      #     - clientOid [String] Client order ID if provided
      #     - symbol [String] Trading pair
      #     - status [String] Order status after cancellation
      #     - triggerPrice [String] Trigger price of the cancelled order
      #     - executePrice [String] Execution price of the cancelled order
      #     - size [String] Order size
      #     - orderType [String] Order type
      #     - planType [String] Plan type
      #     - side [String] Order side ('buy' or 'sell')
      #     - triggerType [String] Trigger type
      #     - cTime [String] Creation time
      #     - uTime [String] Update time
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
      # Rate Limit: 10 times/2s with user ID
      # Note: This endpoint retrieves basic information about the user's spot account
      #
      # @return [Hash] Response containing:
      #   - userId [String] User ID
      #   - username [String] Username
      #   - email [String] User's email address
      #   - accountType [String] Account type
      #   - marginMode [String] Margin mode ('isolated' or 'crossed')
      #   - marginCoefficient [String] Margin coefficient
      #   - canTrade [Boolean] Whether trading is enabled
      #   - canDeposit [Boolean] Whether deposits are enabled
      #   - canWithdraw [Boolean] Whether withdrawals are enabled
      #   - cTime [String] Account creation time
      def spot_account_info
        response = get(path: '/spot/account/info')
        handle_response(response)
      end

      # Get Account Assets
      # GET /api/v2/spot/account/assets
      #
      # Rate Limit: 10 times/2s with user ID
      # Note: This endpoint retrieves detailed balance information for all assets in the spot account
      #
      # @param coin [String] Optional. Cryptocurrency code e.g. 'BTC'
      # @param asset_type [String] Optional. Type of asset
      # @return [Array] List of account assets with the following fields:
      #   - coinId [String] The ID of the coin
      #   - coinName [String] The name of the coin in lowercase
      #   - coinDisplayName [String] The display name of the coin
      #   - available [String] Available balance
      #   - frozen [String] Frozen balance
      #   - lock [String] Locked balance
      #   - uTime [String] Last update time in Unix milliseconds
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
      # Rate Limit: 2 times/2s with user ID
      # Note: This endpoint retrieves asset information for all sub-accounts
      # Returns only sub-accounts which have assets > 0
      # Note: ND Brokers are not allowed to call this endpoint
      #
      # @param is_less_than [String] Optional.
      # @param limit [String] Optional.
      # @return [Hash] Response containing array of sub-accounts, each with:
      #   - userId [String] Sub-account user ID
      #   - username [String] Sub-account username
      #   - assets [Array] List of assets, each containing:
      #     - coinId [String] The ID of the coin
      #     - coinName [String] The name of the coin in lowercase
      #     - available [String] Available balance
      #     - frozen [String] Frozen balance
      #     - lock [String] Locked balance
      #     - uTime [String] Last update time in Unix milliseconds
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
      # Rate Limit: 5 times/2s with user ID
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
      #   - success [Boolean] Whether the modification was successful
      #   - code [String] Result code
      #   - msg [String] Result message
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
      # Rate Limit: 10 times/2s with user ID
      # Note: This endpoint retrieves the account's transaction history including deposits, withdrawals, trades, etc.
      #
      # @param coin [String] Optional. Cryptocurrency code e.g. 'BTC'
      # @param group_type [String] Optional. Bill group type e.g. 'deposit', 'withdraw'
      # @param business_type [String] Optional. Business type e.g. 'spot', 'margin'
      # @param start_time [Integer] Optional. Filter by start time in milliseconds
      # @param end_time [Integer] Optional. Filter by end time in milliseconds
      # @param limit [Integer] Optional. Number of records to return (default: 100, max: 500)
      # @param request_time [Integer] Optional. Request timestamp in milliseconds
      # @return [Hash] Response containing array of:
      #   - id [Integer] Bill ID
      #   - coin [String] Cryptocurrency code
      #   - amount [String] Transaction amount
      #   - fee [String] Transaction fee if applicable
      #   - balance [String] Account balance after transaction
      #   - accountType [String] Account type
      #   - groupType [String] Bill group type
      #   - businessType [String] Business type
      #   - cTime [String] Creation time
      def spot_account_bills(coin: nil, group_type: nil, business_type: nil, start_time: nil, end_time: nil, limit: nil, request_time: nil)
        response = get(
          path: '/spot/account/bills',
          args: {
            coin: coin,
            groupType: group_type,
            businessType: business_type,
            startTime: start_time,
            endTime: end_time,
            limit: limit,
            requestTime: request_time,
          }
        )
        handle_response(response)
      end

      # Transfer
      # POST /api/v2/spot/wallet/transfer
      #
      # Rate Limit: 5/sec (uid)
      # Note: This endpoint transfers assets between different account types within Bitget
      # Note: Only available for main accounts, not sub-accounts
      #
      # @param from_type [String] Required. Source account type. Valid values:
      #   - 'spot': Spot account (accepts all coins)
      #   - 'mix_usdt': USDT-M futures account (only USDT)
      #   - 'mix_usd': USD-M futures account (BTC, ETH, EOS, XRP, USDC)
      #   - 'mix_usdc': USDC-M futures account (only USDC)
      #   - 'margin_cross': Cross-margin account (supported spot coins)
      #   - 'margin_isolated': Isolated-margin account (supported spot coins)
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
      # Rate Limit: 5 times/2s with user ID
      # Note: This endpoint retrieves the list of coins that can be transferred between specified account types
      #
      # @param from_type [String] Required. Source account type. Valid values:
      #   - 'spot': Spot account (accepts all coins)
      #   - 'mix_usdt': USDT-M futures account (only USDT)
      #   - 'mix_usd': USD-M futures account (BTC, ETH, EOS, XRP, USDC)
      #   - 'mix_usdc': USDC-M futures account (only USDC)
      #   - 'margin_cross': Cross-margin account (supported spot coins)
      #   - 'margin_isolated': Isolated-margin account (supported spot coins)
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
      # Rate Limit: 2/sec (uid)
      # Note: This endpoint requires IP whitelist. Transfer between fromUserId and toUserId
      # should have direct/brother relationship.
      #
      # @param from_type [String] Required. Source account type. Valid values:
      #   - 'spot': Spot account (accepts all coins)
      #   - 'p2p': P2P/Funding account
      #   - 'coin_futures': Coin-M futures account
      #   - 'usdt_futures': USDT-M futures account
      #   - 'usdc_futures': USDC-M futures account
      #   - 'cross_margin': Cross-margin account (supported spot coins)
      #   - 'isolated_margin': Isolated-margin account (supported spot coins)
      # @param to_type [String] Required. Destination account type (same valid values as from_type)
      # @param amount [String] Required. Amount to transfer
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param symbol [String] Optional. Trading pair symbol e.g. 'BTCUSDT'
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param from_user_id [String] Optional. Source user ID. Required for cross-user transfers
      # @param to_user_id [String] Optional. Destination user ID. Required for cross-user transfers
      # @return [Hash] Response indicating success or failure
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
      # Rate Limit: 2/sec (uid)
      # Note: This endpoint requires withdrawal permission and IP whitelist.
      #
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param transfer_type [String] Required. Type of withdrawal. Valid values:
      #   - 'on_chain': Withdraw to external address
      #   - 'internal_transfer': Internal transfer
      # @param address [String] Required. Withdrawal address
      # @param chain [String] Optional. Blockchain network e.g. 'BTC-Bitcoin', 'ETH-ERC20'
      # @param inner_to_type [String] Optional. Target account type for internal transfers. Valid values:
      #   - 'spot': Spot account
      #   - 'mix_usdt': USDT-M futures account
      #   - 'mix_usd': USD-M futures account
      #   - 'mix_usdc': USDC-M futures account
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
      #   - OrderId [String] Withdrawal ID
      #   - clientOid [String]
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
      # Rate Limit: 20 times/1s (uid)
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
      #   - coin [String]
      #   - status [String] Transfer status
      #   - toType [String]
      #   - fromType [String]
      #   - size [String]
      #   - ts [String] Timestamp
      #   - clientOid [String] Client order ID
      #   - transferId [String] Transfer ID
      #   - fromUserId [String] Source account ID
      #   - toUserId [String] Target account ID
      def spot_account_sub_main_trans_record(coin: nil, role: nil, subaccount_user_id: nil, start_time: nil, end_time: nil, client_order_id: nil, limit: nil, id_less_than: nil)
        response = get(
          path: '/spot/account/sub-main-trans-record',
          args: {
            coinId: coin,
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
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint retrieves transfer records between different account types
      #
      # @param coin [String] Optional. Cryptocurrency code e.g. 'BTC'
      # @param from_type [String] Optional. Source account type. Valid values:
      #   - 'exchange': Spot account
      #   - 'usdt_mix': USDT-M futures account
      #   - 'usdc_mix': USDC-M futures account
      #   - 'usd_mix': Coin-M futures account
      #   - 'margin_cross': Cross margin account
      #   - 'margin_isolated': Isolated margin account
      # @param start_time [Integer] Optional. Start time in Unix milliseconds
      # @param end_time [Integer] Optional. End time in Unix milliseconds
      # @param client_order_id [String] Optional. Client-supplied order ID
      # @param page_number [Integer] Optional. Page number for pagination
      # @param limit [Integer] Optional. Number of results per request. Default: 100
      # @param id_less_than [String] Optional. Filter records with ID less than this value
      # @return [Hash] Response containing:
      #   - coinName [String] Cryptocurrency code
      #   - status [String] Transfer status
      #   - toType [String] Target account type
      #   - toSymbol [String] Target symbol
      #   - fromType [String] Source account type
      #   - fromSymbol [String] Source symbol
      #   - amount [String] Transfer amount
      #   - tradeTime [String] Transfer timestamp
      #   - clientOid [String] Client order ID
      #   - transferId [String] Transfer ID
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
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint enables or disables BGB fee deduction for spot trading
      #
      # @param deduct [String] Required. Whether to enable BGB fee deduction. Valid values:
      #   - 'on': Enable BGB fee deduction
      #   - 'off': Disable BGB fee deduction
      # @return [Hash] Response containing:
      #   - deduct [String] Current BGB fee deduction status ('on' or 'off')
      #   - cTime [String] Last update timestamp
      def spot_account_switch_deduct(deduct:)
        response = post(path: '/spot/account/switch-deduct', args: {deduct: deduct})
        handle_response(response)
      end

      # Get Deposit Address
      # GET /api/v2/spot/wallet/deposit-address
      #
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint retrieves the deposit address for a specific cryptocurrency
      #
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param chain [String] Optional. Blockchain network e.g. 'BTC-Bitcoin', 'ETH-ERC20'
      # @param size [Integer] Optional. Number of addresses to generate
      # @return [Hash] Response containing:
      #   - coin [String] Cryptocurrency code
      #   - chain [String] Blockchain network
      #   - address [String] Deposit address
      #   - tag [String] Memo/Tag if required by the coin
      #   - url [String] Optional QR code URL
      #   - size [Integer] Number of addresses generated if size parameter was used
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
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint retrieves the deposit address for a specific cryptocurrency in a sub-account
      #
      # @param subaccount_user_id [String] Required. Sub-account user ID (uid)
      # @param coin [String] Required. Cryptocurrency code e.g. 'BTC', 'USDT'
      # @param chain [String] Optional. Blockchain network e.g. 'BTC-Bitcoin', 'ETH-ERC20'
      # @param size [Integer] Optional. Number of addresses to generate
      # @return [Hash] Response containing:
      #   - coin [String] Cryptocurrency code
      #   - chain [String] Blockchain network
      #   - address [String] Deposit address
      #   - tag [String] Memo/Tag if required by the coin
      #   - url [String] Optional QR code URL
      #   - size [Integer] Number of addresses generated if size parameter was used
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
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint retrieves the current BGB fee deduction settings
      #
      # @return [Hash] Response containing:
      #   - deduct [String] Current BGB fee deduction status ('on' or 'off')
      #   - cTime [String] Last update timestamp
      def spot_account_deduct_info
        response = get(path: '/spot/account/deduct-info')
        handle_response(response)
      end

      # Cancel Withdrawal
      # POST /api/v2/spot/wallet/cancel-withdrawal
      #
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint cancels a pending withdrawal request
      #
      # @param order_id [String] Required. The withdrawal order ID to cancel
      # @return [Hash] Response containing:
      #   - data [String] success, fail
      def spot_wallet_cancel_withdrawal(order_id:)
        response = post(path: '/spot/wallet/cancel-withdrawal', args: {orderId: order_id})
        handle_response(response)
      end

      # Get SubAccount Deposit Records
      # GET /api/v2/spot/wallet/subaccount-deposit-records
      #
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint retrieves deposit records for a specific sub-account
      #
      # @param subaccount_user_id [String] Required. Sub-account user ID (uid)
      # @param coin [String] Optional. Filter by cryptocurrency code e.g. 'BTC', 'USDT'
      # @param start_time [Integer] Optional. Filter by start time in milliseconds
      # @param end_time [Integer] Optional. Filter by end time in milliseconds
      # @param id_less_than [Integer] Optional. Filter by records with ID less than this value
      # @param limit [Integer] Optional. Number of records to return (default: 100, max: 500)
      # @return [Hash] Response containing:
      #   - id [Integer] Record ID
      #   - coin [String] Cryptocurrency code
      #   - chain [String] Blockchain network
      #   - amount [String] Deposit amount
      #   - address [String] Deposit address
      #   - tag [String] Memo/Tag if applicable
      #   - status [String] Deposit status
      #   - cTime [String] Creation timestamp
      #   - uTime [String] Last update timestamp
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
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint retrieves withdrawal records for the account
      #
      # @param coin [String] Optional. Filter by cryptocurrency code e.g. 'BTC', 'USDT'
      # @param client_order_id [String] Optional. Filter by client order ID
      # @param start_time [Integer] Required. Filter by start time in milliseconds
      # @param end_time [Integer] Optional. Filter by end time in milliseconds
      # @param id_less_than [Integer] Optional. Filter by records with ID less than this value
      # @param order_id [String] Optional. Filter by withdrawal order ID
      # @param limit [Integer] Optional. Number of records to return (default: 100, max: 500)
      # @return [Hash] Response containing array of:
      #   - id [Integer] Record ID
      #   - orderId [String] Withdrawal order ID
      #   - clientOid [String] Client order ID if provided
      #   - coin [String] Cryptocurrency code
      #   - chain [String] Blockchain network
      #   - amount [String] Withdrawal amount
      #   - fee [String] Withdrawal fee
      #   - address [String] Withdrawal address
      #   - tag [String] Memo/Tag if applicable
      #   - status [String] Withdrawal status
      #   - cTime [String] Creation timestamp
      #   - uTime [String] Last update timestamp
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
      # Rate Limit: 20 times/1s (uid)
      # Note: This endpoint retrieves deposit records for the account
      #
      # @param coin [String] Optional. Filter by cryptocurrency code e.g. 'BTC', 'USDT'
      # @param order_id [String] Optional. Filter by deposit order ID
      # @param start_time [Integer] Required. Filter by start time in milliseconds
      # @param end_time [Integer] Required. Filter by end time in milliseconds
      # @param id_less_than [Integer] Optional. Filter by records with ID less than this value
      # @param limit [Integer] Optional. Number of records to return (default: 100, max: 500)
      # @return [Hash] Response containing array of:
      #   - orderId [String] Deposit order ID
      #   - tradeId [String] TX ID
      #   - coin [String] Cryptocurrency code
      #   - type [String] 'deposit'
      #   - size [String] Quantity
      #   - status [String] Deposit status: pending, fail, success.
      #   - fromAddress [String] Chain address if dest is on_chain or UID, email, or phone number if dest is internal_transfer
      #   - toAddress [String] Chain address if dest is on_chain or UID, email, or phone number if dest is internal_transfer
      #   - chain [String] Blockchain network
      #   - dest [String] on_chain, internal_transfer
      #   - cTime [String] Creation timestamp
      #   - uTime [String] Last update timestamp
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
        log_request(verb: verb, request_string: request_string(path), args: sorted_args, headers: headers)
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
