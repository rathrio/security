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
    if mail.multipart?
      apply_multipart(mail)
      return
    end

    result = scan(mail.body.decoded)
    if virus?(result)
      mail.body = ''
      add_notice(mail)
    end
  end

  private

  def apply_multipart(mail)
    virus_detected = false

    mail.attachments.map do |a|
      result = scan(a.decoded)
      next unless virus?(result)
      virus_detected = true
    end

    if virus_detected
      add_notice(mail)
    end
  end

  def virus?(result)
    result.kind_of? ClamAV::VirusResponse
  end

  def add_notice(mail)
    mail.subject = "[Virus removed] #{mail.subject}"
  end

  def scan(str)
    io = StringIO.new(str.to_s.chomp)
    cmd = ClamAV::Commands::InstreamCommand.new(io)
    client.execute(cmd)
  end
end
