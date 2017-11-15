# Keyword filter that currently just replaces the matched
# keywords with "[redacted]".
class KeywordFilter
  attr_reader :keywords, :replace

  def initialize(keywords = [])
    @keywords = keywords
    @replace = '[redacted]'
  end

  # Redacts the subject and body of the mail.
  #
  # @param mail [Mail::Message] mail to be redacted
  def apply!(mail)
    mail.subject = redact(mail.subject)

    if mail.multipart?
      mail.parts.each do |part|
        part.body = redact(part.body)
      end
    else
      mail.body = redact(mail.body)
    end
  end

  private

  def redact(str)
    str = str.to_s.clone

    keywords.each do |kw|
      str.gsub!(Regexp.new(kw), replace)
    end

    str
  end
end

