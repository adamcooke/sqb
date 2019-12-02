require 'sqb/version'
require 'sqb/safe_string'
require 'sqb/escaping'

require 'sqb/query'
require 'sqb/select'
require 'sqb/update'
require 'sqb/delete'
require 'sqb/insert'
require 'sqb/replace'

module SQB

  extend SQB::Escaping

  STAR = Object.new

  def self.safe(string)
    SafeString.new(string)
  end

  def self.column(column)
    with_table_and_column(column) do |table, column|
      safe(escape_and_join(table, column))
    end
  end

end
