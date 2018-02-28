require 'sqb/version'
require 'sqb/safe_string'

require 'sqb/query'
require 'sqb/select'
require 'sqb/update'
require 'sqb/delete'
require 'sqb/insert'

module SQB
  def self.safe(string)
    SafeString.new(string)
  end
end
