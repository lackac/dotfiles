extend_console "recorder", true, false do

  module Readline
    class History
      def self.record_line(line)
        return unless @_recordfile
        File.open(@_recordfile, 'ab') do |f|
          f.puts(line)
        end
      end

      def self.start_recording
        now = Time.now
        if @_recordfile
          puts "You are already recording to #{@_recordfile}."
          puts "Use the stop_recording method to stop this session."
          return
        else
          @_recordfile = "irb-record-#{now.strftime("%Y%d%m-%H%M")}.log"
          puts "Recording to #{@_recordfile}..."
        end
        record_line "\n# session start: #{now}\n"
        at_exit do
          stop_recording(false)
        end
      end

      def self.stop_recording(warn = true)
        if @_recordfile
          record_line "\n# session stop: #{Time.now}\n"
          puts "Recording to #{@_recordfile} stopped"
          @_recordfile = nil
        elsif warn
          puts "There is no recording going on."
        end
      end
    end

    def readline_with_recording(*args)
      line = readline_without_recording(*args)
      History.record_line(line)
      line
    end
    alias :readline_without_recording :readline
    alias :readline :readline_with_recording
  end

  def start_recording
    Readline::History.start_recording
  end

  def stop_recording
    Readline::History.stop_recording
  end

  tip "type `start_recording' to record your commands to a file"

end
