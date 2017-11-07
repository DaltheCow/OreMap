require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)

    cols = params.keys.map {|key| key.to_s}
    col_names = cols.map {|col| "#{col} = ?"}.join(' AND ')

    vals = params.values

    results = DBConnection.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE #{col_names}
    SQL
    results.map {|result| self.new(result)}
  end
end

class SQLObject
  extend Searchable
end
