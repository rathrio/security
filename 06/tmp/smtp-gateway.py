#!/usr/bin/env python3

import os, sys, smtplib, re, plac, asyncio, pyclamd
from os.path import abspath, isfile
from aiosmtpd.controller import Controller
from aiosmtpd.handlers import Message
import dns.resolver, dns.dnssec, dns.rdatatype, dns.message, dns.name, dns.query

MAIL_SERVER = "security2017.vaucher.org"
OUT_PORT = 10587

IN_PORT = 9876


class Filter:
    def apply(self, message):
        raise NotImplementedError


class AntivirusFilter:
    def __init__(self):
        self.cd = pyclamd.ClamdAgnostic()
        if self.cd.ping():
            print("Connected to ClamAV daemon")
        else:
            sys.exit("Clamd not running")

    def apply(self, message):

        found = False
        parent = None
        delete = []
        # first walk: scan for virus
        for part in message.walk():
            part.get_content_type()
            if 'application' in part.get_content_type():
                # get decoded attachment and scan it
                content = part.get_payload(decode=True)
                scan = self.cd.scan_stream(content)
                if scan:
                    print("Virus found")
                    found = True
                    delete.append(part)

        if found:
            # second walk: remove virus
            for part in message.walk():
                if part.is_multipart():
                    for subpart in part._payload:
                        if subpart in delete:
                            part._payload.remove(subpart)

            subj = message.get("Subject")
            message.replace_header("Subject", "[Virus removed] " + subj)
        # file_content = message.get_payload(1).get_payload(decode=True)
        # scan = self.cd.scan_stream(file_content)
        # if scan:
        #     print("Virus found")
        #     message.

    def scan(self, message):
        if message.is_multipart():
            for subpart in message.get_payload():
                yield from subpart.walk()


class KeywordFilter(Filter):
    def __init__(self, file_name):
        print("file name: " + file_name)
        self.keywords = KeywordFilter.extract_keywords(file_name)
        print(self.keywords)
    
    def extract_keywords(file_name):
        kws = None

        with open(file_name, 'r') as file:
            kws = [f.strip() for f in file]
        return kws
    
    def apply(self, message):
        pl = message.get_payload()
        if message.is_multipart():
            pass
        else:
            for k in self.keywords:
                pl = re.sub(k, "[redacted]", pl)
        message.set_payload(pl)


class MailHandler(Message):
    def __init__(self, gateway):
        super().__init__()
        self.gateway = gateway

    # async def handle_RCPT(self, server, session, envelope, address, rcpt_options):
    #     envelope.rcpt_tos.append(address)
    #     return '250 OK'

    # async def handle_DATA(self, server, session, envelope):
    #     self.gateway.process_mail(envelope.mail_from, envelope.rcpt_tos, envelope.content.decode('utf-8', errors='replace'))
    #     return '250 Message accepted for delivery'

    def handle_message(self, message):
        self.gateway.process_mail(message)
        pass


class Gateway:
    def __init__(self, smtp_server, smtp_port, filters=[]):
        self.filters = filters      # contains all the filters (Keywords and others later on)
        self.message = None           # current mail, changed in place
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port

    def process_mail(self, message):
        print("received mail from %s, proccessing..." % message.get("From"))
        self.message = message

        # apply filters
        #print("Before:")
        #print(self.message.get_payload())
        #for f in self.filters:
        #    f.apply(self.message)
        #print("After:")
        #print(self.message.get_payload())

        ### DNSSEC checks
        # get domain from Recipient
        domain = self.message.get('X-RcptTo').split('@')[1]
        # create resolver, set DO flag
        resolver = dns.resolver.Resolver()
        resolver.use_edns(0, dns.flags.DO, 4096)
        # make query
        print("requesting MX records")
        response = resolver.query(domain, 'MX')
        # take the MX record
        mx_server = str(response.rrset[0].exchange)
        # look for flags in the response
        for line in response.response.to_text().split('\n'):
            if line.startswith('flag') and "AD" in line:
                print('Found AD bit in dns response, DNSSEC record is valid')
                break

        # get TLSA record
        print("requesting TLSA records")
        response = resolver.query('_10587._tcp.' + mx_server, 'TLSA')
        tlsa_cert_text = response.rrset[0].to_text()
        tlsa_cert_bit = response.rrset[0].cert
        tlsa_cert = response.rrset[0].to_text()[6:]

        # look for flags in the response
        for line in response.response.to_text().split('\n'):
            if line.startswith('flag') and "AD" in line:
                print('Found AD bit in dns response, DNSSEC record is valid')
                break

        # connect to SMTP server
        print('bla')
        try:
            # connect to the mail server, initiate TLS connection
            smtp = smtplib.SMTP(mx_server, self.smtp_port)
            smtp.ehlo()
            smtp.starttls()
            # retreive TLS certificate
            cert = smtp.sock.getpeercert(True)

            # TODO: check tlsa fingerprint against smtp server's tls certificate

            self.smtp.send_message(self.message, from_addr=USER, to_addrs=self.message.get("X-RcptTo"))
            print("mail forwarded")
        except smtplib.SMTPAuthenticationError:
            sys.exit("SMTP auth failed")
        except:
            sys.exit("Could not send mail")


@plac.annotations(
    keywords=('file(s) containing keywords to filter', 'option', 'k'),
    antivirus=('scan for viruses', 'flag', 'av'),
    in_port=('port to listen to', 'option', 'p'),
    server=('server address to relay e-mails to', 'option'),
    port=('server port to relay e-mails to', 'option'))
def main(keywords, antivirus, in_port, server, port):
    in_port = in_port if in_port else IN_PORT
    server = server if server else MAIL_SERVER
    port = port if port else OUT_PORT
    
    filters = []
    # add keyword filters if specified
    if keywords:
        keywords = keywords.split(",")
        for k in keywords:
            if not isfile(abspath(k)):
                print("%s: keywords file does not exist" % k)
            else:
                filters.append(KeywordFilter(k))
    # add antivirus filter if specified
    if antivirus:
        filters.append(AntivirusFilter())

    # create a gateway object containing the filters, start the server
    gateway = Gateway(server, port, filters)
    controller = Controller(MailHandler(gateway), hostname='localhost', port=in_port)
    try:
        controller.start()
        while True:
            pass
    finally:
        controller.stop()

if __name__ == '__main__':
    plac.call(main)
