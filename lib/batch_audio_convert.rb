################################################################################
# BatchAudioConvert
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require "batch_audio_convert/version"
require "batch_audio_convert/file_utils"
require "batch_audio_convert/audio_utils"


module BatchAudioConvert

  include FileUtils
  include AudioUtils


  # Determine files to process
  def build_file_list
    puts_and_logs 'Finding files...'
    file_list = []
    config[:source].each do |entry|
      if File.directory?(entry)
        populate_list_of_files_from_directory(file_list, entry) 
        next
      end
      if File.file?(entry)
        populate_list_of_files_from_file(file_list, entry) 
        next
      end
      logger.warn "\"#{entry}\" is neither a directory nor a regular file. Ignored..."
    end
    logger.debug(file_list)
    file_list
  end

  # Generate destination directory
  def process_files(file_list)
    puts_and_logs 'Processing files...'
    file_list.each do |file|
      analysis_result = analyze_file file
      self.send analysis_result[:method_name], file, analysis_result[:destination_file]
    end
  end


  # Runs an external command
  def run_command(cmd)
    if config[:simulate]
      puts_and_logs " - Simulate running \"#{cmd}\""
      return
    end
    if config[:debug]
      if config[:verbose]
        puts_and_logs " - Running \"#{cmd}\""
      else
        logger.debug " - Running \"#{cmd}\""
      end
      system cmd
      return
    end
    puts_and_logs " - Running \"#{cmd}\"" if config[:verbose]
    system(cmd + ' > /dev/null 2>&1')

  end

end
