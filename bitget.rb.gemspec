Gem::Specification.new do |spec|
  spec.name = 'bitget.rb'

  spec.version = '0.3.0'
  spec.date = '2025-03-29'

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
