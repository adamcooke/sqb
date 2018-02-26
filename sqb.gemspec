require_relative './lib/sqb/version'
Gem::Specification.new do |s|
  s.name          = "sqb"
  s.description   = %q{A friendly SQL builder for MySQL.}
  s.summary       = %q{This gem provides a friendly DSL for constructing MySQL queries.}
  s.homepage      = "https://github.com/adamcooke/sqb"
  s.version       = SQB::VERSION
  s.files         = Dir.glob("{lib}/**/*")
  s.require_paths = ["lib"]
  s.authors       = ["Adam Cooke"]
  s.email         = ["me@adamcooke.io"]
  s.licenses      = ['MIT']
end
