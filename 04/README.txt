Assignment 4 - E-mail security (part 1)
=======================================

Rathesan Iyadurai (10-107-688)

You should find the following files in this directory:

- README.txt: this README
- mail: a script that is preconfigured to send emails via the SMTP gateway, in
        case you do not want to configure your email client.
- smtp-gateway: SMTP server that redacts and relays messages as requested.
- filter.txt and filter2.txt: Example keyword files.

Prerequisites
-------------

- Ruby >= 2.4
- A recent version of the following Ruby libraries:
  - https://rubygems.org/gems/mail: for parsing and sending emails
  - https://rubygems.org/gems/gserver: required for mini-smtp-server to work
  - https://rubygems.org/gems/mini-smtp-server: lightweight smtp server for the
    gateway
  - https://rubygems.org/gems/mailcatcher: local smtp server that comes with a
    web ui

  You can install them all with the RubyGems package manager:

      gem install mail gserver mini-smtp-server mailcatcher


Usage
-----

1. Start mailcatcher and open the web UI in your browser. This is where the
   gateway will send emails to by default.

       mailcatcher

2. Start the smtp-gateway. You can use the provided keyword files or your own.
   The output will tell you what port it is listening to.

       ./smtp-gateway filter.txt filter2.txt

   Pass the "-h" switch to see available options.

   The gateway will also print all redacted messages that were successfully
   relayed.

   It uses a Regex based approach for keyword filtering. So the keywords in the
   given files are always treated as (Ruby) regular expressions. If you want to
   play around with Ruby regular expressions, I can recommend
   http://rubular.com.

3. Send some emails to the gateway. I recommend using the provided mail script,
   since it sets some handy defaults.

       ./mail

   Run "./mail -h" to see available options.
   
   On a successfull delivery, the mail script will print the message that was
   sent. Consequently, the smtp-gateway should print a redacted message that
   was relayed to mailcatcher. In the web UI of mailcatcher, you should then
   see the redacted message.
