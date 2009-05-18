require File.dirname(__FILE__) + '/../lib/has_related'
if defined? ActiveRecord
  ActiveRecord::Base.send(:include, HasRelated)
end

