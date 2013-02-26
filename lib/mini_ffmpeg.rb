require File.join(File.dirname(__FILE__), '/image_temp_file')

module MiniFfmpeg
  
  class MiniFfmpegError < RuntimeError; end

  VERSION    = '1.0'
  FFMPEG_BIN = `which ffmpeg`.strip

  class Media
    
    attr :tempfile
    attr_reader :duration, :resolution, :time_taken
    attr_accessor :type

    def initialize(input_path, tempfile = nil)
      #sanity check... does ffmpeg exist and is it in the path?
      raise 'Cannot find FFMPEG in your system PATH' if FFMPEG_BIN.blank?
      raise "File #{input_path} does not exist!" unless File.exist?(input_path)
      #continue
      @path       = input_path
      @tempfile   = tempfile # ensures that the tempfile will stick around until this media is garbage collected.
      @time_taken = 0
      # Parse file for video properties
      parse_file_for_metadata
    end

    #convert input file to FLV using given new width
    def convert_to_flv(flv_file, width)
      #need to resize?
      if width != @resolution.width
        height = @resolution.resized_height_by_width(width)
      else
        height = @resolution.height
      end
      command = ['-ar 22050 -ab 32 -acodec libmp3lame', "-s #{width}x#{height}", '-vcodec flv -r 25 -qscale 8 -f flv', "-y #{flv_file}"]
      if block_given?
        run_command(command) {|progress| yield progress}
      else
        run_command(command)
      end
    end

    def convert_to_mp3(mp3_file, bitrate, length = 0)
      command = ["-ab #{bitrate}", "-y #{mp3_file}"]
      command << "-t #{length.to_s}" if length > 0
      if block_given?
        run_command(command) {|progress| yield progress}
      else
        run_command(command)
      end
    end

    def generate_splash_image(splash_file, offset = 10)
      command = ["-ss #{MediaTime.seconds_to_s(offset)}", '-t 00:00:01 -vcodec mjpeg -vframes 1 -an', "-f rawvideo #{splash_file}"]
      run_command(command)
    end


    protected

    def parse_file_for_metadata
      output = run_command
      @duration = MiniFfmpeg::MediaTime.new(output)
      if MiniFfmpeg::Resolution.is_video?(output)
        @type       = :video
        @resolution =  MiniFfmpeg::Resolution.new(output)
      else
        @type = :audio
      end
    end

    def run_command(args = [])
      args.collect! do |arg|
        arg = arg.to_s
        arg = %|"#{arg}"| unless arg[0] == ?- # values quoted because they can contain characters like '>', but don't quote switches
        arg
      end
      #log and run
      started = Time.now
      #FFMpeg outputs to STDERR... redirect to capture output for further processing
      command = "nice -n 19 #{FFMPEG_BIN} -i #{@path} -y #{args.join(' ')} 2>&1" #-y forces output
      RAILS_DEFAULT_LOGGER.debug("MiniFFMPEG command: #{command}")
      #if block supplied then need to pipe through IO to capture ffmpeg output for progress reporting
      if block_given?
        progress = nil
        IO.popen(command) do |pipe|
          pipe.each("\r") do |line|
            if line =~ /time=(\d+)\.(\d+)/
              if @duration.to_i > 0
                p = (($1.to_f / @duration.to_f) * 100).to_i
              else
                p = 0
              end
              p = 100 if p > 100
              if progress != p
                progress = p
                #pass progress callback
                yield progress
                $defout.flush
              end
            end
          end
          #done...yield 100 incase we are at <100 here
          yield 100
        end
      else
        output = eval("`#{command}`")
        @time_taken = Time.now - started
        return output #return required as ffmpeg will complain of no given output file... which we don't supply when querying the uploaded media 
      end
      @time_taken = Time.now - started
      #
      raise MiniFfmpegError, "FFMPeg command #{command} failed: Error Given #{$?}" if $?.exitstatus != 0
    end


  end

  class CommandBuilder

    attr :args

    def initialize
      @args = []
    end

    def method_missing(symbol, *args)
      @args << "-#{symbol}"
      @args += args
    end

    def +(value)
      @args << "+#{value}"
    end

  end

  ##MediaTime will parse Duration string for supported video and audio files
  class MediaTime

    attr_reader :to_s, :hours, :minutes, :seconds, :micro

    def initialize(input)
      @hours = @minutes = @seconds = '00'
      @micro = '0'
      #
      if input[/Duration:\s(\d+):(\d+):(\d+)\.(\d+),/]
        @to_s    = input[/Duration:\s(\d+:\d+:\d+\.\d+),/,1]
        @hours   = input[/Duration:\s(\d+):(\d+):(\d+)\.(\d+),/,1].to_i
        @minutes = input[/Duration:\s(\d+):(\d+):(\d+)\.(\d+),/,2].to_i
        @seconds = input[/Duration:\s(\d+):(\d+):(\d+)\.(\d+),/,3].to_i
        @micro   = input[/Duration:\s(\d+):(\d+):(\d+)\.(\d+),/,4].to_i
      else
        raise "Unrecognised timestamp format #{input}"
      end
    end

    def self.seconds_to_s(sec)
      (DateTime.new(0) + sec.seconds).strftime '%H:%M:%S'
    end

    def to_f
      "#{to_i}.#{@micro}".to_f
    end

    def to_i
      @hours.to_i.hours + @minutes.to_i.minutes + @seconds.to_i.seconds
    end
    
  end

  class Resolution

    attr_reader :to_s, :width, :height

    #check if video stream present in video file
    def self.is_video?(input)
      !input[/Stream.+Video.+(?:\s(\d+x\d+))/].nil?
    end

    def initialize(input)
      @to_s = input[/Stream.+Video.+(?:\s(\d+x\d+))/]
      unless @to_s.blank?
        @to_s   = input[/Stream.+Video.+(?:\s(\d+x\d+))/,1]
        @width  = input[/Stream.+Video.+(?:\s(\d+)x(\d+))/,1].to_i
        @height = input[/Stream.+Video.+(?:\s(\d+)x(\d+))/,2].to_i
      else
        raise "Is not video file based on input:\n #{input}"
      end
    end

    #Given width and height, will recalculate the video's new resolution whilst preserving the aspect ratio
    #resized video's dimensions must not exceed given width or height
    def resized_height_by_width(new_width)
      raise 'Width must be even' if new_width % 2 != 0
      orig_ar      = @width.to_f / @height.to_f
      calc_height  = (new_width.to_f / orig_ar).to_i
      calc_height += 1 if calc_height % 2 != 0
      calc_height
    end

  end

    
end
