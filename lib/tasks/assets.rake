# Place this code in lib/tasks/assets.rake

namespace :assets do
  desc "Create .gz versions of assets"
  task :gzip => :environment do
    zip_types = /\.(?:css|html|js|otf|svg|eot|woff|ttf|txt|xml)$/

    public_assets = File.join(
      Rails.root,
      "public",
      Rails.application.config.assets.prefix)

    Dir["#{public_assets}/**/*"].each do |f|
      next unless f =~ zip_types

      mtime = File.mtime(f)
      gz_file = "#{f}.gz"
      next if File.exist?(gz_file) && File.mtime(gz_file) >= mtime

      puts "Writing gzip file for #{f}"

      File.open(gz_file, "wb") do |dest|
        gz = Zlib::GzipWriter.new(dest, Zlib::BEST_COMPRESSION)
        gz.mtime = mtime.to_i
        IO.copy_stream(open(f), gz)
        gz.close
      end

      File.utime(mtime, mtime, gz_file)
    end
  end

  desc "Compile React components with webpack"
  task :webpack do
    sh "NODE_ENV=#{Rails.env} npm run build"
  end

  # Hook into existing assets:precompile task
  Rake::Task["assets:precompile"].enhance do
    Rake::Task["assets:gzip"].invoke
  end
end