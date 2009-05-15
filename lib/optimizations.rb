require 'inline'
module HasRelated
  class Optimizations
    InlineC = Module.new do
      inline do |builder|
        builder.include '<math.h>'
        builder.c <<-EOC
        /*
          people.each do |person|
            prefs1_item = prefs[item1][person] || 0.0
            prefs2_item = prefs[item2][person] || 0.0
            sum += prefs2_item * prefs1_item
          end

          sum / item_count
        */
        double c_similarity(VALUE people, int people_count, int item_count, VALUE item1_prefs, VALUE item2_prefs)
        {
          double sum = 0.0;

          VALUE * people_a = RARRAY(people)->ptr;
          int i;
          for(i = 0; i < people_count; i++) {
            VALUE person = people_a[i];
            
            VALUE item1_person_score_ob;
            VALUE item2_person_score_ob;

            double item1_person_score = 0.0;
            double item2_person_score = 0.0;

            if (st_lookup(RHASH(item1_prefs)->tbl, person, &item1_person_score_ob))
              item1_person_score = NUM2DBL(item1_person_score_ob);

            if (st_lookup(RHASH(item2_prefs)->tbl, person, &item2_person_score_ob))
              item2_person_score = NUM2DBL(item2_person_score_ob);
            
            sum += item1_person_score * item2_person_score;
          }

          return sum / item_count;
        }
        EOC
      end
    end
    class << self
      include InlineC
    end
  end

  def self.similarity(prefs, item1, item2)
    people = prefs[item1].keys & prefs[item2].keys
    return 0 if people.empty?

    item1_prefs = prefs[item1]
    item2_prefs = prefs[item2]

    item_count = (item1_prefs.keys | item2_prefs.keys).size
    sum = 0.0

    Optimizations.c_similarity(people, people.size, item_count, item1_prefs, item2_prefs)
  end

end
