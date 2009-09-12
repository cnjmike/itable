module ITableModule
 
#---------------------------------------------
#
# class BottomlessNil
#
#---------------------------------------------
class BottomlessNil

  def initialize
  end

  def to_s
    nil
  end

  def id
    nil
  end

  def method_missing( meth, *args )
    self
  end
end

#---------------------------------------------
#
# class Filter
#
#---------------------------------------------
  class Filter
  attr_accessor :name, :options, :options_join_string, :url
  attr_reader   :selected_value

    def initialize( name, options_join_string='' )
      @name = name.to_s
      @options = []
      @options_join_string = options_join_string
    end
  
    def add_option( label, sym, condition ) 
      @options << ITableModule::FilterOption.new( self, label, sym, condition )
    end

    def selected_value=( val )
      @selected_value = val
      opt = @options.find{ |o| o.name == val }.find
      opt.is_selected = true if opt
    end

    def conditions( control_params )
      if (control_params || {}).include? @name
        @options.find{ |opt| opt.name == control_params[ @name ] }.condition || "1=1"
      else
        "1=1"
      end
    end      
  end # class ITableModule::Filter

#-----------------------------------------------
#
# class FilterOption
#
#-----------------------------------------------
  class FilterOption
  attr_accessor :filter, :name, :label, :condition, :is_selected

    def initialize( filter, label, name, condition )
      @filter = filter
      @is_selected = false
      @label = label
      @name = name.to_s
      @condition = condition
    end
  
  end # FilterOption

#-------------------------------------------------
#
# class Table
#
#------------------------------------------------
  class Table
  attr_accessor :name, :attrs, :rows, :headers, :filters, :settings, :sort_default, :is_empty
 
    def initialize( name, options )
      @name                = name
      @settings            = {}
      @sort_default        = 0
      @filters              = []
      @headers             = []
      @click_sorts_by_col  = []
      @rows                = []
      options.each do |opt, val|
        case opt
          when :settings:     @settings   = val
        end
      end
      options.delete( :settings )
      @attrs = options
      @is_empty = true
      
    end

    def filter( f )
      @filters << f
    end
    
    def with( collection, &block )  

      if collection.length > 0
        @is_empty = false
        collection.each do |c|
          @rows << Array.new
          yield c
        end
      else
         @rows << Array.new
         yield BottomlessNil.new
      end
    end

    def column( label, data, options={} )
    
      if @rows.length == 1

        # adding the first row, so update headers too

        @headers << label
        if options.include? :sort_by
          # add a column for the sort_by data and point to it
          @click_sorts_by_col << @headers.length 
          @headers << nil
          @click_sorts_by_col << nil
        else
          @click_sorts_by_col << @headers.length - 1
        end

        if options.include? :sort_default
          @sort_default = @headers.length - 1 
        end
      end

      @rows.last << data
      if options.include? :sort_by
        @rows.last << options[:sort_by]
      end
    end

    def sort_data
 
      sort_col = @click_sorts_by_col[ @settings[ 'sort_by' ].to_i || @sort_default ]
      puts "Sort by: #{@settings[ 'sort_by' ].to_i || @sort_default } -> #{sort_col}"
      puts @rows.inspect
      @rows.sort!{ |a,b| a[ sort_col ] <=> b[ sort_col ] }
      @rows.reverse! if @settings['sort_asc'] == 'false'
    end

  end #class Table
end #module
