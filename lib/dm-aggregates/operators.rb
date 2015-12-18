module DataMapper
  module Aggregates
    module Operators
      def count
        DataMapper::Query::Operator.new(self, :count)
      end

      def min
        DataMapper::Query::Operator.new(self, :min)
      end

      def max
        DataMapper::Query::Operator.new(self, :max)
      end

      def avg
        DataMapper::Query::Operator.new(self, :avg)
      end

      def sum
        DataMapper::Query::Operator.new(self, :sum)
      end
      
      
      def sum_distinct
	      DataMapper::Query::Operator.new(self, :sum_distinct)
      end
      
      def count_distinct
	      DataMapper::Query::Operator.new(self, :count_distinct)
      end    
    end # module Operators
  end # module Aggregates
end # module DataMapper
