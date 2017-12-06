require 'clamav/client'

class VirusScanner
  attr_reader :client

  VIRUS_REMOVED = '[Virus removed]'

  def initialize
    @client = ClamAV::Client.new
  end

  # Removes viruses from emails.
  #
  # @param mail [Mail::Message] mail to be filtered
  def apply!(mail)
    viruses = []

    mail.parts.each do |part|
      next unless attachment?(part)

      result = scan(part.body)

      if virus?(result)
        part.body = ""
        viruses << result
      end
    end

    if viruses.any?
      mail.subject = "#{VIRUS_REMOVED} #{mail.subject}"

      notice = <<~EOS



        -------------------------------------------------------------------------------

        Detected and neutralized the following threats:

        #{viruses.map { |v| "- #{v.virus_name}" }.join("\n\n")}
      EOS

      body_part = mail.parts.first
      body_part.body = "#{body_part.body}\n\n#{notice}"
    end
  end

  private

  def attachment?(part)
    part.content_disposition =~ /attachment/i
  end

  def virus?(result)
    result.kind_of? ClamAV::VirusResponse
  end

  def scan(str)
    io = StringIO.new(str.to_s.chomp)
    cmd = ClamAV::Commands::InstreamCommand.new(io)
    client.execute(cmd)
  end
end
