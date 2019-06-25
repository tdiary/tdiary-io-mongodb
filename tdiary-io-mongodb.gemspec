# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "tdiary-io-mongodb"
  spec.version       = "5.0.4"
  spec.authors       = ["TADA Tadashi"]
  spec.email         = ["t@tdtds.jp"]
  spec.description   = %q{MongoDB adapter for tDiary}
  spec.summary       = %q{MongoDB adapter for tDiary}
  spec.homepage      = "https://github.com/tdiary/tdiary-io-mongodb"
  spec.license       = "GPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mongoid", "~> 7.0"
  spec.add_dependency "mongo", "< 2.9.0"
  spec.add_dependency "hikidoc"
  spec.add_dependency "tdiary", ">= 5.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
