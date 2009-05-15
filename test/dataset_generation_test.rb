require File.dirname(__FILE__) + '/test_helper'

class DatasetGenerationTest < Test::Unit::TestCase
  def setup
    prefs = {
      :p1 => {:u1 => 1, :u2 => 1, :u3 => 1},
      :p2 => {:u2 => 1},
      :p3 => {:u3 => 1, :u5 => 1},
      :p4 => {:u1 => 1, :u4 => 1},
      :p5 => {:u1 => 1, :u4 => 1, :u5 => 1}
    }
    @rv = HasRelated.generate_dataset(prefs)
  end

  def test_tied_game
    assert [:p2, :p3, :p4].include?( @rv[:p1].first.last )
  end

  def test_one_of_many
    assert_equal :p1, @rv[:p2].first.last
  end

  def test_clear_winner
    assert_equal :p4, @rv[:p5].first.last
    assert_equal :p3, @rv[:p5][1].last
  end

  def test_no_relation
    assert !@rv[:p3].map{|v| v.last }.include?( :p4 )
  end

end
