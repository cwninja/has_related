require File.dirname(__FILE__) + '/lib/has_related'
if defined? ActiveRecord
  ActiveRecord::Base.send(:include, HasRelated)
end

ENV['INLINEDIR'] = File.join(Rails.respond_to?(:root) ? Rails.root : RAILS_ROOT, 'tmp', 'rubyinline')
begin
  FileUtils.mkdir_p ENV['INLINEDIR'] unless File.directory? ENV['INLINEDIR']
  require 'inline'
  require File.dirname(__FILE__) + '/lib/optimizations'
rescue LoadError
  STDERR.puts "Warning: You are using the ruby version of yonder algorithms... they are slow. Let us compile some C."
end
