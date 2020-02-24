# frozen_string_literal: true

require 'sqb/insert'

module SQB
  class Replace < Insert
    private

    def mysql_verb
      'REPLACE'
    end
  end
end
