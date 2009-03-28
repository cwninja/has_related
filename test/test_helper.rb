$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'test/unit'
require 'fileutils'

class Test::Unit::TestCase #:nodoc:
end

module Rails
  def root
    if @tmpdir.nil?
      @tmpdir = File.join(ENV["TMPDIR"], "has_related")
      Dir.mkdir(@tmpdir) unless File.directory? @tmpdir
      ObjectSpace.define_finalizer(@tmpdir, proc{|id| FileUtils.remove_entry_secure @tmpdir })
    end
    @tmpdir
  end

  extend self
end

require "#{File.dirname(__FILE__)}/../init"
