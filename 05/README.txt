Assignment 5 - E-mail security (part 2)
=======================================

Rathesan Iyadurai (10-107-688)

You should find the following files in this directory:

- README.txt: this README
- mail: a script that is preconfigured to send emails via the SMTP gateway, in
        case you do not want to configure your email client.
- smtp-gateway: SMTP server that applies filters.
- filter.txt: Example keyword file.
- not_a_virus.txt: File that contains the EICAR test string.
- not_a_virus_for_real.txt: Virus free file.


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

  You can install them all with the RubyGems package manager:

      gem install mail gserver mini-smtp-server mailcatcher clamav-client

  I'm using a socket to communicate with the
  clamd server. You might need to set the
  following ENV var to let the client know
  about the correct socket:

      CLAMD_UNIX_SOCKET='/tmp/clamd.socket'


Usage
-----
