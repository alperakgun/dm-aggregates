module DataMapper
  module Aggregates
    module DataObjectsAdapter
      extend Chainable

      def aggregate(query)
        fields = query.fields
        types  = fields.map { |p| p.respond_to?(:operator) ? String : p.primitive }

        field_size = fields.size

        records = []

        with_connection do |connection|
          statement, bind_values = select_statement(query)

          command = connection.create_command(statement)
          command.set_types(types)

          reader = command.execute_reader(*bind_values)

          begin
            while(reader.next!)
              row = fields.zip(reader.values).map do |field, value|
                if field.respond_to?(:operator)
                  send(field.operator, field.target, value)
                else
                  field.load(value)
                end
              end

              records << (field_size > 1 ? row : row[0])
            end
          ensure
            reader.close
          end
        end

        records
      end

      private

      def count(property, value)
        value.to_i
      end

      def min(property, value)
        property.load(value)
      end

      def max(property, value)
        property.load(value)
      end

      def avg(property, value)
        property.primitive == ::Integer ? value.to_f : property.load(value)
      end

      def sum(property, value)
        property.load(value)
      end
      
      def count_distinct(property, value)
        value.to_i
      end

      
      chainable do
        def property_to_column_name(property, qualify)
          case property
            when DataMapper::Query::Operator
              aggregate_field_statement(property.operator, property.target, qualify)

            when Property, DataMapper::Query::Path
              super

            else
              raise ArgumentError, "+property+ must be a DataMapper::Query::Operator, a DataMapper::Property or a Query::Path, but was a #{property.class} (#{property.inspect})"
          end
        end
      end

      def aggregate_field_statement(aggregate_function, property, qualify)
        column_name = if aggregate_function == :count && property == :all
          '*'
        else
          property_to_column_name(property, qualify)
        end

        case aggregate_function
          when :count then "COUNT(#{column_name})"
          when :sum   then "SUM(#{column_name})"
          when :min   then "MIN(#{column_name})"
          when :max   then "MAX(#{column_name})"
          when :avg   then "AVG(#{column_name})"
          when :count_distinct then "COUNT(DISTINCT(#{column_name}))"
          else raise "Invalid aggregate function: #{aggregate_function.inspect}"
        end
      end

    end # class DataObjectsAdapter
  end # module Aggregates
end # module DataMapper
