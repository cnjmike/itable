require "#{RAILS_ROOT}/vendor/plugins/i_table/i_table_module.rb"

ActiveRecord::Base.send        :include, ActiveRecord::ITable
ActionController::Base.send    :include, ActionController::ITable
ActionView::Base.send          :include, ActionView::ITable
