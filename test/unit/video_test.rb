require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/mini_ffmpeg'

class VideoTest < Test::Unit::TestCase

  context 'MiniFfmpeg class tests' do

    setup do

      @output = <<EOF
FFmpeg version SVN-rUNKNOWN, Copyright (c) 2000-2007 Fabrice Bellard, et al.
  configuration: --enable-libmp3lame --enable-liba52 --disable-debug --enable-libfaad --enable-libfaac --enable-gpl --enable-xvid --enable-libdts --enable-pthreads --enable-libvorbis --enable-pp --enable-libtheora --enable-libogg --enable-libgsm --disable-debug --enable-shared --prefix=/usr
  libavutil version: 49.3.0
  libavcodec version: 51.38.0
  libavformat version: 51.10.0
  built on Jan 20 2009 12:14:42, gcc: 4.2.4 (Ubuntu 4.2.4-1ubuntu3)

Seems stream 0 codec frame rate differs from container frame rate: 1000.00 (1000/1) -> 25.00 (25/1)
Input #0, flv, from '2.flv':
  Duration: 00:00:41.1, start: 0.000000, bitrate: N/A
  Stream #0.0: Video: flv, yuv420p, 480x360, 25.00 fps(r)
Must supply at least one output file
EOF

     @output2 = <<EOF
FFmpeg version SVN-rUNKNOWN, Copyright (c) 2000-2007 Fabrice Bellard, et al.
  configuration: --enable-libmp3lame --enable-liba52 --disable-debug --enable-libfaad --enable-libfaac --enable-gpl --enable-xvid --enable-libdts --enable-pthreads --enable-libvorbis --enable-pp --enable-libtheora --enable-libogg --enable-libgsm --disable-debug --enable-shared --prefix=/usr
  libavutil version: 49.3.0
  libavcodec version: 51.38.0
  libavformat version: 51.10.0
  built on Jan 20 2009 12:14:42, gcc: 4.2.4 (Ubuntu 4.2.4-1ubuntu3)
[matroska @ 0xb7ee2a74]Ignoring seekhead entry for ID=0x1549a966
[matroska @ 0xb7ee2a74]Ignoring seekhead entry for ID=0x1654ae6b
[matroska @ 0xb7ee2a74]Ignoring seekhead entry for ID=0x114d9b74
[matroska @ 0xb7ee2a74]Unknown entry 0x73a4 in info header
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55aa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x23314f - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55ee - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0xaa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55aa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x23314f - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55ee - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0xaa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55aa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x23314f - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55ee - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0xaa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55aa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x23314f - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55ee - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0xaa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x6d80 - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55aa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x23314f - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x55ee - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0xaa - ignoring
[matroska @ 0xb7ee2a74]Unknown track header entry 0x6d80 - ignoring
Input #0, matroska, from '5.mkv':
  Duration: 00:23:26.0, bitrate: N/A
  Stream #0.0: Video: mpeg4, yuv420p, 720x480, 29.97 fps(r)
  Stream #0.1: Audio: ac3, 48000 Hz, stereo
  Stream #0.2: Audio: ac3, 48000 Hz, stereo
Must supply at least one output file
EOF

      @audio_output = <<EOF
FFmpeg version SVN-rUNKNOWN, Copyright (c) 2000-2007 Fabrice Bellard, et al.
  configuration: --enable-libmp3lame --enable-liba52 --disable-debug --enable-libfaad --enable-libfaac --enable-gpl --enable-xvid --enable-libdts --enable-pthreads --enable-libvorbis --enable-pp --enable-libtheora --enable-libogg --enable-libgsm --disable-debug --enable-shared --prefix=/usr
  libavutil version: 49.3.0
  libavcodec version: 51.38.0
  libavformat version: 51.10.0
  built on Jan 20 2009 12:14:42, gcc: 4.2.4 (Ubuntu 4.2.4-1ubuntu3)
Input #0, mp3, from '1.mp3':
  Duration: 00:06:01.4, start: 0.000000, bitrate: 128 kb/s
  Stream #0.0: Audio: mp3, 44100 Hz, stereo, 128 kb/s
Must supply at least one output file
EOF
    end

    should 'MiniFfmpeg::MediaTime should decode FFMPeg output for durations' do
      duration = MiniFfmpeg::MediaTime.new(@output)
      assert_equal duration.to_s,    '00:00:41.1'
      assert_equal duration.hours,   0
      assert_equal duration.minutes, 0
      assert_equal duration.seconds, 41
      assert_equal duration.micro,   1
      assert_equal duration.to_i,    41,   'to_i mismatch'
      assert_equal duration.to_f,    41.1, 'to_f mismatch'
      #slightly more complicated output
      duration = MiniFfmpeg::MediaTime.new(@output2)
      assert_equal duration.to_s,    '00:23:26.0'
      assert_equal duration.hours,   0,    'hours mismatch'
      assert_equal duration.minutes, 23,   'minutes mismatch'
      assert_equal duration.seconds, 26,   'seconds mismatch'
      assert_equal duration.micro,   0,    'micro mismatch'
      assert_equal duration.to_i,    1406,  'to_i mismatch'
      assert_equal duration.to_f,    1406.0, 'to_f mismatch'
    end

    should 'MiniFfmpeg::Resolution should recognize video files' do
      assert_equal MiniFfmpeg::Resolution.is_video?(@output),       true
      assert_equal MiniFfmpeg::Resolution.is_video?(@output2),      true
      assert_equal MiniFfmpeg::Resolution.is_video?(@audio_output), false
    end

    should 'MiniFfmpeg::Resolution should extract video resolution' do
      res = MiniFfmpeg::Resolution.new(@output)
      assert_equal res.to_s,   '480x360'
      assert_equal res.width,  480
      assert_equal res.height, 360
      #
      res = MiniFfmpeg::Resolution.new(@output2)
      assert_equal res.to_s,   '720x480'
      assert_equal res.width,  720
      assert_equal res.height, 480
    end

    should 'MiniFfmpeg::Resolution should calculate new resolution preserving the aspect ratio' do
      res = MiniFfmpeg::Resolution.new(@output)
      height = res.resized_height_by_width(320)
      assert_equal height, 240
      #
      res = MiniFfmpeg::Resolution.new(@output2)
      height = res.resized_height_by_width(320)
      assert_equal height, 214
    end

  end

  context 'video encoding' do

    setup do
      @user = create_user
    end

    should 'save video file matadata' do
      assert false, 'todo'
    end

    should 'convert given video file to an avi file' do
      Video.save_and_queue_video_job(fixture_file_upload('/files/2.avi', 'stream/octet'), @user) do |video|
        assert File.exist?(video.original_file), 'video file not copied to library'
        #job created?
        assert Job.find_by_id(video.job_id, 'could not file job')
        #convert to flv
        video.convert_to_flash_and_generate_splash do |progress|
          puts progress 
        end
        assert File.exists?(video.flv_file(:full_path => true)), 'FLV not found'
        assert File.exists?(video.splash_file), 'FLV preview file not found'
      end
      
    end


  end

end
