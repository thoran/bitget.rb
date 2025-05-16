require_relative '../helper'
require_relative '../../lib/Bitget/V2/Client'

describe Bitget::V2::Client do
  let(:api_key){ENV.fetch('BITGET_API_KEY', '<API_KEY>')}
  let(:api_secret){ENV.fetch('BITGET_API_SECRET', '<API_SECRET>')}
  let(:api_passphrase){ENV.fetch('BITGET_API_PASSPHRASE', '<API_PASSPHRASE>')}

  let(:client) do
    Bitget::V2::Client.new(
      api_key: api_key,
      api_secret: api_secret,
      api_passphrase: api_passphrase
    )
  end

  # Market

  describe "#spot_public_coins" do
    context "when a coin is NOT supplied" do
      it "retrieves a list of all coins" do
        VCR.use_cassette('v2/spot/public/coins-when_coin_is_not_supplied') do
          response = client.spot_public_coins
          _(response['code']).must_equal('00000')
          _(response['msg']).must_equal('success')
          _(response).must_include('requestTime')
          _(response).must_include('data')
          _(response['data']).must_be_kind_of(Array)

          coin = response['data'].first
          _(coin).must_include('coinId')
          _(coin).must_include('coin')
          _(coin).must_include('transfer')
          _(coin).must_include('areaCoin')
          _(coin['areaCoin']).must_match(/^(yes|no)$/)
          _(coin).must_include('chains')
          _(coin['chains']).must_be_kind_of(Array)

          chain = coin['chains'].first
          _(chain).must_include('chain')
          _(chain).must_include('needTag')
          _(chain).must_include('withdrawable')
          _(chain).must_include('rechargeable')
          _(chain).must_include('withdrawFee')
          _(chain).must_include('extraWithdrawFee')
          _(chain).must_include('depositConfirm')
          _(chain).must_include('withdrawConfirm')
          _(chain).must_include('minDepositAmount')
          _(chain).must_include('minWithdrawAmount')
          _(chain).must_include('browserUrl')
          _(chain).must_include('contractAddress')
          _(chain).must_include('withdrawStep')
          _(chain).must_include('withdrawMinScale')
          _(chain).must_include('congestion')

          assert_operator response['data'].count, :>, 1500
        end
      end
    end

    context "when a coin IS supplied" do
      it "retrieves one coin" do
        VCR.use_cassette('v2/spot/public/coins-when_coin_is_supplied') do
          response = client.spot_public_coins(coin: 'BTC')
          _(response['code']).must_equal('00000')
          _(response['msg']).must_equal('success')
          _(response).must_include('requestTime')
          _(response).must_include('data')
          _(response['data']).must_be_kind_of(Array)
          _(response['data'].count).must_equal(1)

          coin = response['data'].first
          _(coin).must_include('coinId')
          _(coin).must_include('coin')
          _(coin['coin']).must_equal('BTC')
          _(coin).must_include('transfer')
          _(coin).must_include('areaCoin')
          _(coin['areaCoin']).must_match(/^(yes|no)$/)
          _(coin).must_include('chains')
          _(coin['chains']).must_be_kind_of(Array)

          chain = coin['chains'].first
          _(chain).must_include('chain')
          _(chain).must_include('needTag')
          _(chain).must_include('withdrawable')
          _(chain).must_include('rechargeable')
          _(chain).must_include('withdrawFee')
          _(chain).must_include('extraWithdrawFee')
          _(chain).must_include('depositConfirm')
          _(chain).must_include('withdrawConfirm')
          _(chain).must_include('minDepositAmount')
          _(chain).must_include('minWithdrawAmount')
          _(chain).must_include('browserUrl')
          _(chain).must_include('contractAddress')
          _(chain).must_include('withdrawStep')
          _(chain).must_include('withdrawMinScale')
          _(chain).must_include('congestion')
        end
      end
    end
  end

  describe "#spot_public_symbols" do
    context "when a symbol is NOT supplied" do
      it "retrieves a list of all symbols" do
        VCR.use_cassette('v2/spot/public/symbols-when_symbol_is_not_supplied') do
          response = client.spot_public_symbols
          _(response['msg']).must_equal('success')
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
          _(response['msg']).must_equal('success')
          _(response).must_include('data')
          _(response['data'].first).must_include('symbol')
          _(response['data'].first).must_include('baseCoin')
          _(response['data'].first).must_include('quoteCoin')
          _(response['data'].count).must_equal(1)
          _(response['data'].first['symbol']).must_equal('BTCUSDT')
        end
      end
    end
  end

  describe "#spot_market_vip_fee_rate" do
    it "retrieves VIP fee rate information" do
      VCR.use_cassette('v2/spot/market/vip-fee-rate') do
        response = client.spot_market_vip_fee_rate
        _(response['code']).must_equal('00000')
        _(response['msg']).must_equal('success')
        _(response).must_include('requestTime')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)

        vip_level = response['data'].first
        _(vip_level).must_include('level')
        _(vip_level).must_include('dealAmount')
        _(vip_level).must_include('assetAmount')
        _(vip_level).must_include('takerFeeRate')
        _(vip_level).must_include('makerFeeRate')
        _(vip_level).must_include('btcWithdrawAmount')
        _(vip_level).must_include('usdtWithdrawAmount')
      end
    end
  end

  describe "#spot_market_tickers" do
    context "when a symbol is NOT supplied" do
      it "retrieves all tickers" do
        VCR.use_cassette('v2/spot/market/tickers-when_symbol_is_not_supplied') do
          response = client.spot_market_tickers
          _(response['code']).must_equal('00000')
          _(response['msg']).must_equal('success')
          _(response).must_include('requestTime')
          _(response).must_include('data')
          _(response['data']).must_be_kind_of(Array)

          ticker = response['data'].first
          _(ticker).must_include('symbol')
          _(ticker).must_include('high24h')
          _(ticker).must_include('open')
          _(ticker).must_include('low24h')
          _(ticker).must_include('lastPr')
          _(ticker).must_include('quoteVolume')
          _(ticker).must_include('baseVolume')
          _(ticker).must_include('usdtVolume')
          _(ticker).must_include('bidPr')
          _(ticker).must_include('askPr')
          _(ticker).must_include('bidSz')
          _(ticker).must_include('askSz')
          _(ticker).must_include('openUtc')
          _(ticker).must_include('ts')
          _(ticker).must_include('changeUtc24h')
          _(ticker).must_include('change24h')
        end
      end
    end

    context "when a symbol is supplied" do
      it "retrieves ticker for the specified symbol" do
        VCR.use_cassette('v2/spot/market/tickers-when_symbol_is_supplied') do
          response = client.spot_market_tickers(symbol: 'BTCUSDT')
          _(response['code']).must_equal('00000')
          _(response['msg']).must_equal('success')
          _(response).must_include('requestTime')
          _(response).must_include('data')
          _(response['data']).must_be_kind_of(Array)
          _(response['data'].count).must_equal(1)

          ticker = response['data'].first
          _(ticker['symbol']).must_equal('BTCUSDT')
          _(ticker).must_include('high24h')
          _(ticker).must_include('open')
          _(ticker).must_include('low24h')
          _(ticker).must_include('lastPr')
          _(ticker).must_include('quoteVolume')
          _(ticker).must_include('baseVolume')
          _(ticker).must_include('usdtVolume')
          _(ticker).must_include('bidPr')
          _(ticker).must_include('askPr')
          _(ticker).must_include('bidSz')
          _(ticker).must_include('askSz')
          _(ticker).must_include('openUtc')
          _(ticker).must_include('ts')
          _(ticker).must_include('changeUtc24h')
          _(ticker).must_include('change24h')
        end
      end
    end
  end

  describe "#spot_market_merge_depth" do
    it "retrieves merge depth" do
      VCR.use_cassette('v2/spot/market/merge-depth') do
        response = client.spot_market_merge_depth(symbol: 'BTCUSDT')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('asks')
        _(response['data']).must_include('bids')
        _(response['data']).must_include('ts')
      end
    end
  end

  describe "#spot_market_orderbook" do
    it "retrieves orderbook" do
      VCR.use_cassette('v2/spot/market/orderbook') do
        response = client.spot_market_orderbook(symbol: 'BTCUSDT')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('asks')
        _(response['data']).must_include('bids')
        _(response['data']).must_include('ts')
      end
    end
  end

  describe "#spot_market_candles" do
    it "retrieves candles" do
      VCR.use_cassette('v2/spot/market/candles') do
        response = client.spot_market_candles(symbol: 'BTCUSDT', granularity: '1min')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data'].first).must_be_kind_of(Array)
        _(response['data'].first.length).must_equal(8) # [timestamp, open, high, low, close, base_volume, usdt_volume, quote_volume]
      end
    end
  end

  describe "#spot_market_history_candles" do
    it "retrieves history candles" do
      VCR.use_cassette('v2/spot/market/history-candles') do
        response = client.spot_market_history_candles(symbol: 'BTCUSDT', granularity: '1min', end_time: 1690196141868)
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data'].first).must_be_kind_of(Array)
        _(response['data'].first.length).must_equal(8) # [ts, open, high, low, close, base volume, USDT volume, quote volume]
      end
    end
  end

  describe "#spot_market_fills" do
    it "retrieves recent trades" do
      VCR.use_cassette('v2/spot/market/fills') do
        response = client.spot_market_fills(symbol: 'BTCUSDT')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data'].first).must_include('price')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('side')
        _(response['data'].first).must_include('ts')
      end
    end
  end

  describe "#spot_market_fills_history" do
    it "retrieves market trades history" do
      VCR.use_cassette('v2/spot/market/fills-history') do
        response = client.spot_market_fills_history(symbol: 'BTCUSDT')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data'].first).must_include('price')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('side')
        _(response['data'].first).must_include('ts')
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
          force: 'gtc',
          price: '30000',
          size: '0.001'
        )
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOid')
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
  end

  describe "#spot_trade_batch_cancel_replace_order" do
    it "batch cancels and replaces orders" do
      VCR.use_cassette('v2/spot/trade/batch-cancel-replace-order') do
        order_list = [
          {
            symbol: 'BTCUSDT',
            price: '31000',
            size: '0.001',
            orderId: '123456',
          },
          {
            symbol: 'ETHUSDT',
            price: '2000',
            size: '0.01',
            orderId: '123457',
          }
        ]
        response = client.spot_trade_batch_cancel_replace_order(order_list: order_list)
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('clientOid')
        _(response['data'].first).must_include('success')
        _(response['data'].first).must_include('msg')
      end
    end
  end

  describe "#spot_trade_cancel_order" do
    it "cancels an order" do
      VCR.use_cassette('v2/spot/trade/cancel-order') do
        response = client.spot_trade_cancel_order(symbol: 'BTCUSDT')
        _(response['message']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOid')
      end
    end
  end

  describe "#spot_trade_batch_orders" do
    it "places batch orders" do
      VCR.use_cassette('v2/spot/trade/batch-orders') do
        order_list = [
          {
            symbol: 'BTCUSDT',
            side: 'buy',
            orderType: 'limit',
            force: 'gtc',
            price: '30000',
            size: '0.001'
          },
          {
            symbol: 'ETHUSDT',
            side: 'buy',
            orderType: 'limit',
            force: 'gtc',
            price: '2000',
            size: '0.01'
          }
        ]
        response = client.spot_trade_batch_orders(batch_mode: 'multiple', order_list: order_list)
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('successList')
        _(response['data']).must_include('failureList')
        _(response['data']['successList']).must_be_kind_of(Array)
        _(response['data']['successList'].first).must_include('orderId')
        _(response['data']['successList'].first).must_include('clientOid')
        _(response['data']['failureList']).must_be_kind_of(Array)
      end
    end
  end

  describe "#spot_trade_batch_cancel_order" do
    it "cancels batch orders" do
      VCR.use_cassette('v2/spot/trade/batch-cancel-order') do
        response = client.spot_trade_batch_cancel_order(symbol: 'BTCUSDT', order_list: ['123456', '123457'])
        _(response['message']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('successList')
        _(response['data']['successList'].first).must_include('orderId')
        _(response['data']['successList'].first).must_include('clientOid')
        _(response['data']).must_include('failureList')
        _(response['data']['failureList'].first).must_include('orderId')
        _(response['data']['failureList'].first).must_include('clientOid')
        _(response['data']['failureList'].first).must_include('errorMsg')
      end
    end
  end

  describe "#spot_trade_cancel_symbol_order" do
    it "cancels all orders for a symbol" do
      VCR.use_cassette('v2/spot/trade/cancel-symbol-order') do
        response = client.spot_trade_cancel_symbol_order(symbol: 'BTCUSDT')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('symbol')
      end
    end
  end

  describe "#spot_trade_order_info" do
    it "retrieves order information" do
      VCR.use_cassette('v2/spot/trade/orderInfo') do
        response = client.spot_trade_order_info(order_id: '123456')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('userId')
        _(response['data'].first).must_include('symbol')
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('clientOid')
        _(response['data'].first).must_include('price')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('orderType')
        _(response['data'].first).must_include('side')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('priceAvg')
        _(response['data'].first).must_include('baseVolume')
        _(response['data'].first).must_include('quoteVolume')
        _(response['data'].first).must_include('enterPointSource')
        _(response['data'].first).must_include('feeDetail')
        _(response['data'].first).must_include('orderSource')
        _(response['data'].first).must_include('cancelReason')
        _(response['data'].first).must_include('cTime')
        _(response['data'].first).must_include('orderType')
        _(response['data'].first).must_include('uTime')
      end
    end
  end

  describe "#spot_trade_unfilled_orders" do
    it "gets unfilled orders" do
      VCR.use_cassette('v2/spot/trade/unfilled-orders') do
        response = client.spot_trade_unfilled_orders(symbol: 'BTCUSDT')
        _(response['message']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('clientOid')
        _(response['data'].first).must_include('symbol')
        _(response['data'].first).must_include('status')
      end
    end
  end

  describe "#spot_trade_history_orders" do
    it "gets history orders" do
      VCR.use_cassette('v2/spot/trade/history-orders') do
        response = client.spot_trade_history_orders(symbol: 'BTCUSDT')
        _(response['message']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('userId')
        _(response['data'].first).must_include('symbol')
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('clientOid')
        _(response['data'].first).must_include('price')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('orderType')
        _(response['data'].first).must_include('side')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('priceAvg')
        _(response['data'].first).must_include('baseVolume')
        _(response['data'].first).must_include('quoteVolume')
        _(response['data'].first).must_include('enterPointSource')
        _(response['data'].first).must_include('feeDetail')
        _(response['data'].first).must_include('orderSource')
        _(response['data'].first).must_include('cTime')
        _(response['data'].first).must_include('uTime')
        _(response['data'].first).must_include('tpslType')
        _(response['data'].first).must_include('cancelReason')
        _(response['data'].first).must_include('triggerPrice')
      end
    end
  end

  describe "#spot_trade_fills" do
    it "gets trade fills" do
      VCR.use_cassette('v2/spot/trade/fills') do
        response = client.spot_trade_fills(symbol: 'BTCUSDT')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('userId')
        _(response['data'].first).must_include('symbol')
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('tradeId')
        _(response['data'].first).must_include('orderType')
        _(response['data'].first).must_include('side')
        _(response['data'].first).must_include('priceAvg')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('amount')
        _(response['data'].first).must_include('feeDetail')
        _(response['data'].first['feeDetail']).must_include('deduction')
        _(response['data'].first['feeDetail']).must_include('feeCoin')
        _(response['data'].first['feeDetail']).must_include('totalDeductionFee')
        _(response['data'].first['feeDetail']).must_include('totalFee')
        _(response['data'].first).must_include('tradeScope')
        _(response['data'].first).must_include('cTime')
        _(response['data'].first).must_include('uTime')
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
          trigger_type: 'mark_price',
          trigger_price: '30000',
          execute_price: '30000'
        )
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOid')
      end
    end
  end

  describe "#spot_trade_modify_plan_order" do
    it "modifies a plan order" do
      VCR.use_cassette('v2/spot/trade/modify-plan-order') do
        response = client.spot_trade_modify_plan_order(order_id: '123456')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOid')
      end
    end
  end

  describe "#spot_trade_cancel_plan_order" do
    it "cancels a plan order" do
      VCR.use_cassette('v2/spot/trade/cancel-plan-order') do
        response = client.spot_trade_cancel_plan_order(order_id: '123456')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response).must_be_kind_of(Hash)
        _(response['data']).must_include('result')
        _(response['data']['result']).must_equal('success')
      end
    end
  end

  describe "#spot_trade_current_plan_order" do
    it "gets current plan orders" do
      VCR.use_cassette('v2/spot/trade/current-plan-order') do
        response = client.spot_trade_current_plan_order(symbol: 'BTCUSDT')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('nextFlag')
        _(response['data']).must_include('idLessThan')
        _(response['data']).must_include('orderList')
      end
    end
  end

  describe "#spot_trade_plan_sub_order" do
    it "gets plan sub order" do
      VCR.use_cassette('v2/spot/trade/plan-sub-order') do
        response = client.spot_trade_plan_sub_order(order_id: '123456')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('price')
        _(response['data'].first).must_include('type')
        _(response['data'].first).must_include('status')
      end
    end
  end

  describe "#spot_trade_history_plan_order" do
    it "gets history plan orders" do
      VCR.use_cassette('v2/spot/trade/history-plan-order') do
        response = client.spot_trade_history_plan_order(
          symbol: 'BTCUSDT',
          start_time: 1747754739537,
          end_time: 1747755739537
        )
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('nextFlag')
        _(response['data']).must_include('idLessThan')
        _(response['data']).must_include('orderList')
        _(response['data']['orderList'].first).must_include('orderId')
        _(response['data']['orderList'].first).must_include('clientOid')
        _(response['data']['orderList'].first).must_include('symbol')
        _(response['data']['orderList'].first).must_include('size')
        _(response['data']['orderList'].first).must_include('executePrice')
        _(response['data']['orderList'].first).must_include('triggerPrice')
        _(response['data']['orderList'].first).must_include('status')
        _(response['data']['orderList'].first).must_include('orderType')
        _(response['data']['orderList'].first).must_include('side')
        _(response['data']['orderList'].first).must_include('planType')
        _(response['data']['orderList'].first).must_include('triggerType')
        _(response['data']['orderList'].first).must_include('enterPointSource')
        _(response['data']['orderList'].first).must_include('uTime')
        _(response['data']['orderList'].first).must_include('cTime')
      end
    end
  end

  describe "#spot_trade_batch_cancel_plan_order" do
    it "cancels batch plan orders" do
      VCR.use_cassette('v2/spot/trade/batch-cancel-plan-order') do
        response = client.spot_trade_batch_cancel_plan_order(symbol_list: ['BTCUSDT', 'ETHUSDT'])
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('successList')
        _(response['data']).must_include('failureList')
      end
    end
  end

  # Account

  describe "#spot_account_info" do
    it "retrieves account information" do
      VCR.use_cassette('v2/spot/account/info') do
        response = client.spot_account_info
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('userId')
        _(response['data']).must_include('channelCode')
        _(response['data']).must_include('authorities')
      end
    end
  end

  describe "#spot_account_assets" do
    it "retrieves account assets" do
      VCR.use_cassette('v2/spot/account/assets') do
        response = client.spot_account_assets
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('available')
        _(response['data'].first).must_include('frozen')
        _(response['data'].first).must_include('locked')
        _(response['data'].first).must_include('uTime')
      end
    end
  end

  describe "#spot_account_subaccount_assets" do
    it "gets subaccount assets" do
      VCR.use_cassette('v2/spot/account/subaccount-assets') do
        response = client.spot_account_subaccount_assets
        _(response['message']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('id')
        _(response['data'].first).must_include('userId')
        _(response['data'].first).must_include('assetsList')
        _(response['data'].first['assetsList']).must_be_kind_of(Array)
        _(response['data'].first['assetsList'].first).must_include('coin')
        _(response['data'].first['assetsList'].first).must_include('available')
        _(response['data'].first['assetsList'].first).must_include('limitAvailable')
        _(response['data'].first['assetsList'].first).must_include('frozen')
        _(response['data'].first['assetsList'].first).must_include('locked')
        _(response['data'].first['assetsList'].first).must_include('uTime')
      end
    end
  end

  describe "#spot_account_bills" do
    it "gets account bills" do
      VCR.use_cassette('v2/spot/account/bills') do
        response = client.spot_account_bills
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('billId')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('bizOrderId')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('groupType')
        _(response['data'].first).must_include('businessType')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('balance')
        _(response['data'].first).must_include('fees')
        _(response['data'].first).must_include('cTime')
      end
    end
  end

  describe "#spot_account_sub_main_trans_record" do
    it "gets main-sub transfer records" do
      VCR.use_cassette('v2/spot/account/sub-main-trans-record') do
        response = client.spot_account_sub_main_trans_record
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('toType')
        _(response['data'].first).must_include('fromType')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('ts')
        _(response['data'].first).must_include('clientOid')
        _(response['data'].first).must_include('transferId')
        _(response['data'].first).must_include('fromUserId')
        _(response['data'].first).must_include('toUserId')
      end
    end
  end

  describe "#spot_account_transfer_records" do
    it "gets transfer records" do
      VCR.use_cassette('v2/spot/account/transferRecords') do
        response = client.spot_account_transfer_records
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('toType')
        _(response['data'].first).must_include('fromType')
        _(response['data'].first).must_include('fromSymbol')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('ts')
        _(response['data'].first).must_include('clientOid')
        _(response['data'].first).must_include('transferId')
      end
    end
  end

  describe "#spot_account_switch_deduct" do
    it "switches BGB deduct" do
      VCR.use_cassette('v2/spot/account/switch-deduct') do
        response = client.spot_account_switch_deduct(deduct: 'on')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_equal(true)
      end
    end
  end

  describe "#spot_account_deduct_info" do
    it "gets BGB deduct info" do
      VCR.use_cassette('v2/spot/account/deduct-info') do
        response = client.spot_account_deduct_info
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('deduct')
      end
    end
  end

  describe "#spot_wallet_modify_deposit_account" do
    it "modifies deposit account" do
      VCR.use_cassette('v2/spot/wallet/modify-deposit-account') do
        response = client.spot_wallet_modify_deposit_account(account_type: 'spot', coin: 'TRX')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('success')
      end
    end
  end

  describe "#spot_wallet_transfer" do
    it "transfers funds between accounts" do
      VCR.use_cassette('v2/spot/wallet/transfer') do
        response = client.spot_wallet_transfer(
          from_type: 'spot',
          to_type: 'isolated_margin',
          amount: '100',
          coin: 'USDT',
          symbol: 'TRXUSDT'
        )
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('transferId')
        _(response['data']).must_include('clientOid')
      end
    end
  end

  describe "#spot_wallet_transfer_coin_info" do
    it "gets transferable coin list" do
      VCR.use_cassette('v2/spot/wallet/transfer-coin-info') do
        response = client.spot_wallet_transfer_coin_info(from_type: 'spot', to_type: 'isolated_margin')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data']).must_include('AGLD')
      end
    end
  end

  describe "#spot_wallet_subaccount_transfer" do
    it "transfers funds between subaccounts" do
      VCR.use_cassette('v2/spot/wallet/subaccount-transfer') do
        response = client.spot_wallet_subaccount_transfer(
          from_type: 'spot',
          to_type: 'isolated_margin',
          amount: '100',
          coin: 'USDT'
        )
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Hash)
        _(response['data']).must_include('transferId')
        _(response['data']).must_include('clientOid')
      end
    end
  end

  describe "#spot_wallet_withdrawal" do
    it "withdraws funds" do
      VCR.use_cassette('v2/spot/wallet/withdrawal') do
        response = client.spot_wallet_withdrawal(
          coin: 'USDT',
          transfer_type: 'on_chain',
          address: '0x1234567890abcdef',
          chain: 'TRC20',
          size: 100
        )
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response).must_be_kind_of(Hash)
        _(response['msg']).must_equal('success')
        _(response['data']).must_include('orderId')
        _(response['data']).must_include('clientOid')
      end
    end
  end

  describe "#spot_wallet_cancel_withdrawal" do
    it "cancels a withdrawal" do
      VCR.use_cassette('v2/spot/wallet/cancel-withdrawal') do
        response = client.spot_wallet_cancel_withdrawal(order_id: '123456')
        _(response).must_include('data')
        _(response['data']).must_equal('success')
      end
    end
  end

  describe "#spot_wallet_deposit_address" do
    it "gets deposit address" do
      VCR.use_cassette('v2/spot/wallet/deposit-address') do
        response = client.spot_wallet_deposit_address(coin: 'USDT', chain: 'TRC20')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('address')
        _(response['data']).must_include('chain')
        _(response['data']).must_include('coin')
      end
    end
  end

  describe "#spot_wallet_subaccount_deposit_address" do
    it "gets subaccount deposit address" do
      VCR.use_cassette('v2/spot/wallet/subaccount-deposit-address') do
        response = client.spot_wallet_subaccount_deposit_address(
          subaccount_user_id: '123456',
          coin: 'USDT',
          chain: 'TRC20'
        )
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_include('address')
        _(response['data']).must_include('chain')
        _(response['data']).must_include('coin')
        _(response['data']).must_include('tag')
        _(response['data']).must_include('url')
      end
    end
  end

  describe "#spot_wallet_subaccount_deposit_records" do
    it "gets subaccount deposit records" do
      VCR.use_cassette('v2/spot/wallet/subaccount-deposit-records') do
        response = client.spot_wallet_subaccount_deposit_records(subaccount_user_id: '123456')
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('tradeId')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('toAddress')
        _(response['data'].first).must_include('dest')
        _(response['data'].first).must_include('chain')
        _(response['data'].first).must_include('fromAddress')
        _(response['data'].first).must_include('cTime')
        _(response['data'].first).must_include('uTime')
      end
    end
  end

  describe "#spot_wallet_withdrawal_records" do
    it "gets withdrawal records" do
      VCR.use_cassette('v2/spot/wallet/withdrawal-records') do
        response = client.spot_wallet_withdrawal_records(start_time: 1690196141868, end_time: 1690197141868)
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('tradeId')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('dest')
        _(response['data'].first).must_include('clientOid')
        _(response['data'].first).must_include('type')
        _(response['data'].first).must_include('tag')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('fee')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('toAddress')
        _(response['data'].first).must_include('fromAddress')
        _(response['data'].first).must_include('confirm')
        _(response['data'].first).must_include('chain')
        _(response['data'].first).must_include('cTime')
        _(response['data'].first).must_include('uTime')
      end
    end
  end

  describe "#spot_wallet_deposit_records" do
    it "gets deposit records" do
      VCR.use_cassette('v2/spot/wallet/deposit-records') do
        response = client.spot_wallet_deposit_records(
          start_time: 1690196141868,
          end_time: 1690197141868
        )
        _(response['msg']).must_equal('success')
        _(response).must_include('data')
        _(response['data']).must_be_kind_of(Array)
        _(response['data'].first).must_include('orderId')
        _(response['data'].first).must_include('tradeId')
        _(response['data'].first).must_include('coin')
        _(response['data'].first).must_include('type')
        _(response['data'].first).must_include('size')
        _(response['data'].first).must_include('status')
        _(response['data'].first).must_include('toAddress')
        _(response['data'].first).must_include('dest')
        _(response['data'].first).must_include('chain')
        _(response['data'].first).must_include('fromAddress')
        _(response['data'].first).must_include('cTime')
        _(response['data'].first).must_include('uTime')
      end
    end
  end

  describe "error handling" do
    let(:mock_error){Minitest::Mock.new}

    before do
      client.use_logging = true
      mock_error.expect(:call, nil, [], code: '418', message: "I'm a teapot", body: '')
    end

    after do
      client.use_logging = false
      mock_error.verify
    end

    it "handles errors for public GET endpoints with NO arguments" do
      VCR.use_cassette('v2/spot/public/coins-when_an_error_occurs') do
        assert_raises(Bitget::Error) do
          client.stub(:log_error, mock_error) do
            client.spot_public_coins
          end
        end
      end
    end

    it "handles errors for public GET endpoints WITH arguments" do
      VCR.use_cassette('v2/spot/market/candles-when_an_error_occurs') do
        assert_raises(Bitget::Error) do
          client.stub(:log_error, mock_error) do
            client.spot_market_candles(symbol: 'INVALID', granularity: '1min')
          end
        end
      end
    end

    it "handles errors for authenticated GET endpoints with NO arguments" do
      VCR.use_cassette('v2/spot/account/info-when_an_error_occurs') do
        assert_raises(Bitget::Error) do
          client.stub(:log_error, mock_error) do
            client.spot_account_info
          end
        end
      end
    end

    it "handles errors for authenticated GET endpoints WITH arguments" do
      VCR.use_cassette('v2/spot/account/bills-when_an_error_occurs') do
        assert_raises(Bitget::Error) do
          client.stub(:log_error, mock_error) do
            client.spot_account_bills(
              coin: 'BTC',
              business_type: 'deposit',
              group_type: 'transfer'
            )
          end
        end
      end
    end

    it "handles errors for authenticated POST endpoints WITH arguments" do
      VCR.use_cassette('v2/spot/trade/place-order-when_an_error_occurs') do
        assert_raises(Bitget::Error) do
          client.stub(:log_error, mock_error) do
            client.spot_trade_place_order(
              symbol: 'BTCUSDT',
              side: 'buy',
              order_type: 'limit',
              force: 'normal',
              price: '30000',
              size: '0.001'
            )
          end
        end
      end
    end
  end

  describe "logging" do
    before do
      client.use_logging = true
      FileUtils.rm_f(client.class.log_file_path)
      client.class.instance_variable_set(:@log_file_path, nil)
      client.class.instance_variable_set(:@logger, nil)
    end

    after do
      client.use_logging = false
      FileUtils.rm_f(client.class.log_file_path)
    end

    describe "logging configuration" do
      it "uses the configured log file path" do
        client.class.log_file_path = '/tmp/path'
        _(client.class.log_file_path).must_equal(File.expand_path('/tmp/path'))
      end

      it "creates log directory if it doesn't exist" do
        nested_path = File.join(Dir.tmpdir, 'bitget_test', 'nested', 'test.log')
        client.class.log_file_path = nested_path
        client.class.logger
        _(File.directory?(File.dirname(nested_path))).must_equal(true)
      end

      it "creates a daily rotating logger" do
        _(client.class.logger).must_be_kind_of(Logger)
        _(File.exist?(client.class.log_file_path)).must_equal(true)
      end
    end

    describe "request logging" do
      it "logs requests" do
        client.class.logger
        VCR.use_cassette('v2/spot/public/coins-when_coin_is_supplied') do
          client.spot_public_coins(coin: 'BTC')
        end
        client.class.logger.close
        log_content = File.read(client.class.log_file_path)
        _(log_content).must_match(/GET https:\/\/api.bitget.com\/api\/v2\/spot\/public\/coins/)
        _(log_content).must_match(/Args: \{coin: \"BTC\"}/)
        _(log_content).must_match(/Headers: .+\"Content-Type\" => \"application\/json\"/)
      end
    end

    describe "response logging" do
      it "logs responses" do
        client.class.logger
        VCR.use_cassette('v2/spot/public/coins-when_coin_is_supplied') do
          client.spot_public_coins(coin: 'BTC')
        end
        client.class.logger.close
        log_content = File.read(client.class.log_file_path)
        _(log_content).must_match(/Code:/)
        _(log_content).must_match(/Message:/)
        _(log_content).must_match(/Body:/)
      end
    end

    describe "error logging" do
      it "logs error responses" do
        client.class.logger
        VCR.use_cassette('v2/spot/public/coins-when_error_occurs') do
          begin
            client.spot_public_coins(coin: 'INVALID')
          rescue Bitget::Error
          end
        end
        client.class.logger.close
        log_content = File.read(client.class.log_file_path)
        _(log_content).must_match(/Code:/)
        _(log_content).must_match(/Message:/)
        _(log_content).must_match(/Body:/)
      end
    end
  end
end
