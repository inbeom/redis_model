# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis_model/version'

Gem::Specification.new do |spec|
  spec.name          = 'redis_model'
  spec.version       = RedisModel::VERSION
  spec.authors       = ['Inbeom Hwang']
  spec.email         = ['hwanginbeom@gmail.com']
  spec.summary       = %q{Interfaces for Redis values.}
  spec.description   = %q{RedisModel provides various types of interfaces to handle values on Redis}
  spec.homepage      = 'http://gitlab.ultracaption.net/inbeom/redis_model'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'redis'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'kaminari'
end
