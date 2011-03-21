# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "http_router_sinatra/version"

Gem::Specification.new do |s|
  s.name        = "http_router_sinatra"
  s.version     = HttpRouter::Sinatra::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "http_router_sinatra"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "http_router", "~> 0.6.0"
  s.add_dependency "sinatra", "~> 1.2.0"
  s.add_development_dependency 'minitest', '~> 2.0.0'
  s.add_development_dependency 'code_stats'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rbench'
  s.add_development_dependency 'phocus'
  s.add_development_dependency 'bundler',  '~> 1.0.0'
end
