require 'fileutils'
module HasRelated
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_related(method_name = "related_items")
      class_eval do
        define_method method_name do |count|
          HasRelated.similar_items(self, count)
        end
      end
    end
  end

  class << self

    def sim_pearson(prefs, item1, item2, total_people)
      people = prefs[item].keys & prefs[other].keys
      n = total_people
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

    def file_for_class(klass)
      File.join(Rails.root, "db", "similar_items_datasets", klass.to_s.underscore + ".bin")
    end

    def similar_items(item, count)
      ids = similar_item_ids(item, nil)
      (item.class.find_all_by_id(ids) || []).sort_by{|item| ids.index(item.id) }.first(count)
    end

    def similar_item_ids(item, count)
      data = [dataset(item.class)]
      all_related_ids = (data[item.id] || []).map{|_, id| id}
      if count
        all_related_ids.first(count)
      else
        all_related_ids
      end
    end
    
    def dataset(klass)
      @dataset ||= {}
      return @dataset[klass.to_s] if @dataset[klass.to_s]
      if File.readable? file_for_class(klass)
        @dataset[klass.to_s] = Marshal.load(File.open(file_for_class(klass)))
      else
        @dataset[klass.to_s] = []
      end
    end

    def generate_dataset(prefs, total_people = nil, &block)
      all_results = {}
      total_people ||= prefs.inject(Set.new){|acc, (k, users)| acc += users.keys; acc }.size

      items = prefs.keys

      for item in items
        agregated_recomendation_map = []

        items.each do |other|
          next unless other != item && (similarity = sim_pearson(prefs, item, other, total_people)) > 0
          agregated_recomendation_map << [similarity, other]
        end

        all_results[item] = agregated_recomendation_map.sort.reverse.first(16) if agregated_recomendation_map.any?

        yield [item, agregated_recomendation_map] if block_given?
      end

      return all_results
    end

    def dump_dataset(prefs, total_people, klass, &block)
      ensure_data_dir_exists!(klass)
      dataset = generate_dataset(prefs, total_people, &block)
      write_dataset_to_disk(dataset, klass)
    end

    def dump_grouped_datasets(grouped_prefs, grouped_total_people, klass, &block)
      ensure_data_dir_exists!(klass)
      dataset = Hash.new
      grouped_prefs.each do |id, prefs|
        dataset.merge! generate_dataset(prefs, grouped_total_people[id], &block)
      end
      write_dataset_to_disk(dataset, klass)
    end

  private
    def ensure_data_dir_exists!(klass)
      FileUtils.mkdir_p(File.dirname(file_for_class(klass))) unless File.directory? File.dirname(file_for_class(klass))
    end

    def write_dataset_to_disk(dataset, klass)
      File.open(file_for_class(klass), "w") do |io|
        Marshal.dump(dataset, io)
      end
    end
  end
end
