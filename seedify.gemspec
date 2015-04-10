lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seedify/version'

Gem::Specification.new do |spec|
  spec.name     = 'seedify'
  spec.version  = Seedify::VERSION
  spec.authors  = ['Karol Słuszniak']
  spec.email    = 'k.sluszniak@visuality.pl'
  spec.homepage = 'http://github.com/visualitypl/seedify'
  spec.license  = 'MIT'
  spec.platform = Gem::Platform::RUBY

  spec.summary = 'Implement and organize seeds in Rail-ish, object-oriented fashion. Handy syntax for command line parameters and progress logging.'

  spec.description = 'Let your seed code become a first-class member of the Rails app and put it into seed objects in "app/seeds" alongside the controllers, models etc. Invoke seeds as rake tasks or from within the app/console, with or without the parameters. Progress logging included.'

  spec.files            = Dir['lib/**/*.rb', 'lib/**/*.rake']
  spec.has_rdoc         = false
  spec.extra_rdoc_files = ['README.md']
  spec.test_files       = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths    = ["lib"]

  spec.add_development_dependency 'bundler',                   '~> 1.6'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
  spec.add_development_dependency 'rake',                      '~> 10.0'
  spec.add_development_dependency 'rspec',                     '~> 3.1'
  spec.add_development_dependency 'scrutinizer-ocular',        '~> 1.0'
  spec.add_development_dependency 'simplecov',                 '~> 0.9'

  spec.add_runtime_dependency 'activesupport', '>= 3.0'
  spec.add_runtime_dependency 'rails',         '>= 3.0'
end
