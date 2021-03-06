require_relative 'associatable-one_step_connections'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_table = through_options.table_name
      through_pk = through_options.primary_key
      through_fk = through_options.foreign_key

      source_options = through_options.model_class.assoc_options[source_name]
      source_table = source_options.table_name
      source_pk = source_options.primary_key
      source_fk = source_options.foreign_key

      key_val = self.send(through_fk)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT #{source_table}.*
        FROM #{through_table}
        JOIN #{source_table}
        ON #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE #{through_table}.#{through_pk} = ?
      SQL
      source_options.model_class.parse_all(results).first
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      if through_options.class == HasManyOptions
        through_table = through_options.table_name
        through_pk = through_options.primary_key
        through_fk = through_options.foreign_key
      else
        through_table = through_options.table_name
        through_fk = through_options.primary_key
        through_pk = through_options.foreign_key
      end

      source_options = through_options.model_class.assoc_options[source_name]
      if source_options.class == HasManyOptions
        source_table = source_options.table_name
        source_pk = source_options.primary_key
        source_fk = source_options.foreign_key
      else
        source_table = source_options.table_name
        source_fk = source_options.primary_key
        source_pk = source_options.foreign_key
      end

      key_val = self.send(through_pk)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT #{source_table}.*
        FROM #{through_table}
        JOIN #{source_table}
        ON #{source_table}.#{source_fk} = #{through_table}.#{source_pk}
        WHERE #{through_table}.#{through_fk} = ?
      SQL
      source_options.model_class.parse_all(results)
    end
  end

end
