require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @cols if @cols
    all = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @cols = all[0].map {|item| item.to_sym}
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method("#{col}=") do |arg|
        attributes[col] = arg
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= (self.name == "Human" ? "humans" : self.name.tableize)
  end

  def self.all
    all = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(all)
  end

  def self.parse_all(results)
    results.map {|hash| self.new(hash)}
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE id = ?
    SQL
    return nil if result.empty?
    self.new(result.first)
  end

  def initialize(params = {})

    params.each do |key, value|
      if self.class.columns.include?(key.to_sym)
        send("#{key}=", value)
      else
        raise "unknown attribute '#{key}'"
      end
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    cols = attributes.keys
    col_names = cols.join(', ')

    ques_marks =  (['?'] * cols.length).join(', ')

    result = DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{ques_marks})
    SQL
    # self.send(:id=, DBConnection.last_insert_row_id)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols = attributes.keys
    col_names = cols.map {|col| "#{col} = ?"}.join(', ')

    result = DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL


  end

  def save
    self.id ? self.update : self.insert
  end
end
