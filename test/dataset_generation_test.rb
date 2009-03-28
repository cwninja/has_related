require File.dirname(__FILE__) + '/test_helper'

class DatasetGenerationTest < Test::Unit::TestCase
  def test_should_generate_dataset
    items = ["fish", "carrots", "hamsters", "beans", "bannanas"]
    users = ["vet", "vet2", "shop"]
    prefs = {
      "fish" => {"vet" => 1, "vet2" => 1, "shop" => 1},
      "carrots" => {"shop" => 1},
      "beans" => {"shop" => 1},
      "hamsters" => {"vet" => 1, "vet2" => 1},
      "bannanas" => {}
    }
    rv = HasRelated.generate_dataset(users, prefs)
    assert rv["beans"].find{|v| v.last == "carrots" }.first > 0
    assert_nil rv["beans"].find{|v| v.last == "hamsters" }
  end
end
