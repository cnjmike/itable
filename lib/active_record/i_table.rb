module ActiveRecord
  module ITable
    module ClassMethods

      def create_itable_filter( name, &block )
        new_filter = ITableModule::Filter.new( name )
        self.instance_variable_set( "@#{name.to_s}", new_filter ) 
        self.instance_eval( 
          %{ def #{self.name}.#{name}
               @#{name}
             end
           } )
        yield new_filter
      end
    end

    def self.included( base )
      base.extend ClassMethods
    end

  end
end
