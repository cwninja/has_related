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

    def file_for_class(klass)
      File.join(Rails.root, "db", "similar_items_datasets", klass.to_s.underscore + ".bin")
    end

    def similar_items(item, count)
      ids = similar_item_ids(item, count)
      (item.class.find_all_by_id(ids) || []).sort_by{|item| ids.index(item.id) }.first(count)
    end


    def similar_item_ids(item, count = nil)
      dataset = similar_items_dataset(item.class.name) || {}
      rankings = dataset[item.id] || []
      rankings = rankings.first(count) if count
      rankings.map{|_, id| id}
    end

    def similarity(item1, prefs_item1, item2, prefs_item2, people)
      people.inject(0){|acc, person|
        acc + prefs_item2[person] * prefs_item1[person]
      }
    end

    def generate_dataset(prefs, &block)
      all_results = {}
      items = prefs.keys

      prefs.each do |item1, item1_prefs|
        agregated_recomendation_map = []

        item1_people = item1_prefs.keys

        prefs.each do |item2, item2_prefs|
          unless item1 == item2
            item_similarity = similarity(item1, item1_prefs, item2, item2_prefs, item1_people & item2_prefs.keys)
            agregated_recomendation_map << [item_similarity, item2] if item_similarity > 0
          end
        end

        all_results[item1] = agregated_recomendation_map.sort_by{|count, item1| -count}.first(16) if agregated_recomendation_map.any?

        yield [item1, agregated_recomendation_map] if block_given?
      end

      return all_results
    end

    def dump_dataset(prefs, total_people, klass, &block)
      ensure_data_dir_exists!(klass)
      dataset = generate_dataset(prefs, total_people, &block)
      write_dataset_to_disk(dataset, klass)
    end

    def dump_grouped_datasets(grouped_prefs, klass, &block)
      ensure_data_dir_exists!(klass)
      dataset = Hash.new
      grouped_prefs.each do |id, prefs|
        dataset.merge! generate_dataset(prefs, &block)
      end
      write_dataset_to_disk(dataset, klass)
    end

    def similar_items_dataset(klass_name)
      @similar_items_dataset ||= {}
      return @similar_items_dataset[klass_name] if @similar_items_dataset[klass_name]

      if File.readable? file_for_class(klass_name)
        @similar_items_dataset[klass_name] = Marshal.load(File.open(file_for_class(klass_name)))
      else
        @similar_items_dataset[klass_name] = {}
      end

      return @similar_items_dataset[klass_name]
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
