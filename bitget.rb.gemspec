require_relative './lib/Bitget/VERSION'

Gem::Specification.new do |spec|
  spec.name = 'bitget.rb'

  spec.version = Bitget::VERSION
  spec.date = '2025-05-26'

  spec.summary = "Access the Bitget API with Ruby."
  spec.description = "Access the Bitget API with Ruby."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'http://github.com/thoran/bitget.rb'
  spec.license = 'Ruby'

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency('http.rb')
  spec.files = [
    'bitget.rb.gemspec',
    'Gemfile',
    Dir['lib/**/*.rb'],
    'README.md',
    Dir['test/**/*.rb']
  ].flatten
  spec.require_paths = ['lib']
end
