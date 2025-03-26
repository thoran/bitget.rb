require_relative './helper'
require_relative '../lib/Bitget/Client'

describe Bitget::Client do
  let(:client) do
    Bitget::Client.new(
      api_key: api_key,
      api_secret: api_secret,
      api_passphrase: api_passphrase
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
  end
end
