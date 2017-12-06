require 'dnsruby'

class Dane

  # @param mail [Mail::Message] mail
  def apply!(mail)
    inner_resolver = Dnsruby::Resolver.new
    inner_resolver.do_validation = true
    inner_resolver.dnssec = true
    resolver = Dnsruby::Recursor.new(inner_resolver)
    resolver.dnssec = true

    mail.recipients.each do |rec|
    end
  end
end
