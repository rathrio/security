Assignment 8 - HTTP proxy (part 2)
==================================

Rathesan Iyadurai (10-107-688)

You should find the following files in this directory:

- README.txt: this README
- blacklist.txt: sample blacklist file
- proxy: a filtering and caching proxy server


Prerequisites
-------------

- Ruby >= 2.4


Usage
-----

1. Start the proxy server.

       ./proxy blacklist.txt

   The server listens on localhost:8080.

2. Configure your browser to use this proxy server or test with curl, e.g.:

   curl -x localhost:8080 https://www.sbb.ch


