# bitget.rb
# Bitget

# 20250323
# 0.1.0

lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require_relative './Bitget/Client'
