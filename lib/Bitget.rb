# bitget.rb
# Bitget

# 20250326
# 0.1.1

lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require_relative './Bitget/Client'
