## Example-Download
When a file is downloaded via the web, if you inspect the backend
processing, you may find a GET request. This request returned data,
most likely in binary format, and that was the data that was saved to
the location specified during the download request.

This sample uses the [HTTP/HTTPS enabler portion](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.ieac100/ieac1-cwe-http.htm) of the toolkit to issue
a GET request and store the corresponding content in either zFS file
or a sequential data set.

It is intended to showcase how a native z/OS application can easily
download content accessible via a REST API.        

## Prep work
Compile and link `hwtdload.c`

**Encoding consideration**:
  `hwtdload.c` file was uploaded and tested using ISO8859-1 encoding

**Sample compilation in UNIX:**

`xlc -o hwtdload -I//'HWT.H' -qdll -qrent -qlongname -qlist  -Wl,LIST=ALL,MAP,DYNAM=DLL hwtdload.c > hwtdload.listing`

where `-I` points to a location that contains the IBM-supplied C header `hwthic.c`

## Invocation
### Syntax:
`hwtdload -f <from> -t <to> [-c <userId:password>] [-k <keyring> [-s <stashfile>]] [-v]`

### OPTIONS                       

**required**
<br>-f *from*, the URI *from* which the remote content should be downloaded
    i.e.: `https://httpbin.org/bytes/10000`
<br>-t *to*, the location *to* which the downloaded content is to be stored
* **for a zFS file**, specify absolute pathname
* **for a data set**, specify name of a pre-allocated sequential data set, 
                       with the following attributes: `DSORG=PS, RECF=FB, LRECL=1024`
   
   **NOTE:** Should the content being downloaded exceed the zFS or data set capacity, the program will fail with messages indicating how much data was, and was not written.
   

**optional**
<br>-c *credentials*, userid and password required for the URI 
* **syntax:** `userId:password`

<br>-k certificate *keystore*, a SAF *keyring* or a *keyring* created using the SystemSSL gskkyman utility
<br>-s *stashfile*, password stashfile associated with the certificate keystore
<br>-v *verbose*, turn on [**HWTH_OPT_VERBOSE** tracing option](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.ieac100/ieac1-cwe-http-options.htm)


**sample output**
```
hwtdload -k keyring.kdb  -s keyring.sth -f https://example.org/bytes/10000 -t /u/HWT/test/content

Using connect scheme: https
Using host: example.org
Using requestUri: /bytes/10000
Using file (or dataset): /u/HWT/test/content
Using keyring: keyring.kdb
Using stashfile: keyring.sth
File successfully downloaded to /u/HWT/test/content (10000 bytes)
```
