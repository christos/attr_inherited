# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attr_inherited/version'

Gem::Specification.new do |gem|
  gem.name          = "attr_inherited"
  gem.version       = AttrInherited::VERSION

  gem.authors       = ["Christos Zisopoulos"]
  gem.email         = ["christos@mac.com"]
  gem.description   = "Attribute inheritance for ActiveRecord models"
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/christos/attr_inherited"

  gem.rubyforge_project = "attr_inherited"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "sqlite3"

  gem.add_dependency "activesupport"
  gem.add_dependency "activerecord"

end
