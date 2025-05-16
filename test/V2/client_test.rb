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
end
