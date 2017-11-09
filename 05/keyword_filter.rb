# Keyword filter that currently just replaces the matched keywords with
# "[redacted]".
class KeywordFilter
  attr_reader :keywords, :replace

  def initialize(keywords = [])
    @keywords = keywords
    @replace = '[redacted]'
  end

  def apply!(mail)
    raise
    mail.subject redact(mail.subject)
    mail.body    redact(mail.body)
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

