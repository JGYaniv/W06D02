require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @columns.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col_name|
      define_method(col_name) do
        self.attributes[col_name] ||= nil
      end
      setter = (col_name.to_s + "=").to_sym
      define_method(setter) do |value = nil|
        self.attributes[col_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
    attr_reader :table_name
  end

  def self.table_name
    return @table_name if @table_name
    self.name.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    self.parse_all(data)
  end

  def self.parse_all(results)
    data = results.map do |result|
      self.new(result)
    end
    data
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT id
      FROM #{self.table_name}
      WHERE id = ?
    SQL
    self.parse_all(data).first
  end

  def initialize(params = {})
    columns = self.class.columns
    
    params.each do |k, v|
      col = k.to_sym
      setter = (k.to_s + "=").to_sym

      if columns.include?(col)
        self.send("#{k}=", v)
      else
        raise "unknown attribute '#{col}'"
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
    col_names = self.class.columns.map(&:to_s).join(", ")
    question_marks = (["?"] * attribute_values.count).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
