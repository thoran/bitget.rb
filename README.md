# bitget.rb

## Description

Access the Bitget API with Ruby.

## Installation

Add this line to your application's Gemfile:
```ruby
  gem 'bitget.rb'
```
And then execute:
```bash
  $ bundle
```
Or install it yourself as:
```bash
  $ gem install bitget.rb
```

## Usage

### Setup
```ruby
bitget_client = Bitget::Client.new(
  api_key: 'api_key0',
  api_secret: 'api_secret0',
  api_passphrase: 'api_passphrase0'
)
```

### Retrieve Info on All the Coins Traded
```ruby
bitget_client.spot_public_coins
# =>
#  {
#    "code" => "00000",
#    "msg" => "success",
#    "requestTime" => 1743252600562,
#    "data" => [
#      {
#        "coinId" => "1460",
#        "coin" => "U2U",
#        "transfer" => "false",
#        "chains" => [
#          {
#            "chain" => "UnicornUltraSolaris",
#            ...
#          }
#        ]
#      },
#      ...
#      {...}
#    ]
#    "areaCoin" => "no"
#  }
```

### Retrieve Info for One of the Coins Traded
```ruby
bitget_client.spot_public_coins(coin: 'BTC')
# =>
#  {
#    "code" => "00000",
#    "msg" => "success",
#    "requestTime" => 1743252619082,
#    "data" => [
#      {
#        "coinId" => "1",
#        "coin" => "BTC",
#        "transfer" => "true",
#        "chains" => [
#          {
#            "chain" => "BTC",
#            "needTag" => "false",
#            "withdrawable" => "true",
#            "rechargeable" => "true",
#            "withdrawFee" => "0.00005",
#            "extraWithdrawFee" => "0",
#            "depositConfirm" => "1",
#            "withdrawConfirm" => "1",
#            "minDepositAmount" => "0.00001",
#            "minWithdrawAmount" => "0.0005",
#            "browserUrl" => "https://www.blockchain.com/explorer/transactions/btc/",
#            "contractAddress" => nil,
#            "withdrawStep" => "0",
#            "withdrawMinScale" => "8",
#            "congestion" => "normal"
#          },
#          ...
#          {...}
#        ]
#      }
#    ]
#    "areaCoin" => "no"
#  }
```

### Get Account Information
```ruby
bitget_client.spot_account_info
```

### Get Account Assets
```ruby
bitget_client.spot_account_assets
```
```ruby
bitget_client.spot_account_assets(coin: 'BTC')
```

See https://www.bitget.com/api-doc/spot/intro for further information on endpoint arguments

## Contributing

1. Fork it (https://github.com/thoran/bitget.rb/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request
