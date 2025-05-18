require_relative './helper'
require_relative '../lib/Bitget/Client'

describe Bitget::Client do
  let(:client) do
    Bitget::Client.new(
      api_key: ENV.fetch('BITGET_API_KEY', '<API_KEY>'),
      api_secret: ENV.fetch('BITGET_API_SECRET', '<API_SECRET>'),
      api_passphrase: ENV.fetch('BITGET_API_PASSPHRASE', '<API_PASSPHRASE>')
    )
  end

  # Market

  %w[
    spot_public_coins
    spot_public_symbols
    spot_market_vip_free_rate
    spot_market_tickers
    spot_market_merge_depth
    spot_market_orderbook
    spot_market_candles
    spot_market_history_candles
    spot_market_fills
    spot_market_fills_history
  ].each do |method|
    describe "##{method}" do
      it "delegates to V2::Client" do
        mock_v2_client = Minitest::Mock.new
        client.instance_variable_set(:@v2_client, mock_v2_client)

        args = case method
        when 'spot_market_merge_depth', 'spot_market_orderbook'
          {symbol: 'BTCUSDT'}
        when 'spot_market_candles', 'spot_market_history_candles'
          {symbol: 'BTCUSDT', granularity: '1min'}
        when 'spot_market_fills', 'spot_market_fills_history'
          {symbol: 'BTCUSDT'}
        else
          {}
        end

        mock_v2_client.expect(method.to_sym, nil, [args])
        client.send(method, **args)
        mock_v2_client.verify
      end
    end
  end

  # Trade

  %w[
    spot_trade_place_order
    spot_trade_cancel_replace_order
    spot_trade_batch_cancel_replace_order
    spot_trade_cancel_order
    spot_trade_batch_orders
    spot_trade_batch_cancel_order
    spot_trade_cancel_symbol_order
    spot_trade_order_info
    spot_trade_unfilled_orders
    spot_trade_history_orders
    spot_trade_fills
  ].each do |method|
    describe "##{method}" do
      it "delegates to V2::Client" do
        mock_v2_client = Minitest::Mock.new
        client.instance_variable_set(:@v2_client, mock_v2_client)

        args = case method
        when 'spot_trade_place_order'
          {
            symbol: 'BTCUSDT',
            side: 'buy',
            order_type: 'limit',
            force: 'normal',
            size: '0.001',
            price: '30000'
          }
        when /cancel|modify|info/
          {symbol: 'BTCUSDT', order_id: '123456'}
        when /batch/
          {symbol: 'BTCUSDT', order_ids: ['123', '456']}
        else
          {symbol: 'BTCUSDT'}
        end

        mock_v2_client.expect(method.to_sym, nil, [args])
        client.send(method, **args)
        mock_v2_client.verify
      end
    end
  end

  # Trigger

  %w[
    spot_trade_place_plan_order
    spot_trade_modify_plan_order
    spot_trade_cancel_plan_order
    spot_trade_current_plan_order
    spot_trade_plan_sub_order
    spot_trade_history_plan_order
    spot_trade_batch_cancel_plan_order
  ].each do |method|
    describe "##{method}" do
      it "delegates to V2::Client" do
        mock_v2_client = Minitest::Mock.new
        client.instance_variable_set(:@v2_client, mock_v2_client)

        args = case method
        when 'spot_trade_place_plan_order'
          {
            symbol: 'BTCUSDT',
            side: 'buy',
            order_type: 'limit',
            size: '0.001',
            trigger_price: '31000',
            execute_price: '30000'
          }
        when 'spot_trade_modify_plan_order'
          {
            order_id: '123456',
            trigger_price: '31000',
            execute_price: '30000',
            size: '0.001'
          }
        when 'spot_trade_cancel_plan_order'
          {order_id: '123456'}
        when 'spot_trade_plan_sub_order'
          {order_id: '123456'}
        when 'spot_trade_batch_cancel_plan_order'
          {symbol: 'BTCUSDT', order_ids: ['123', '456']}
        else
          {symbol: 'BTCUSDT'}
        end

        mock_v2_client.expect(method.to_sym, nil, [args])
        client.send(method, **args)
        mock_v2_client.verify
      end
    end
  end

  # Account

  %w[
    spot_account_info
    spot_account_assets
    spot_account_subaccount_assets
    spot_account_bills
    spot_account_sub_main_trans_record
    spot_account_transfer_records
    spot_account_switch_deduct
    spot_account_deduct_info
    spot_wallet_modify_deposit_account
    spot_wallet_transfer
    spot_wallet_transfer_coin_info
    spot_wallet_subaccount_transfer
    spot_wallet_withdrawal
    spot_wallet_cancel_withdrawal
    spot_wallet_deposit_address
    spot_wallet_subaccount_deposit_address
    spot_wallet_subaccount_deposit_records
    spot_wallet_withdrawal_records
    spot_wallet_deposit_records
  ].each do |method|
    describe "##{method}" do
      it "delegates to V2::Client" do
        mock_v2_client = Minitest::Mock.new
        client.instance_variable_set(:@v2_client, mock_v2_client)

        args = case method
        when 'spot_wallet_withdrawal'
          {
            coin: 'USDT',
            chain: 'TRC20',
            address: '0x1234567890abcdef',
            amount: '100'
          }
        when /transfer/
          {
            coin: 'USDT',
            amount: '100'
          }
        when /subaccount/
          {subaccount_id: '123456'}
        else
          {}
        end

        mock_v2_client.expect(method.to_sym, nil, [args])
        client.send(method, **args)
        mock_v2_client.verify
      end
    end
  end
end
