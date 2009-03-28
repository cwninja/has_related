require 'fileutils'
module HasRelated
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_related(method_name = "related_items")
      options[:on_class].class_eval do
        define_method method_name do
          Logic.similar_items(self, options)
        end
      end
    end
  end

  class << self

    def sim_pearson(prefs, people, item1, item2)
      n = people.length
      return 0 if n == 0

      sum1 = sum2 = sum1Sq = sum2Sq = pSum = 0.0

      people.each do |person|
        prefs1_item = prefs[item1][person] || 0.0
        prefs2_item = prefs[item2][person] || 0.0
        sum1   += prefs1_item
        sum2   += prefs2_item
        sum1Sq += prefs1_item ** 2
        sum2Sq += prefs2_item ** 2
        pSum   += prefs2_item * prefs1_item
      end

      num = pSum - ( ( sum1 * sum2 ) / n )
      den = Math.sqrt( ( sum1Sq - ( sum1 ** 2 ) / n ) * ( sum2Sq - ( sum2 ** 2 ) / n ) )

      return 0 if den == 0

      num / den
    end

    def similar_items(item, count, min_score = 0)
      item.class.find_by_id(similar_item_ids(item, count, min_score))
    end

    def file_for_class(klass)
      File.join(Rails.root, "db", "similar_items_datasets", klass.to_s.underscore + ".yml")
    end

    def similar_item_ids(item, count, min_score = 0)
      @dataset ||= {}
      @dataset[item.class] ||= YAML.load(File.open(file_for_class(item.class)))
      rankings = dataset[item.id]
      return [] unless rankings

      rankings = rankings.select {|score, _| score > min_score }
      rankings = rankings.sort_by {|score, _| -score}
      rankings = rankings[0..(count - 1)]
      rankings.map{|_, id| id}
    end

    def generate_dataset(users, prefs)
      items = prefs.keys
      results = {}
      items.each do |item|
        agregated_recomendation_map = items.reject{|other| other == item }.map{|other|
          [sim_pearson(prefs, users, item, other), other]
        }.sort_by{|score, _| -score}
        results[item] = agregated_recomendation_map
      end
      results
    end

    def dump_dataset(users, prefs, klass)
      FileUtils.mkdir_p(File.dirname(file_for_class(klass)))
      File.open(file_for_class(klass), "w") do |io|
        generate_dataset(users, prefs).to_yaml(io)
      end
    end
  end
end
