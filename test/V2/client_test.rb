require_relative '../helper'
require_relative '../../lib/Bitget/V2/Client'

describe Bitget::V2::Client do
  let(:client) do
    Bitget::V2::Client.new(
      api_key: ENV.fetch('BITGET_API_KEY', '<API_KEY>'),
      api_secret: ENV.fetch('BITGET_API_SECRET', '<API_SECRET>'),
      api_passphrase: ENV.fetch('BITGET_API_PASSPHRASE', '<API_PASSPHRASE>')
    )
  end

  # Market

  describe "#spot_public_coins" do
    context "when a coin is NOT supplied" do
      it "retrieves a list of all coins" do
        VCR.use_cassette('v2/spot/public/coins-when_coin_is_not_supplied') do
          response = client.spot_public_coins
          _(response).must_include('data')
          _(response['data'].first).must_include('coinId')
          _(response['data'].first).must_include('coin')
          assert_operator response['data'].count, :>, 1500
        end
      end
    end

    context "when a coin IS supplied" do
      it "retrieves one coin" do
        VCR.use_cassette('v2/spot/public/coins-when_coin_is_supplied') do
          response = client.spot_public_coins(coin: 'BTC')
          _(response).must_include('data')
          _(response['data'].first).must_include('coinId')
          _(response['data'].first).must_include('coin')
          _(response['data'].count).must_equal(1)
        end
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/public/coins-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_public_coins
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_public_symbols" do
    context "when a symbol is NOT supplied" do
      it "retrieves a list of all symbols" do
        VCR.use_cassette('v2/spot/public/symbols-when_symbol_is_not_supplied') do
          response = client.spot_public_symbols
          _(response).must_include('data')
          _(response['data'].first).must_include('symbol')
          _(response['data'].first).must_include('baseCoin')
          _(response['data'].first).must_include('quoteCoin')
          assert_operator response['data'].count, :>, 0
        end
      end
    end

    context "when a symbol IS supplied" do
      it "retrieves one symbol" do
        VCR.use_cassette('v2/spot/public/symbols-when_symbol_is_supplied') do
          response = client.spot_public_symbols(symbol: 'BTCUSDT')
          _(response).must_include('data')
          _(response['data'].first).must_include('symbol')
          _(response['data'].first).must_include('baseCoin')
          _(response['data'].first).must_include('quoteCoin')
          _(response['data'].count).must_equal(1)
          _(response['data'].first['symbol']).must_equal('BTCUSDT')
        end
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/public/symbols-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_public_symbols
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_market_vip_free_rate" do
    it "retrieves VIP fee rate information" do
      VCR.use_cassette('v2/spot/market/vip-fee-rate') do
        response = client.spot_market_vip_free_rate
        _(response).must_include('data')
        _(response['data'].first).must_include('level')
        _(response['data'].first).must_include('makerFeeRate')
        _(response['data'].first).must_include('takerFeeRate')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/market/vip-fee-rate-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_market_vip_free_rate
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_market_tickers" do
    context "when a symbol is NOT supplied" do
      it "retrieves all tickers" do
        VCR.use_cassette('v2/spot/market/tickers-when_symbol_is_not_supplied') do
          response = client.spot_market_tickers
          _(response).must_include('data')
          _(response['data'].first).must_include('symbol')
          _(response['data'].first).must_include('high24h')
          _(response['data'].first).must_include('low24h')
          _(response['data'].first).must_include('usdtVolume')
          assert_operator response['data'].count, :>, 0
        end
      end
    end


    context "when a symbol IS supplied" do
      it "retrieves one ticker" do
        VCR.use_cassette('v2/spot/market/tickers-when_symbol_is_supplied') do
          response = client.spot_market_tickers(symbol: 'BTCUSDT')
          _(response).must_include('data')
          _(response['data'].first).must_include('symbol')
          _(response['data'].first).must_include('high24h')
          _(response['data'].first).must_include('low24h')
          _(response['data'].first).must_include('usdtVolume')
          _(response['data'].count).must_equal(1)
          _(response['data'].first['symbol']).must_equal('BTCUSDT')
        end
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/market/tickers-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_market_tickers
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_market_merge_depth" do
    it "retrieves merge depth" do
      VCR.use_cassette('v2/spot/market/merge-depth') do
        response = client.spot_market_merge_depth(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data']).must_include('asks')
        _(response['data']).must_include('bids')
        _(response['data']).must_include('ts')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/market/merge-depth-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_market_merge_depth(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_market_orderbook" do
    it "retrieves orderbook" do
      VCR.use_cassette('v2/spot/market/orderbook') do
        response = client.spot_market_orderbook(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data']).must_include('asks')
        _(response['data']).must_include('bids')
        _(response['data']).must_include('ts')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/market/orderbook-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_market_orderbook(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_market_candles" do
    it "retrieves candles" do
      VCR.use_cassette('v2/spot/market/candles') do
        response = client.spot_market_candles(symbol: 'BTCUSDT', granularity: '1min')
        _(response).must_include('data')
        _(response['data'].first).must_be_kind_of(Array)
        _(response['data'].first.length).must_equal(8) # [timestamp, open, high, low, close, base_volume, usdt_volume, quote_volume]
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/market/candles-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_market_candles(symbol: 'INVALID', granularity: '1min')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_market_history_candles" do
    it "retrieves history candles" do
      VCR.use_cassette('v2/spot/market/history-candles') do
        response = client.spot_market_history_candles(symbol: 'BTCUSDT', granularity: '1min')
        _(response).must_include('data')
        _(response['data'].first).must_be_kind_of(Array)
        _(response['data'].first.length).must_equal(6) # [ts, open, high, low, close, volume]
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/market/history-candles-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_market_history_candles(symbol: 'INVALID', granularity: '1min')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_market_fills" do
    it "retrieves recent trades" do
      VCR.use_cassette('v2/spot/market/fills') do
        response = client.spot_market_fills(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data'].first).must_include('price')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('side')
        _(response['data'].first).must_include('ts')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/market/fills-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_market_fills(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_market_fills_history" do
    it "retrieves market trades history" do
      VCR.use_cassette('v2/spot/market/fills-history') do
        response = client.spot_market_fills_history(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data'].first).must_include('price')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('side')
        _(response['data'].first).must_include('ts')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/market/fills-history-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_market_fills_history(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  # Trade

  describe "#spot_trade_place_order" do
    it "places an order" do
      VCR.use_cassette('v2/spot/trade/place-order') do
        response = client.spot_trade_place_order(
          symbol: 'BTCUSDT',
          side: 'buy',
          order_type: 'limit',
          force: 'normal',
          price: '30000',
          size: '0.001'
        )
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOrderId')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/place-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_place_order(
                symbol: 'INVALID',
                side: 'buy',
                order_type: 'limit',
                force: 'normal',
                price: '30000',
                size: '0.001'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_cancel_replace_order" do
    it "cancels and replaces an order" do
      VCR.use_cassette('v2/spot/trade/cancel-replace-order') do
        response = client.spot_trade_cancel_replace_order(
          symbol: 'BTCUSDT',
          price: '31000',
          size: '0.001',
          order_id: '123456'
        )
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOid')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/cancel-replace-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_cancel_replace_order(
                symbol: 'INVALID',
                price: '31000',
                size: '0.001',
                order_id: '123456'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_batch_cancel_replace_order" do
    it "batch cancels and replaces orders" do
      VCR.use_cassette('v2/spot/trade/batch-cancel-replace-order') do
        orders = [
          {
            symbol: 'BTCUSDT',
            orderId: '123456',
            price: '31000',
            size: '0.001'
          },
          {
            symbol: 'ETHUSDT',
            orderId: '123457',
            price: '2000',
            size: '0.01'
          }
        ]
        response = client.spot_trade_batch_cancel_replace_order(orders: orders)
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/batch-cancel-replace-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_batch_cancel_replace_order(orders: [{symbol: 'INVALID'}])
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_cancel_order" do
    it "cancels an order" do
      VCR.use_cassette('v2/spot/trade/cancel-order') do
        response = client.spot_trade_cancel_order(
          symbol: 'BTCUSDT',
          order_id: '123456'
        )
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOrderId')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/cancel-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_cancel_order(
                symbol: 'INVALID',
                order_id: '123456'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_batch_orders" do
    it "places batch orders" do
      VCR.use_cassette('v2/spot/trade/batch-orders') do
        orders = [
          {
            symbol: 'BTCUSDT',
            side: 'buy',
            orderType: 'limit',
            force: 'normal',
            price: '30000',
            size: '0.001'
          },
          {
            symbol: 'ETHUSDT',
            side: 'buy',
            orderType: 'limit',
            force: 'normal',
            price: '2000',
            size: '0.01'
          }
        ]
        response = client.spot_trade_batch_orders(orders: orders)
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/batch-orders-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_batch_orders(orders: [{symbol: 'INVALID'}])
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_batch_cancel_order" do
    it "cancels batch orders" do
      VCR.use_cassette('v2/spot/trade/batch-cancel-order') do
        response = client.spot_trade_batch_cancel_order(
          symbol: 'BTCUSDT',
          order_ids: ['123456', '123457']
        )
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/batch-cancel-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_batch_cancel_order(
                symbol: 'INVALID',
                order_ids: ['123456', '123457']
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_cancel_symbol_order" do
    it "cancels all orders for a symbol" do
      VCR.use_cassette('v2/spot/trade/cancel-symbol-order') do
        response = client.spot_trade_cancel_symbol_order(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('symbol')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/cancel-symbol-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_cancel_symbol_order(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_order_info" do
    it "retrieves order information" do
      VCR.use_cassette('v2/spot/trade/orderInfo') do
        response = client.spot_trade_order_info(
          symbol: 'BTCUSDT',
          order_id: '123456'
        )
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOrderId')
        _(response['data']).must_include('symbol')
        _(response['data']).must_include('status')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/orderInfo-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_order_info(
                symbol: 'INVALID',
                order_id: '123456'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_unfilled_orders" do
    it "gets unfilled orders" do
      VCR.use_cassette('v2/spot/trade/unfilled-orders') do
        response = client.spot_trade_unfilled_orders(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        # _(response['data'].first).must_include('orderId')
        # _(response['data'].first).must_include('clientOrderId')
        # _(response['data'].first).must_include('symbol')
        # _(response['data'].first).must_include('status')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/unfilled-orders-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_unfilled_orders(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_history_orders" do
    it "gets history orders" do
      VCR.use_cassette('v2/spot/trade/history-orders') do
        response = client.spot_trade_history_orders(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        # _(response['data'].first).must_include('orderId')
        # _(response['data'].first).must_include('clientOrderId')
        # _(response['data'].first).must_include('symbol')
        # _(response['data'].first).must_include('status')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/history-orders-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_history_orders(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_fills" do
    it "gets trade fills" do
      VCR.use_cassette('v2/spot/trade/fills') do
        response = client.spot_trade_fills(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        # _(response['data'].first).must_include('orderId')
        # _(response['data'].first).must_include('symbol')
        # _(response['data'].first).must_include('fillId')
        # _(response['data'].first).must_include('fillPrice')
        # _(response['data'].first).must_include('fillQuantity')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/fills-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_fills(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  # Trigger

  describe "#spot_trade_place_plan_order" do
    it "places a plan order" do
      VCR.use_cassette('v2/spot/trade/place-plan-order') do
        response = client.spot_trade_place_plan_order(
          symbol: 'BTCUSDT',
          side: 'buy',
          order_type: 'limit',
          size: '0.001',
          trigger_price: '30000',
          execute_price: '30000'
        )
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOrderId')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/place-plan-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_place_plan_order(
                symbol: 'INVALID',
                side: 'buy',
                order_type: 'limit',
                size: '0.001',
                trigger_price: '30000',
                execute_price: '30000'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_modify_plan_order" do
    it "modifies a plan order" do
      VCR.use_cassette('v2/spot/trade/modify-plan-order') do
        response = client.spot_trade_modify_plan_order(
          order_id: '123456',
          trigger_price: '31000',
          execute_price: '31000',
          size: '0.002'
        )
        _(response).must_include('data')
        _(response['data']).must_include('success')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/modify-plan-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_modify_plan_order(
                order_id: 'INVALID',
                trigger_price: '31000',
                execute_price: '31000',
                size: '0.002'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_cancel_plan_order" do
    it "cancels a plan order" do
      VCR.use_cassette('v2/spot/trade/cancel-plan-order') do
        response = client.spot_trade_cancel_plan_order(order_id: '123456')
        _(response).must_include('data')
        _(response['data']).must_include('success')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/cancel-plan-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_cancel_plan_order(order_id: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_current_plan_order" do
    it "gets current plan orders" do
      VCR.use_cassette('v2/spot/trade/current-plan-order') do
        response = client.spot_trade_current_plan_order(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('nextFlag')
        _(response['data']).must_include('idLessThan')
        _(response['data']).must_include('orderList')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/current-plan-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_current_plan_order(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_plan_sub_order" do
    it "gets plan sub order" do
      VCR.use_cassette('v2/spot/trade/plan-sub-order') do
        response = client.spot_trade_plan_sub_order(order_id: '123456')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('symbol')
        _(response['data'].first).must_include('status')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/plan-sub-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_plan_sub_order(order_id: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_history_plan_order" do
    it "gets history plan orders" do
      VCR.use_cassette('v2/spot/trade/history-plan-order') do
        response = client.spot_trade_history_plan_order(symbol: 'BTCUSDT')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('symbol')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('triggerPrice')
        _(response['data'].first).must_include('executePrice')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/history-plan-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_history_plan_order(symbol: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_trade_batch_cancel_plan_order" do
    it "cancels batch plan orders" do
      VCR.use_cassette('v2/spot/trade/batch-cancel-plan-order') do
        response = client.spot_trade_batch_cancel_plan_order(
          symbol: 'BTCUSDT',
          order_ids: ['123456', '123457']
        )
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('successList')
        _(response['data']).must_include('failureList')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/trade/batch-cancel-plan-order-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_trade_batch_cancel_plan_order(
                symbol: 'INVALID',
                order_ids: ['123456', '123457']
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  # Account

  describe "#spot_account_info" do
    it "retrieves account information" do
      VCR.use_cassette('v2/spot/account/info') do
        response = client.spot_account_info
        _(response).must_include('data')
        _(response['data']).must_include('userId')
        _(response['data']).must_include('channelCode')
        _(response['data']).must_include('authorities')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/account/info-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_account_info
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_account_assets" do
    it "retrieves account assets" do
      VCR.use_cassette('v2/spot/account/assets') do
        response = client.spot_account_assets
        _(response).must_include('data')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('available')
        _(response['data'].first).must_include('frozen')
        _(response['data'].first).must_include('locked')
        _(response['data'].first).must_include('uTime')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/account/assets-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_account_assets
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_account_subaccount_assets" do
    it "gets subaccount assets" do
      VCR.use_cassette('v2/spot/account/subaccount-assets') do
        response = client.spot_account_subaccount_assets(subaccount_id: '123456')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        # _(response['data'].first).must_include('coin')
        # _(response['data'].first).must_include('available')
        # _(response['data'].first).must_include('frozen')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/account/subaccount-assets-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_account_subaccount_assets(subaccount_id: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_account_bills" do
    it "gets account bills" do
      VCR.use_cassette('v2/spot/account/bills') do
        response = client.spot_account_bills
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('id')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('amount')
        _(response['data'].first).must_include('fee')
        _(response['data'].first).must_include('type')
        _(response['data'].first).must_include('status')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/account/bills-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_account_bills(coin: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_account_sub_main_trans_record" do
    it "gets main-sub transfer records" do
      VCR.use_cassette('v2/spot/account/sub-main-trans-record') do
        response = client.spot_account_sub_main_trans_record
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('id')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('amount')
        _(response['data'].first).must_include('type')
        _(response['data'].first).must_include('status')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/account/sub-main-trans-record-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_account_sub_main_trans_record(subaccount_id: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_account_transfer_records" do
    it "gets transfer records" do
      VCR.use_cassette('v2/spot/account/transferRecords') do
        response = client.spot_account_transfer_records
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('id')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('amount')
        _(response['data'].first).must_include('fromType')
        _(response['data'].first).must_include('toType')
        _(response['data'].first).must_include('status')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/account/transferRecords-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_account_transfer_records(coin: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_account_switch_deduct" do
    it "switches BGB deduct" do
      VCR.use_cassette('v2/spot/account/switch-deduct') do
        response = client.spot_account_switch_deduct(deduct: true)
        _(response).must_include('data')
        _(response['data']).must_include('success')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/account/switch-deduct-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_account_switch_deduct(deduct: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_account_deduct_info" do
    it "gets BGB deduct info" do
      VCR.use_cassette('v2/spot/account/deduct-info') do
        response = client.spot_account_deduct_info
        _(response).must_include('data')
        _(response['data']).must_include('deductEnable')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/account/deduct-info-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_account_deduct_info
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_modify_deposit_account" do
    it "modifies deposit account" do
      VCR.use_cassette('v2/spot/wallet/modify-deposit-account') do
        response = client.spot_wallet_modify_deposit_account(
          coin: 'USDT',
          chain: 'TRC20',
          address: '0x1234567890abcdef'
        )
        _(response).must_include('data')
        _(response['data']).must_include('success')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/modify-deposit-account-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_modify_deposit_account(
                coin: 'INVALID',
                chain: 'INVALID',
                address: '0x1234567890abcdef'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_transfer" do
    it "transfers funds between accounts" do
      VCR.use_cassette('v2/spot/wallet/transfer') do
        response = client.spot_wallet_transfer(
          from_account: 'spot',
          to_account: 'margin',
          coin: 'USDT',
          amount: '100'
        )
        _(response).must_include('data')
        _(response['data']).must_include('success')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/transfer-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_transfer(
                from_account: 'INVALID',
                to_account: 'INVALID',
                coin: 'INVALID',
                amount: '100'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_transfer_coin_info" do
    it "gets transferable coin list" do
      VCR.use_cassette('v2/spot/wallet/transfer-coin-info') do
        response = client.spot_wallet_transfer_coin_info(
          from_account: 'spot',
          to_account: 'margin'
        )
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('coin')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/transfer-coin-info-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_transfer_coin_info(
                from_account: 'INVALID',
                to_account: 'INVALID'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_subaccount_transfer" do
    it "transfers funds between subaccounts" do
      VCR.use_cassette('v2/spot/wallet/subaccount-transfer') do
        response = client.spot_wallet_subaccount_transfer(
          subaccount_id: '123456',
          coin: 'USDT',
          amount: '100',
          direction: 'in'
        )
        _(response).must_include('data')
        _(response['data']).must_include('success')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/subaccount-transfer-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_subaccount_transfer(
                subaccount_id: 'INVALID',
                coin: 'INVALID',
                amount: '100',
                direction: 'INVALID'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_withdrawal" do
    it "withdraws funds" do
      VCR.use_cassette('v2/spot/wallet/withdrawal') do
        response = client.spot_wallet_withdrawal(
          coin: 'USDT',
          chain: 'TRC20',
          address: '0x1234567890abcdef',
          amount: '100'
        )
        _(response).must_include('data')
        _(response['data']).must_include('id')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/withdrawal-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_withdrawal(
                coin: 'INVALID',
                chain: 'INVALID',
                address: '0x1234567890abcdef',
                amount: '100'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_cancel_withdrawal" do
    it "cancels a withdrawal" do
      VCR.use_cassette('v2/spot/wallet/cancel-withdrawal') do
        response = client.spot_wallet_cancel_withdrawal(order_id: '123456')
        _(response).must_include('data')
        _(response['data']).must_include('success')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/cancel-withdrawal-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_cancel_withdrawal(order_id: 'INVALID')
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_deposit_address" do
    it "gets deposit address" do
      VCR.use_cassette('v2/spot/wallet/deposit-address') do
        response = client.spot_wallet_deposit_address(
          coin: 'USDT',
          chain: 'TRC20'
        )
        _(response).must_include('data')
        _(response['data']).must_include('address')
        _(response['data']).must_include('chain')
        _(response['data']).must_include('coin')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/deposit-address-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_deposit_address(
                coin: 'INVALID',
                chain: 'INVALID'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_subaccount_deposit_address" do
    it "gets subaccount deposit address" do
      VCR.use_cassette('v2/spot/wallet/subaccount-deposit-address') do
        response = client.spot_wallet_subaccount_deposit_address(
          subaccount_id: '123456',
          coin: 'USDT',
          chain: 'TRC20'
        )
        _(response).must_include('data')
        _(response['data']).must_include('address')
        _(response['data']).must_include('chain')
        _(response['data']).must_include('coin')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/subaccount-deposit-address-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_subaccount_deposit_address(
                subaccount_id: 'INVALID',
                coin: 'INVALID',
                chain: 'INVALID'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_subaccount_deposit_records" do
    it "gets subaccount deposit records" do
      VCR.use_cassette('v2/spot/wallet/subaccount-deposit-records') do
        response = client.spot_wallet_subaccount_deposit_records(
          subaccount_id: '123456',
          coin: 'BTC',
          status: 'success'
        )
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('amount')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('chain')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/subaccount-deposit-records-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_subaccount_deposit_records(
                subaccount_id: 'INVALID',
                coin: 'BTC',
                status: 'success'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_withdrawal_records" do
    it "gets withdrawal records" do
      VCR.use_cassette('v2/spot/wallet/withdrawal-records') do
        response = client.spot_wallet_withdrawal_records(
          coin: 'BTC',
          status: 'success'
        )
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        # _(response['data'].first).must_include('coin')
        # _(response['data'].first).must_include('amount')
        # _(response['data'].first).must_include('status')
        # _(response['data'].first).must_include('chain')
        # _(response['data'].first).must_include('address')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/withdrawal-records-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_withdrawal_records(
                coin: 'INVALID',
                status: 'success'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end

  describe "#spot_wallet_deposit_records" do
    it "gets deposit records" do
      VCR.use_cassette('v2/spot/wallet/deposit-records') do
        response = client.spot_wallet_deposit_records(
          coin: 'BTC',
          status: 'success'
        )
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('amount')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('chain')
        _(response['data'].first).must_include('address')
      end
    end

    context "when an error occurs" do
      it "logs then raises an error" do
        VCR.use_cassette('v2/spot/wallet/deposit-records-when_an_error_occurs') do
          assert_raises(Bitget::Error) do
            mocked_method = Minitest::Mock.new
            mocked_method.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
            client.stub(:log_error, mocked_method) do
              client.spot_wallet_deposit_records(
                coin: 'INVALID',
                status: 'success'
              )
            end
            mocked_method.verify
          end
        end
      end
    end
  end
end
