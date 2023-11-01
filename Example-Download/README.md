## Example-Download
When a file is downloaded via the web, if you inspect the backend
processing, you may find a GET request. This request returned data,
most likely in binary format, and that was the data that was saved to
the location specified during the download request.

This sample uses the [HTTP/HTTPS enabler portion](https://www.ibm.com/docs/en/zos/2.5.0?topic=toolkit-zos-httphttps-protocol-enabler) of the toolkit to issue
a GET request and store the corresponding content in either zFS file
or a sequential data set.

It is intended to showcase how a native z/OS application can easily
download content accessible via a REST API.

This sample supports TLS version 1.3 by default.

## Prep work
Compile and link `hwtdload.c`

**Encoding consideration**:
  `hwtdload.c` file was uploaded and tested using ISO8859-1 encoding

**Sample compilation in UNIX:**

`xlc -o hwtdload -I//'HWT.H' -qdll -qrent -qlongname -qlist  -Wl,LIST=ALL,MAP,DYNAM=DLL hwtdload.c > hwtdload.listing`

where `-I` points to a location that contains the IBM-supplied C header `hwthic.c`

## Invocation
### Syntax:
`hwtdload -f <from> -t <to> [-c <userId:password>] [-k <keyring> [-s <stashfile>]] [-v] [-x]`

### OPTIONS

**required**
<br>-f *from*, the URI *from* which the remote content should be downloaded
    i.e.: `https://codeload.github.com/IBM/IBM-Z-zOS/tar.gz/refs/tags/v1.0.0`
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
<br>-v *verbose*, turn on [**HWTH_OPT_VERBOSE** tracing option](https://www.ibm.com/docs/en/zos/2.5.0?topic=values-options-connections)
<br>-x *translate text*, write to file or dataset as IBM-1047 encoded text rather than binary


**sample output**
```
hwtdload -k keyring.kdb -s keyring.sth -f https://codeload.github.com/IBM/IBM-Z-zOS/tar.gz/refs/tags/v1.0.0 -t /u/user/path/to/content.tar.gz

Using connect scheme: https
Using host: codeload.github.com
Using requestUri: /IBM/IBM-Z-zOS/tar.gz/refs/tags/v1.0.0
Using file (or dataset): /u/user/path/to/content.tar.gz
Using keyring: keyring.kdb
Using stashfile: keyring.sth
[recvexit] 52568037 bytes received
[recvexit] 105135589 bytes received
[recvexit] 157702605 bytes received
[recvexit] 210272132 bytes received
[recvexit] 262839868 bytes received
[recvexit] 315408585 bytes received
[recvexit] 367976588 bytes received
[recvexit] 420543180 bytes received
[recvexit] 473111873 bytes received
File successfully downloaded to /u/user/path/to/content.tar.gz (492236945 bytes)
```
