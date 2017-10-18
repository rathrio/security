Assignment 1 - Files integrity
==============================

Rathesan Iyadurai (10-107-688)

You should find the following files in this directory:

- README.txt: this README
- integ: a Ruby program that can perform the two requested phases.
- integignore.txt: a sample ignore file that can be passed to the --ignore
  flag


Prerequisites
-------------

- a Unix file system
- Ruby >= 2.4


Usage
-----

1. Change to this directory

2. Index a directory

    ./integ --index /path/to/directory

3. Make some modifications in that directory

4. Analyse the modifications

    ./integ /path/to/directory

Step 3 and 4 can be repeated for the same directory.

For more info, run

    ./integ -h

The checksums are stores in a JSON file in this directory. You can view it's
contents with

    cat integ.json

To ignore files/folders, you can pass the --ignore <IGNORE_FILE> flag in both
step 1 and 4, e.g.,

    ./integ --ignore integignore.txt --index /path/to/directory

An ignore-file should contain a list of entries that look like this:

    foobar.txt
    some/path
    app

I don't really differentiate between files and folders in the ignore-file.
foobar.txt could also be a folder.
