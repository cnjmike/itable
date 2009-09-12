module ActionController
  module ITable

      def update_itable_params_from_request_params( table_name )
       
        session[ "ITABLE_#{table_name}" ] = 
          ( session[ "ITABLE_#{table_name}" ] || {} ).merge( params[ table_name ] || {} )
      end 

  end
end
