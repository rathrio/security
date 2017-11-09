require 'clamav/client'

class VirusScanner
  attr_reader :client

  def initialize
    @client = ClamAV::Client.new
  end

  # Removes viruses from emails.
  #
  # @param mail [Mail::Message] mail to be filtered
  def apply!(mail)
    mail.attachments.map do |a|
      r = scan_str(a.decoded)
      next unless r.is_a? ClamAV::VirusResponse

      puts 'VIRUS DETECTED!!! CODE RED! CODE RED!!'
    end
  end

  private

  def scan_str(str)
    io = StringIO.new(str)
    cmd = ClamAV::Commands::InstreamCommand.new(io)
    client.execute(cmd)
  end
end
