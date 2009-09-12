module ActionView
  module ITable

    def itable( name, options, &block )

      tbl = ITableModule::Table.new( name, options )
      yield tbl

      # thru the yield, the user has added columns via Table#column
     
      # get the list of column numbers that are printable columns
      printable_columns = (0..tbl.headers.length-1).collect{ |ix| ix if tbl.headers[ix] }.compact

      # write out the filters
      res = "<div id=itable_filter_block><form action=#{url_for}>\n"
      tbl.filters.each do |f|
        res << "<div id=filter>#{f.name.gsub("_"," ")}\n"
        res << select_tag(
                 "#{tbl.name}[#{f.name}]",
                 options_for_select( 
                   f.options.collect{ |opt| [ opt.label, opt.name.to_s ] }, 
                   tbl.settings[f.name.to_s]
                 ),
                 :onchange => "form.submit();"  
                )
        res << "</div>\n"
      end 
      res << "</form></div>\n"

      if tbl.is_empty
        res << "<p>No rows to display.</p>"
        return res
      end

      #write out the headers
      hdrlinks = (0..tbl.headers.length-1).collect{ |i| { 'sort_by' => i } }
      hdrlinks[ tbl.settings[ 'sort_by' ].to_i || 0 ].merge!( { 'sort_asc' => !(tbl.settings['sort_asc']=='true') } )
      hdrlinks.collect!{ |h| url_for( {tbl.name.to_sym => h} ) }
      hdrlinks = hdrlinks.zip( tbl.headers ).collect{ |hlink, htext| "<th>#{link_to( htext, hlink )}</th>" }
      res << "<div id=table>
                <table #{ tbl.attrs.collect{ |k,v| k.to_s + "='" + v.to_s + "'" }.join("\n")} >
                  <tr>
                    #{hdrlinks.values_at( *printable_columns ).join("\n")}
                  </tr>"

      #write the data
      tbl.sort_data
      tbl.rows.each do |r|
        res << "<tr>#{ r.values_at( *printable_columns ).collect{ |c| 
                         "<td>" + (c.to_s || '') + "</td>\n" 
                       }.join 
                    }</tr>"
      end
      res << "</table>\n</div>\n"
      res
    end
  end
end 
