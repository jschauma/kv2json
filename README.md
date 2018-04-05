# kv2json -- convert key-value input to json

```
kv2json(1)		NetBSD General Commands Manual		    kv2json(1)

NAME
     kv2json -- convert key-value input to json

SYNOPSIS
     kv2json [-_h] [-c char] [-o name] [-r sep] [-s sep]

DESCRIPTION
     The kv2json tool takes plain text key-value data as input and converts it
     into json.

OPTIONS
     The following options are supported by kv2json:

     -_	      Replace spaces in keys with an underscore (_).

     -c char  Treat 'char' as a comment character or string and ignore any
	      input including and up to the end of the line.  Defaults to '#'.

     -h	      Display help and exit.

     -o name  Specify the object name to use for non-key-value prefixes for
	      multiple records.	 Defaults to "name".

     -r sep   Specify the record separator to differentiate multiple elements.
	      Defaults to an empty line.

     -s sep   Specify the key-value separator.	Defaults to '='.

DETAILS
     Many unix tools and configuration files utilize trivial key-value pairs
     as input; many other tools prefer to use more structured JSON.  The
     kv2json utility can be used to trivially generate JSON from the input by
     converting multiple sequences of key-value separated items into JSON
     objects.

     Multiple records or objects can be identified by separating them via an
     empty line or by using the -r flag.

     Any non-key-value text immediately preceeding a key-value block will be
     interpreted as the name of the object.  See EXAMPLES for an illustration
     of this feature.

     kv2json reads data from STDIN and writes output to STDOUT.	 Whitespace at
     the beginning or end of the line as well as around the key-value separa-
     tor is ignored, as are comments and multiple empty lines.

EXAMPLES
     The following examples illustrate common usage of this tool.

	   cat <<EOF | kv2json
	   > key1 = value1
	   > key2 = value2
	   > EOF
	   [
	      {
		"key1" : "value1",
		"key2" : "value2"
	      }
	   ]

     To parse multiple records with an object identifier ("name"):

	   cat <<EOF | kv2json -s :
	   > item1
	   > key1 : value1
	   > # ignore this line
	   > key2 : value2
	   >
	   > item2
	   > key1 : value1
	   > EOF
	   [
	      {
		 "key1" : "value1",
		 "key2" : "value2",
		 "name" : "item1"
	      },
	      {
		 "key1" : "value1",
		 "name" : "item2"
	      }
	   ]

     Note that duplicate keys will yield an array.  Here, we use "---" as the
     record separator and "id" as the object identifier:

	   cat <<EOF | kv2json -o id -r ---
	   > some sort of identifier
	   > key1 = some value
	   > key1 = some other value
	   > key2 = val1
	   > ---
	   > second object
	   > key1 = some value
	   > key2 = val1
	   > key2 = val2
	   > EOF
	   [
	      {
		 "id" : "some sort of identifier",
		 "key1" : [
		    "some value",
		    "some other value"
		 ],
		 "key2" : "val1"
	      },
	      {
		 "id" : "second object",
		 "key1" : "some value",
		 "key2" : [
		    "val1",
		    "val2"
		 ]
	      }
	   ]

EXIT STATUS
     The kv2json utility exits 0 on success, and >0 if an error occurs.

SEE ALSO
     jq(1)

HISTORY
     kv2json was originally written by Jan Schaumann <jschauma@netmeister.org>
     in March 2018.

BUGS
     Please report bugs and feature requests to the author via email.

NetBSD 7.0			 April 4, 2018			    NetBSD 7.0
```
