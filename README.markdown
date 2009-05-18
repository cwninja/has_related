Has related is used by Reevoo to create similar product recommendations.

Example Index Builder:

    namespace :apache do
      desc "Parse the last apache logs for similar products"
      task :find_similar_products => :environment do
        log_files = ENV["LOG_FILES"] || "/var/log/httpd/access.*.gz"

        prefs = Hash.new{|h,k| h[k] = Hash.new(0) }

        Dir.glob(log_files) do |filename|
          File.open(filename) do |f|
            Zlib::GzipReader.new(f).each_line do |line|
              product_id, ip = parse_log_line(line)
              if product_id and ip
                prefs[product_id][ip] += 1
              end
            end
          end
        end

        HasRelated.dump_dataset(prefs, "Product")
      end
    end

(You will need to define your own `parse_log_line` method)


Example Usage:

    class Product < ActiveRecord::Base
      has_related "related_products"
    end

    most_related_product = Product.related_products.first

Happy hunting.