Assignment 6 - E-mail security (part 3)
=======================================

Rathesan Iyadurai (10-107-688)

You should find the following files in this directory:

- README.txt: this README
- mail: a script that is preconfigured to send emails via the SMTP gateway, in
        case you do not want to configure your email client.
- smtp-gateway: SMTP server that applies filters.
- keyword_filter.rb: filter that redacts keywords.
- virus_scanner.rb: filter that neutralizes evil attachments.
- filter.txt: Example keyword file.


Prerequisites
-------------

- Ruby >= 2.4
- ClamAV antivirus engine (https://www.clamav.net)
- A recent version of the following Ruby libraries:
  - https://rubygems.org/gems/mail: for parsing and sending emails
  - https://rubygems.org/gems/gserver: required for mini-smtp-server to work
  - https://rubygems.org/gems/mini-smtp-server: lightweight smtp server for the
    gateway
  - https://rubygems.org/gems/mailcatcher: local smtp server that comes with a
    web UI
  - https://rubygems.org/gems/clamav-client: for communicated with the ClamAV
    daemon
  - https://rubygems.org/gems/dnsruby

  You can install them all with the RubyGems package manager:

      gem install mail gserver mini-smtp-server mailcatcher clamav-client dnsruby

  I'm using a socket to communicate with the clamd server. You might need to
  set the following ENV var to let the client know about the correct socket:

      CLAMD_UNIX_SOCKET='/tmp/clamd.socket'

NOTE: I gave up, because of configuration issues. Will attempt to get it
working later.
