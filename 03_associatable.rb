require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    return "humans" if self.class_name.downcase === "human"
    self.class_name.downcase.pluralize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.foreign_key = options[:foreign_key] || "#{name.to_s}_id".to_sym
    self.primary_key = options[:primary_key] || :id
    self.class_name = options[:class_name] || name.to_s.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    self.primary_key = options[:primary_key] || :id
    self.class_name = options[:class_name] || name.to_s.singularize.capitalize
  end
end

module Associatable

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      key = send(options.foreign_key)
      options.model_class.where(options.primary_key => key)[0]
    end
  end

  def has_many(name, options = {})
    options =  HasManyOptions.new(name, self.name, options)

    define_method(name) do
      key = send(options.primary_key)
      options.model_class.where(options.foreign_key => key)
    end
  end

  def assoc_options

  end
end

class SQLObject
  extend Associatable
end
