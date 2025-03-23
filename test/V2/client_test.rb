require_relative '../helper'
require_relative '../../lib/Bitget/V2/Client'

describe Bitget::V2::Client do
  let(:client) do
    Bitget::V2::Client.new(
      api_key: api_key,
      api_secret: api_secret,
      api_passphrase: api_passphrase
    )
  end

  describe "#spot_public_coins" do
    it "retrieves a list of all coins" do
      VCR.use_cassette('v2/spot/public/coins') do
        response = client.spot_public_coins
        _(response).must_include('data')
        _(response['data'].first).must_include('coinId')
        _(response['data'].first).must_include('coin')
        assert_operator response['data'].count, :>, 1500
      end
    end
  end
end
