Assignment 3 - LDAP client
==========================

Rathesan Iyadurai (10-107-688)

You should find the following files in this directory:

- README.txt: this README
- ldap: a Ruby CLI that wraps net/ldap to add/delete/modify person objects in
  the organisational unit "students"


Prerequisites
-------------

- Ruby >= 2.4
- Ruby LDAP library. You can install it with Rubygems, e.g.,

      gem install net-ldap

  https://github.com/ruby-ldap/ruby-net-ldap


Usage
-----

Pass --help to list all available flags and switches:

    ./ldap --help

List all objects in the students ou in LDIF format with --list:

    ./ldap --list

Add objects to the students ou by passing a comma separated attributes string.
The order doesn't matter:

    ./ldap --add "cn=spongebob squarepants,sn=squarepants"

Remove objects by passing the dn to --remove:

    ./ldap --remove "cn=spongebob squarepants,ou=students,dc=security,dc=ch"

Modify objects by passing the dn and one or more operations to --modify:

    ./ldap --modify "cn=spongebob squarepants,ou=students,dc=security,dc=ch" "replace,sn,schwammkopf" "add,userpassword,123456"

Operation arguments must conform to the following format:

    "<add|replace|delete>,<attribute_name>,<attribute_value>"

The <attribute_value> can be omitted for delete operations.
