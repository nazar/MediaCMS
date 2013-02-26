desc 'Rebrand view photos'

namespace :photos do

  desc "watermarks and annotates all photos"
  task :rebrand_photos => :environment do
  begin
    include MiniMagick
    #
    photos = ENV['start_from'].to_i > 0 ? Photo.all(:conditions => ['id >= ?', ENV['start_from'].to_i]) : Photo.all
    puts "Database contains #{photos.length} photos"
    #get all photos and process
    photos.each do |photo|
      if File.exists?(photo.original_file)
        puts "annotating file #{photo.preview_file}"
        Photo.transaction do
          watermark_preview_file(photo.preview_file)
          annotate_preview_file(photo.preview_file)
        end  
      else
        puts "image #{photo.original_file} not found... skipping"
      end
    end
    rescue => error
      puts "Error: " + error
    end
  end

  desc "thumbnails, swatches, watermarks and annotates all photos"
  task :process_all_photos => :environment do
  begin
    include MiniMagick
    #
    photos = ENV['start_from'].to_i > 0 ? Photo.all(:conditions => ['id >= ?', ENV['start_from'].to_i]) : Photo.all
    puts "Database contains #{photos.length} photos"
    #get photos and process
    photos.each do |photo|
      if File.exists?(photo.original_file)
        puts "annotating file #{photo.preview_file}"
        Photo.transaction do
          photo.create_preview_and_thumbnail_files
          photo.save
        end  
      else
        puts "image #{photo.original_file} not found... skipping"
      end
    end
    rescue => error
      puts "Error: " + error
    end
  end


end
