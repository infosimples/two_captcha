# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'two_captcha/version'

Gem::Specification.new do |spec|
  spec.name          = "two_captcha"
  spec.version       = TwoCaptcha::VERSION
  spec.authors       = ["Marcelo Mita", "Rafael Barbolo"]
  spec.email         = ["team@infosimples.com.br"]
  spec.summary       = %q{Ruby API for 2Captcha (Captcha Solver as a Service)}
  spec.description   = %q{TwoCaptcha allows you to solve captchas with manual labor}
  spec.homepage      = "https://github.com/infosimples/two_captcha"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")

  # Since our currently binstubs are used only during the gem's development, we
  # are ignoring them in the gem specification.
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
end
