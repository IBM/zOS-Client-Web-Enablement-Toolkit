       IDENTIFICATION DIVISION.
       PROGRAM-ID. HWTHXCB1.
      * START OF SPECIFICATIONS * * * * * * * * * * * * * * * * * * *  *
      *                                                                *
      * Beginning of Copyright and License                             *
      *                                                                *
      * Copyright 2019 IBM Corp.                                       *
      *                                                                *
      * Licensed under the Apache License, Version 2.0 (the "License");*
      * you may not use this file except in compliance with the        *
      * License.                                                       *
      * You may obtain a copy of the License at                        *
      *                                                                *
      * http://www.apache.org/licenses/LICENSE-2.0                     *
      *                                                                *
      * Unless required by applicable law or agreed to in writing,     *
      * software distributed under the License is distributed on an    *
      * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,   *
      * either express or implied.  See the License for the specific   *
      * language governing permissions and limitations under the       *
      * License.                                                       *
      *                                                                *
      * End of Copyright and License                                   *
      *----------------------------------------------------------------*
      *                                                                *
      *  MODULE NAME=HWTHXCB1                                          *
      *                                                                *
      *  DESCRIPTIVE NAME=Sample Cobol code calls to HTTP services     *
      *                                                                *
      *  FUNCTION                                                      *
      *                                                                *
      *  This particular sample shows a sample invocation of a         *
      *  published REST API get Airport information. Using simple      *
      *  programming techniques, the sample connects to the host       *
      *  and then issues a simple HTTP request to get the desired      *
      *  info. To tie it all together, it then invokes the other       *
      *  part of the z/OS Client Web Enablement Toolkit (the z/OS      *
      *  JSON parser) to parse thru the values to quickly report on    *
      *  a couple of values returned that are of interest.             *
      *                                                                *
      *   Test your access to this URL in a browser                    *
      *   (or better yet use CURL in OMVS):                            *
      *      http://www.airport-data.com/api/ap_info.json?iata=LAX     *
      *   It should return something like this:                        *
      *   {"icao":"KLAX","iata":"LAX",                                 *
      *     "name":"Los Angeles International Airport",                *
      *     "location":"Los Angeles, CA",                              *
      *     "country":"United States",                                 *
      *     "country_code":"US",                                       *
      *     "longitude":"-118.408068",                                 *
      *     "latitude":"33.942495",                                    *
      *     "link":"http:\/\/www.airport-data.com\/airport\/LAX\/",    *
      *     "status":200}                                              *
      *                                                                *
      *  This module provides sample calls to these HTTP Enabler       *
      *  services:                                                     *
      *    HWTHINIT - Initialize a connection and request instance.    *
      *    HWTHSET  - Set various connection and request options       *
      *    HWTHCONN - Connect to a web server.                         *
      *    HWTHRQST - Send an HTTP request over an existing            *
      *               connection                                       *
      *    HWTHDISC - Disconnect from a web server.                    *
      *    HWTHTERM - Terminate a connection and request instance.     *
      *                                                                *
      *  OPERATION:                                                    *
      *                                                                *
      *  CODE FLOW in this sample:                                     *
      *    Call HTTP-Init-Connection to create a connection instance.  *
      *    Call HTTP-Setup-Connection to set all the necessary         *
      *      connection options prior to connecting to the web server. *
      *    Call HTTP-Connect to connect to the web server.             *
      *    Call HTTP-Init-Request to create a request instance.        *
      *    Call HTTP-Setup-Request to set necessary request options    *
      *    Call HTTP-Request to send the request over the established  *
      *      connection.                                               *
      *      * Response Header exit (HWTHHDRX) receives control for    *
      *          each response header received from the HTTP server    *
      *      * Response Body exit (HWTHBDYX) receives control with the *
      *          response body received from the HTTP server.          *
      *    Call HTTP-Terminate to terminate the request instance.      *
      *    Call HTTP-Disconnect to disconnect the connection (socket)  *
      *      from the web server.                                      *
      *    Call HTTP-Terminate to terminate the connection instance.   *
      *                                                                *
      *    DEPENDENCIES                                                *
      *                                                                *
      *     1. Include the copy library HWTHICOB.                      *
      *                                                                *
      *    NOTES:                                                      *
      *                                                                *
      * No recovery logic has been supplied in this sample.            *
      *                                                                *
      * JCL Method:                                                    *
      * -----------                                                    *
      *                                                                *
      * Sample JCL to compile, link edit the program.                  *
      *                                                                *
      * //XCBLCLG  JOB NOTIFY=????????,                                *
      * // REGION=0M,MSGLEVEL=1,MSGCLASS=H                             *
      * //*                                                            *
      * //  JCLLIB ORDER=(SYS1.SIGYPROC)                               *
      * //*                                                            *
      * //  Set SRC=HWTHXCB1               < INPUT ... REQUIRED        *
      * //  Set SAMPLIB=SYS1.SAMPLIB       < INPUT ... REQUIRED        *
      * //  Set MACLIB=SYS1.MACLIB         < COPYBOOK ... REQUIRED     *
      * //  Set CSSLIB=SYS1.CSSLIB         < CSSLIB ... REQUIRED       *
      * //  Set LOAD=HWT.SAMPLE.PDSE.LOAD  < OUTPUT ... REQUIRED       *
      * //*                                                            *
      * //CL EXEC PROC=IGYWCL,                                         *
      * //     PARM.COBOL='LIST',                                      *
      * //     PARM.LKED='REUS(RENT)',                                 *
      * //     LNGPRFX='SYS1',                                         *
      * //     LIBPRFX='ZOS220.CEE'                                    *
      * //COBOL.SYSIN  DD DSN=&SAMPLIB(&SRC),DISP=SHR                  *
      * //COBOL.SYSLIB DD DSN=&MACLIB,DISP=SHR                         *
      * //LKED.SYSLMOD DD DSN=&LOAD(&SRC),DISP=SHR                     *
      * //LKED.SYSLIB  DD DSN=&CSSLIB,DISP=SHR                         *
      * //             DD DSN=&LIBPRFX..SCEELKED,DISP=SHR              *
      * //             DD DSN=&LIBPRFX..SCEELKEX,DISP=SHR              *
      * //GO EXEC PGM=&SRC,PARM='AIRPORT_NAME/POSIX(ON)'               *
      * //STEPLIB  DD  DSN=&LOAD,DISP=SHR                              *
      * //SYSPRINT DD  SYSOUT=*                                        *
      * //*                                                            *
      * //*  where AIRPORT_NAME is the IATA 3 character airport code   *
      * //*  (e.g. LAX)                                                *
      * //*                                                            *
      * -------------------------------------------------------------- *
      *    REFERENCE:                                                  *
      *      See the z/OS MVS Programming: Callable Services for       *
      *      High-Level Languages publication for more information     *
      *      regarding the usage of HTTP Enabler APIs.                 *
      *                                                                *
      * Change Activity:                                               *
      * $L0 ------ z/OS Client Web Enablement                          *
      *     Tookit sample (HTTP) in Cobol programming language         *
      *                                                                *
      * END OF SPECIFICATIONS * * * * * * * * * * * * * * * * * * * * *
       DATA DIVISION.

       WORKING-STORAGE SECTION.

      * Global vars required for majority of HTTP services
       01 Conn-Handle   Pic X(12) Value Zeros.
       01 Rqst-Handle   Pic X(12) Value Zeros.
       01 Diag-Area     Pic X(136) Value Zeros.

      * Slist is used to pass custom HTTP headers on request
       01 Slist-Handle  Pic 9(9) Binary Value 0.

      * Dummy vars used by HWTHSET service
       01 option-val-char    Pic X(999) Value Spaces.
       01 option-val-numeric Pic 9(9) Binary Value 0.
       01 option-val-addr    Pointer Value Null.
       01 option-val-len     Pic 9(9) Binary Value 0.

      * Function pointers used to setup response exit routines
       01 header-cb-ptr Function-Pointer Value Null.
       01 rspbdy-cb-ptr Function-Pointer Value Null.

      * Data passed to the response header exit routine
       01 hdr-udata.
         05 hdr-udata-eye   Pic X(8) Value 'HDRUDATA'.
         05 hdr-rspcode-ptr Pointer Value Null.
         05 hdr-count-ptr   Pointer value Null.
         05 hdr-flags-ptr   Pointer Value Null.

      * Response status code returned from the server
      * This gets passed to the response header exit
      * through the header user data structure
       01 http-resp-code Pic 9(9) Binary Value 0.

      * Count of HTTP headers processed by our exit
       01 http-hdr-count Pic 9(9) Binary Value 0.

      * Data passed to the response body exit routine
       01 body-udata.
         05 body-udata-eye     Pic X(8) Value 'BDYUDATA'.
         05 hdr-flags-ptr      Pointer Value Null.
         05 resp-body-data-ptr Pointer Value Null.

      * Flag shared between response body and response header exits
      * Used by the response header exit to indicate that the response
      * body is JSON.
       01 hdr-flags.
         05 json-response-flag    Pic 9.
           88 json-response-true  Value 1.
           88 json-response-false Value 0.

       01 request-status-flag Pic 9.
         88 request-successful   Value 1.
         88 request-unsuccessful Value 0.

      * Structure for storing data returned from FAA website
      * Filled out by the response body exit
       01 resp-body-data.
         05 resp-body-data-eye Pic X(8) Value 'AIRPORT'.
         05 airport-info.
           10 airport-name          Pic X(50).
           10 airport-iata          Pic X(6).
           10 airport-state         Pic X(30).
           10 airport-country       Pic X(50).
           10 airport-lat           Pic X(30).
           10 airport-long          Pic x(30).
           10 airport-status-type   Pic X(30).
           10 airport-status-reason Pic X(30).
           10 airport-average-delay Pic X(30).
           10 airport-weather-cond  Pic X(30).
           10 airport-temp          Pic X(30).
           10 airport-wind          Pic X(30).
           10 airport-delay-flag    Pic 9.
             88 airport-delay-true  Value 1.
             88 airport-delay-false Value 0.

      *
         COPY HWTHICOB.
      *
       LINKAGE SECTION.

      * User-supplied parameter: expecting a 3-char IATA airport code
       01 jcl-parm.
         05 parm-len    Pic S9(3) binary.
         05 parm-string.
           10 parm-char Pic X occurs 0 to 100 times
                      depending on parm-len.

       PROCEDURE DIVISION using jcl-parm.
       Begin.

           Display "***********************************************".
           Display "** HTTP Web Enablement Toolkit Sample Begins **".

           If parm-len not equal 3 then
             Display "** Bogus IATA airport code specified!        **"
             Display "** Terminating Sample                        **"
             Display "***********************************************"
             Stop Run
           End-if

           *> Initialize and set up a connection handle
           Perform HTTP-Init-Connection

           If (HWTH-OK)

             *> Set the required options before connecting to the server
             Perform HTTP-Setup-Connection

             If (HWTH-OK)

               *> Connect to the HTTP server
               Perform HTTP-Connect

               If (HWTH-OK)

                 *> Initialize and set up a request
                 Perform HTTP-Init-Request

                 If (HWTH-OK)

                   *> Set the necessary options before connecting
                   *> to the server.
                   Perform HTTP-Setup-Request

                   If (HWTH-OK)

                     *> Send the request
                     Perform HTTP-Issue-Request

                     If (HWTH-OK)

                       *> If the response code was ok, write the data
                       If http-resp-code equal 200 then
                         Perform Display-Airport-Data
                         Set request-successful to true
                       End-If
                     End-If
                   End-If

                   *> Terminate the request
                   Perform HTTP-Terminate-Request
                 End-If

                 *> Disconnect the connection
                 Perform HTTP-Disconnect
               End-If
             End-If

             *> Terminate the connection
             Perform HTTP-Terminate-Connection
           End-If

           *> If the last service was successful and the request
           *> completed successfully, then put successful message
           If HWTH-OK AND request-successful then
             Display "** Program Ended Successfully                **"
           else
             Display "** Program Ended Unsuccessfully              **"
           End-if

           Display "** HTTP Web Enablement Toolkit Sample Ends   **".
           Display "***********************************************".
           STOP RUN.

      ****************************************************************
      *                                                              *
      * Function: HTTP-Init-Connection                               *
      *   Initializes a connection handle using the HWTHINIT service *
      *                                                              *
      ****************************************************************
       HTTP-Init-Connection.

           Set HWTH-HANDLETYPE-CONNECTION to true.

           Call "HWTHINIT" using
             HWTH-RETURN-CODE
             HWTH-HANDLETYPE
             Conn-Handle
             HWTH-DIAG-AREA

           If (HWTH-OK)
             Display "** Initialize succeeded (HWTHINIT)"
           else
             Display "HWTHINIT FAILED: "
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

      ****************************************************************
      *                                                              *
      * Function: HTTP-Init-Request                                  *
      *   Initializes a request handle using the HWTHINIT service    *
      *                                                              *
      ****************************************************************
       HTTP-Init-Request.

           Set HWTH-HANDLETYPE-HTTPREQUEST to true.

           Call "HWTHINIT" using
             HWTH-RETURN-CODE
             HWTH-HANDLETYPE
             Rqst-Handle
             HWTH-DIAG-AREA

           If (HWTH-OK)
             Display "** Initialize succeeded (HWTHINIT)"
           else
             Display "HWTHINIT FAILED: "
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Function: HTTP-Setup-Connection                                *
      *           Sets the necessary connection options                *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       HTTP-Setup-Connection.

           *>  ______________________________________________________
           *> |                                                      |
           *> | First, set the verbose option on. This option is     |
           *> | handy when developing an application. Lots of        |
           *> | informational error messages are written to          |
           *> | standard output to help in debugging efforts.        |
           *> | This option should likely be turned off with         |
           *> | HWTH_VERBOSE_OFF or just not set at all (default is  |
           *> | off) when the application goes into production.      |
           *> |______________________________________________________|
           Set HWTH-OPT-VERBOSE to true.
           Set HWTH-VERBOSE-ON to true.
           Set option-val-addr to address of HWTH-VERBOSE.
           Compute option-val-len = function length (HWTH-VERBOSE).

           Display "** Set HWTH-OPT-VERBOSE for connection".
           Call "HWTHSET" using
                          HWTH-RETURN-CODE
                          Conn-Handle
                          HWTH-Set-OPTION
                          option-val-addr
                          option-val-len
                          HWTH-DIAG-AREA.

           If HWTH-OK

             *>  ______________________________________________________
             *> |                                                      |
             *> | Set URI for connection handle.                       |
             *> |______________________________________________________|
             Set HWTH-OPT-URI to true

             Move "http://www.airport-data.com" to  option-val-char
             Move 27 to option-val-len
           *> Alternate test: Use local server
           *> Move "http://10.0.0.117" to  option-val-char
           *> Move 17 to option-val-len

             Set option-val-addr to address of option-val-char

             Display "** Set HWTH-OPT-URI for connection"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            Conn-Handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If

           If HWTH-OK
             *>  ______________________________________________________
             *> |                                                      |
             *> | Set Port for connection handle.                      |
             *> |   Port 80 is the default, but code is included       |
             *> |   to illustrate how to set a port if necessary       |
             *> |______________________________________________________|
             Set HWTH-OPT-PORT to true
             Set option-val-addr to address of option-val-numeric
             Compute option-val-len =
                 function length (option-val-numeric)
             move 80 to option-val-numeric
             Display "** Set HWTH-OPT-PORT for connection"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            Conn-Handle
                            HWTH-SET-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If

           If HWTH-OK

             *>  ______________________________________________________
             *> |                                                      |
             *> | Set HWTH_OPT_COOKIETYPE                              |
             *> |   Enable the cookie engine for this connection.  Any |
             *> |   "eligible" stored cookies will be resent to the    |
             *> |   host on subsequent interactions automatically.     |
             *> |   interactions automatically.                        |
             *> |______________________________________________________|
             Set HWTH-OPT-COOKIETYPE to true
             Set HWTH-COOKIETYPE-SESSION to true
             Set option-val-addr to address of HWTH-COOKIETYPE
             Compute option-val-len =
                 function length (HWTH-COOKIETYPE)

             Display "** Set HWTH-OPT-COOKIETYPE for connection"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            Conn-Handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           else
             Display "HWTHSET FAILED: "
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

      ****************************************************************
      *                                                              *
      * Function: HTTP-Connect                                       *
      *   Issues the hwthconn service and performs error checking    *
      *                                                              *
      ****************************************************************
       HTTP-Connect.

           Call "HWTHCONN" using
             HWTH-RETURN-CODE
             Conn-Handle
             HWTH-DIAG-AREA

           If (HWTH-OK)
             Display "** Connect succeeded (HWTHCONN)"
           else
             Display "Connect failed (HWTHCONN)."
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

      ****************************************************************
      *                                                              *
      * Function: HTTP-Issue-Request                                 *
      *   Issues the hwthrqst service and performs error checking    *
      *                                                              *
      ****************************************************************
       HTTP-Issue-Request.

           Call "HWTHRQST" using
             HWTH-RETURN-CODE
             Conn-Handle
             Rqst-Handle
             HWTH-DIAG-AREA

           If (HWTH-OK)
             Display "** Request succeeded (HWTHRQST)"
           else
             Display "Request failed (HWTHRQST)."
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Function: HTTP-Setup-Request                                   *
      *           Sets the necessary request options                   *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       HTTP-Setup-Request.

           *>  ______________________________________________________
           *> |                                                      |
           *> | Set HTTP Request method.                             |
           *> |   A GET request method is used to get data from      |
           *> |   the server.                                        |
           *> |______________________________________________________|
           Set HWTH-OPT-REQUESTMETHOD to true.
           Set HWTH-HTTP-REQUEST-GET to true.
           Set option-val-addr to address of HWTH-REQUESTMETHOD.
           Compute option-val-len =
               function length (HWTH-REQUESTMETHOD).

           Display "** Set HWTH-REQUESTMETHOD for request"
           Call "HWTHSET" using
                          HWTH-RETURN-CODE
                          rqst-handle
                          HWTH-Set-OPTION
                          option-val-addr
                          option-val-len
                          HWTH-DIAG-AREA

           If HWTH-OK

             *>  ______________________________________________________
             *> |                                                      |
             *> | Set the request URI                                  |
             *> |   Set the URI that identifies a resource by name     |
             *> |   that is the target of our request.                 |
             *> |______________________________________________________|
             Set HWTH-OPT-URI to true
             Move 1 to option-val-len
             STRING "/api/ap_info.json?iata="
                    DELIMITED BY SIZE
                    parm-string(1:parm-len) DELIMITED BY SIZE
                    INTO
                    option-val-char WITH POINTER option-val-len

          *> Alternate test: Use local server
          *> STRING "/index.htm"
          *>        DELIMITED BY SIZE
          *>        parm-string(1:parm-len) DELIMITED BY SIZE
          *>        INTO
          *>        option-val-char WITH POINTER option-val-len

             Set option-val-addr to address of option-val-char
             SUBTRACT 1 FROM option-val-len

             Display "** Set HWTH-OPT-URI for request"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            rqst-handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If

           If HWTH-OK

             *> Create a list of HTTP headers
             Perform Build-Slist

             *> Specify the HTTP request headers
             Set HWTH-OPT-HTTPHEADERS to true
             Set option-val-addr to address of Slist-Handle
             Compute option-val-len = function length(Slist-Handle)

             Display "** Set HWTH-OPT-HTTPHEADERS for request"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            rqst-handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If

           If HWTH-OK

             *> Direct the toolkit to convert the response body
             *> from ASCII to EBCDIC
             Set HWTH-OPT-TRANSLATE-RESPBODY to true
             Set HWTH-XLATE-RESPBODY-A2E to true
             Set option-val-addr to address of HWTH-XLATE-RESPBODY
             Compute option-val-len =
                 function length (HWTH-XLATE-RESPBODY)

             Display "** Set HWTH-OPT-TRANSLATE-RESPBODY for request"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            rqst-handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If

           If HWTH-OK

             *>  ______________________________________________________
             *> |                                                      |
             *> | Set the response header callback routine             |
             *> |   Set the address of the routine that is to receive  |
             *> |   control once for every response header that we     |
             *> |   receive                                            |
             *> |______________________________________________________|
             Set HWTH-OPT-RESPONSEHDR-EXIT to true
             Set header-cb-ptr to ENTRY "HWTHHDRX"
             Set option-val-addr to address of header-cb-ptr
             Compute option-val-len =
                 function length (header-cb-ptr)

             Display "** Set HWTH-OPT-RESPONSEHDR-EXIT for request"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            rqst-handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If

           If HWTH-OK

             *> Initialize the header user data pointers to allow
             *> the response header exit to communicate the HTTP status
             *> code and hdr-flags to the main program
             Set hdr-rspcode-ptr to address of http-resp-code
             Set hdr-count-ptr to address of http-hdr-count
             Set hdr-flags-ptr of hdr-udata to address of hdr-flags

             *>  ______________________________________________________
             *> |                                                      |
             *> | Set the response header callback routine user data   |
             *> |   Example to show how data can be passed to the      |
             *> |   response header callback routine to allow the      |
             *> |   routine to customize its processing.               |
             *> |______________________________________________________|
             Set HWTH-OPT-RESPONSEHDR-USERDATA to true
             Set option-val-addr to address of hdr-udata
             Compute option-val-len = function length(hdr-udata)

             Display "** Set HWTH-OPT-RESPONSEHDR-USERDATA for request"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            rqst-handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If

           If HWTH-OK

             *>  ______________________________________________________
             *> |                                                      |
             *> | Set the response body callback routine               |
             *> |   Set the address of the routine that is to receive  |
             *> |   control if there is a response body returned by    |
             *> |   the server                                         |
             *> |______________________________________________________|
             Set HWTH-OPT-RESPONSEBODY-EXIT to true
             Set rspbdy-cb-ptr to ENTRY "HWTHBDYX"
             Set option-val-addr to address of rspbdy-cb-ptr
             Compute option-val-len =
                 function length (rspbdy-cb-ptr)

             Display "** Set HWTH-OPT-RESPONSEBODY-EXIT for request"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            rqst-handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If

           If HWTH-OK

             *>  ______________________________________________________
             *> |                                                      |
             *> | Set the response body callback routine user data     |
             *> |   Example to show how data can be passed to the      |
             *> |   response body callback routine to allow the routine|
             *> |   to customize its processing.                       |
             *> |______________________________________________________|
             Set hdr-flags-ptr of body-udata to address of hdr-flags
             Set resp-body-data-ptr to address of resp-body-data

             Set HWTH-OPT-RESPONSEBODY-USERDATA to true
             Set option-val-addr to address of body-udata
             Compute option-val-len = function length(body-udata)

             Display "** Set HWTH-OPT-RESPONSEBODY-USERDATA for request"
             Call "HWTHSET" using
                            HWTH-RETURN-CODE
                            rqst-handle
                            HWTH-Set-OPTION
                            option-val-addr
                            option-val-len
                            HWTH-DIAG-AREA
           End-If
           .

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Function: Build-Slist                                          *
      *           Sets the necessary request options                   *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       Build-Slist.



           *>  ______________________________________________________
           *> |                                                      |
           *> | Add the Accept request header                        |
           *> |   Create a brand new SLST and specify the first      |
           *> |   header to be an "ACCEPT" header that requests that |
           *> |   the server return the data requested by the GET    |
           *> |   request to be in JSON format.                      |
           *> |______________________________________________________|
           Move 1 to option-val-len.
           String "Accept: application/json" delimited by size
                  into option-val-char with pointer
                  option-val-len.
           Subtract 1 from option-val-len.

           Set option-val-addr to address of option-val-char.
           Set HWTH-SLST-NEW to true.

           Call "HWTHSLST" using
                           HWTH-RETURN-CODE
                           rqst-handle
                           HWTH-SLST-function
                           Slist-Handle
                           option-val-addr
                           option-val-len
                           HWTH-DIAG-AREA.
           If HWTH-OK

           *>  ______________________________________________________
           *> |                                                      |
           *> | Add the Accept-Language request header               |
           *> |   Append to the just-created SLST and specify an     |
           *> |   additional option "Accept-Language" to infer to    |
           *> |   the server the regional settings preferred by this |
           *> |   application.                                       |
           *> |______________________________________________________|
             Move 1 to option-val-len
             String "Accept-Language: en-US" delimited by size
                    into option-val-char with pointer
                    option-val-len
             Subtract 1 from option-val-len

             Set option-val-addr to address of option-val-char
             Set HWTH-SLST-APPEND to true

             Display "** Adding SLIST APPEND"
             Call "HWTHSLST" using
                             HWTH-RETURN-CODE
                             rqst-handle
                             HWTH-SLST-function
                             Slist-Handle
                             option-val-addr
                             option-val-len
                             HWTH-DIAG-AREA
           else
             Display "Slist service failed (HWTHSLST)."
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

      ****************************************************************
      *                                                              *
      * Display-Airport-Data                                         *
      *                                                              *
      *   Function:  Write the airport data                          *
      *    For simplicity, this sample outputs the data to standard  *
      *    out. In a real world application, this data could be      *
      *    displayed real-time in an application, written to storage *
      *    media or displayed in some log or other media.            *
      *                                                              *
      ****************************************************************
       Display-Airport-Data.

           Display "***********************************".
           Display "Airport data for " airport-iata.
           Display "***********************************".

           Display "Airport name: " airport-name.
           Display "Airport state: " airport-state.
           Display "Airport country: " airport-country.
           Display "Airport longitude: " airport-long.
           Display "Airport latitude: " airport-lat.
           Display "-----------------------------------".


      ****************************************************************
      *                                                              *
      * Function: HTTP-Disconnect                                    *
      *   Issues the hwthdisc service and performs error checking    *
      *                                                              *
      ****************************************************************
       HTTP-Disconnect.

           Call "HWTHDISC" using
             HWTH-RETURN-CODE
             Conn-Handle
             HWTH-DIAG-AREA

           If (HWTH-OK)
             Display "** Disconnect succeeded (HWTHDISC)"
           else
             Display "Disconnect failed (HWTHDISC)."
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

      ****************************************************************
      *                                                              *
      * Function: HTTP-Terminate-Connection                          *
      *   Issues the hwthterm service and performs error checking    *
      *                                                              *
      ****************************************************************
       HTTP-Terminate-Connection.

           Set HWTH-NOFORCE to true.

           Call "HWTHTERM" using
             HWTH-RETURN-CODE
             Conn-Handle
             HWTH-FORCETYPE
             HWTH-DIAG-AREA.

           If (HWTH-OK)
             Display "** Terminate succeeded (HWTHTERM)"
           else
             Display "Terminate failed (HWTHTERM)."
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

      ****************************************************************
      *                                                              *
      * Function: HTTP-Terminate-Request                             *
      *   Issues the hwthterm service and performs error checking    *
      *                                                              *
      ****************************************************************
       HTTP-Terminate-Request.

           Set HWTH-NOFORCE to true.

           Call "HWTHTERM" using
             HWTH-RETURN-CODE
             Rqst-Handle
             HWTH-FORCETYPE
             HWTH-DIAG-AREA.

           If (HWTH-OK)
             Display "** Terminate succeeded (HWTHTERM)"
           else
             Display "Terminate failed (HWTHTERM)."
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .


      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Function: Set-Http-Option                                      *
      *           Sets the specified HTTP option                       *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       IDENTIFICATION DIVISION.
       PROGRAM-ID Set-Http-Option COMMON.
       DATA DIVISION.

       LINKAGE SECTION.
       01 handle                      Pic X(12).
       01 option                      Pic 9(9) Binary.
       01 option-val-addr             USAGE POINTER.
       01 option-val-len              Pic 9(9) Binary.

       PROCEDURE DIVISION using handle,
                                option,
                                option-val-addr,
                                option-val-len.
        Begin.

           Call "HWTHSET" using
                        HWTH-RETURN-CODE
                        handle
                        option
                        option-val-addr
                        option-val-len
                        HWTH-DIAG-AREA.

           If (HWTH-OK)
             Display "** Set succeeded (HWTHSET)"
           else
             Display "Set failed (HWTHSET)."
             Call "DSPHDIAG" using
                             HWTH-RETURN-CODE
                             HWTH-DIAG-AREA
           End-If
           .

       End Program Set-Http-Option.

       End Program HWTHXCB1.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Function: HWTHHDRX                                             *
      *           Sample Response Header Callback Routine (Exit)       *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       IDENTIFICATION DIVISION.
       PROGRAM-ID HWTHHDRX.
       DATA DIVISION.

       WORKING-STORAGE SECTION.
       01 Content-Type Pic X(12) Value "CONTENT-TYPE".
       01 Json-Content Pic X(16) Value "APPLICATION/JSON".
       01 Max-Display-Size Pic 9(9) Binary Value 30.
       01 rsp-status-code  Pic 9(9) Binary Value 0.

       LOCAL-STORAGE SECTION.
       01 name-max-len     Pic 9(9) Binary Value 0.
       01 value-max-len    Pic 9(9) Binary Value 0.
       01 name-ucase       Pic X(999) Value Spaces.
       01 value-ucase      Pic X(999) Value Spaces.
       01 Content-Type-Len Pic 9(9) Binary Value 0.
       01 Json-Content-Len Pic 9(9) Binary Value 0.

       01  HWTH-RESP-EXIT-FLAGS Global Pic 9(9) Binary.
           88  HWTH-EXITFLAG-COOKIESTORE-FULL Value 1.

       01  HWTH-RESP-EXIT-RC             GLOBAL PIC 9(9) BINARY.
           88  HWTH-RESP-EXIT-RC-OK             VALUE 0.
           88  HWTH-RESP-EXIT-RC-ABORT          VALUE 1.

       LINKAGE SECTION.
       01 http-resp-line  Pic X(20).
       01 exit-flags      Pic 9(9) Binary.
       01 hdr-name-ptr    Usage Pointer.
       01 hdr-name-len    Pic 9(9) Binary.
       01 hdr-value-ptr   Usage Pointer.
       01 hdr-value-len   Pic 9(9) Binary.
       01 hdr-udata-ptr   Usage Pointer.
       01 hdr-udata-len   Pic 9(9) Binary.

       01 hdr-name-dsect  Pic X(999).
       01 hdr-value-dsect Pic X(999).
       01 reason-dsect    Pic X(128).

       01 hdr-udata.
         05 hdr-udata-eye   Pic X(8).
         05 hdr-rspcode-ptr Pointer.
         05 hdr-count-ptr   Pointer.
         05 hdr-flags-ptr   Pointer.

       01 http-resp-code Pic 9(9) Binary.
       01 http-hdr-count Pic 9(9) Binary.

       01 hdr-flags.
         05 json-response-flag    Pic 9.
           88 json-response-true  Value 1.
           88 json-response-false Value 0.

       01  HWTH-RESP-STATUS-MAP.
           05  HWTH-STATUS-CODE       Pic 9(9) Binary.
           05  HWTH-STATUS-VERS-PTR   Pointer.
           05  HWTH-STATUS-VERS-LEN   Pic 9(9) Binary.
           05  HWTH-STATUS-REASON-PTR Pointer.
           05  HWTH-STATUS-REASON-LEN Pic 9(9) Binary.

       PROCEDURE DIVISION using http-resp-line,
                                exit-flags
                                hdr-name-ptr,
                                hdr-name-len,
                                hdr-value-ptr,
                                hdr-value-len,
                                hdr-udata-ptr,
                                hdr-udata-len.
       Begin.

           Display "*******************************************".
           Display "** Response Header Exit Receives Control **".

           *> Make sure hdr-udata was specified
           If hdr-udata-ptr = Null then

             Display "No header user data was specified!"

             *> Direct the toolkit to halt further header processing
             Set HWTH-RESP-EXIT-RC-ABORT to true
             Compute Return-Code = HWTH-RESP-EXIT-RC

             EXIT PROGRAM
           End-If

           *> Establish addressability to the userdata structure
           Set address of hdr-udata to hdr-udata-ptr.
           Set address of hdr-flags to hdr-flags-ptr.
           Set address of http-resp-code to hdr-rspcode-ptr.
           Set address of http-hdr-count to hdr-count-ptr.

           *>  ______________________________________________________
           *> |                                                      |
           *> | Establish addressability to the HTTP response line   |
           *> | The response status line contains the HTTP version,  |
           *> | status code, and reason phrase (e.g. HTTP/1.1 200 OK)|
           *> |______________________________________________________|
           Set address of HWTH-RESP-STATUS-MAP to
                 address of http-resp-line.

           *> Write status code and reason phrase the first time the
           *> header exit receives control
           If http-resp-code = ZERO then

             Set address of reason-dsect to HWTH-STATUS-REASON-PTR

             Display "** HTTP Status Code: " HWTH-STATUS-CODE
             Display "** HTTP Reason Phrase: "
                       reason-dsect(1:HWTH-STATUS-REASON-LEN)

             Move HWTH-STATUS-CODE to http-resp-code
           End-If

           *> Increment the header count
           Compute http-hdr-count = http-hdr-count + 1.

           If http-resp-code NOT EQUAL 200 then

             *> Direct the toolkit to halt further header processing
             Set HWTH-RESP-EXIT-RC-ABORT to true
             Compute Return-Code = HWTH-RESP-EXIT-RC

             EXIT PROGRAM
           End-If


           *> Check the exit flags for the cookie store full condition
           If exit-flags NOT EQUAL 0 then
             Move exit-flags to HWTH-RESP-EXIT-FLAGS
             If HWTH-EXITFLAG-COOKIESTORE-FULL then
               Display "Cookie Store Full!"
             else
               Display "Other exit flag found."
             End-If
           End-If

           *> Truncate the header name for display purposes
           Set address of hdr-name-dsect to hdr-name-ptr.
           Compute name-max-len =
             function Min(MAX-DISPLAY-SIZE, hdr-name-len).

           *> Truncate the header value for display purposes
           Set address of hdr-value-dsect to hdr-value-ptr.
           Compute value-max-len =
             function Min(MAX-DISPLAY-SIZE, hdr-value-len).

           *> Display the header name and value
           Display "  Response Header " http-hdr-count.
           Display "    Name: " hdr-name-dsect(1:name-max-len).
           Display "    Value: " hdr-value-dsect(1:value-max-len).

           *>  ________________________________________________________
           *> |                                                        |
           *> | Did we receive the header for the content type and     |
           *> | is the value application/json?                         |
           *> |________________________________________________________|

           *> Fold everything to uppercase for comparison
           String function Upper-Case(hdr-name-dsect(1:name-max-len))
               delimited by size into name-ucase.

           String function Upper-Case(hdr-value-dsect(1:value-max-len))
               delimited by size into value-ucase.

           *> Compare only the required number of bytes
           Compute Content-Type-Len = function length(Content-Type).
           Compute Json-Content-Len = function length(Json-Content).

           If name-ucase(1:Content-Type-Len) = Content-Type then
             If value-ucase(1:Json-Content-Len) = Json-Content then
               Set json-response-true to true
             End-If
           End-If

           Display "** Response Header Exit Returns          **".
           Display "*******************************************".

       End Program HWTHHDRX.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * function: HWTHBDYX                                             *
      *           Callback routine used to process the response body   *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       IDENTIFICATION DIVISION.
       PROGRAM-ID HWTHBDYX.
       DATA DIVISION.

       WORKING-STORAGE SECTION.
       01 Name-Key      Pic X(4) Value 'name'.
       01 Iata-Key      Pic X(4) Value 'iata'.
       01 State-Key     Pic X(8) Value 'location'.
       01 Country-Key   Pic X(7) Value 'country'.
       01 Long-Key      Pic X(9) Value 'longitude'.
       01 Lat-Key       Pic x(8) Value 'latitude'.
       01 Delay-Key     Pic X(5) Value 'delay'.
       01 Type-Key      Pic X(4) Value 'type'.
       01 Reason-Key    Pic X(6) Value 'reason'.
       01 Avg-Delay-Key Pic X(8) Value 'avgDelay'.
       01 Weather-Key   Pic X(7) Value 'weather'.
       01 Temp-Key      Pic X(4) Value 'temp'.
       01 Wind-Key      Pic X(4) Value 'wind'.

         COPY HWTJICOB.

       LOCAL-STORAGE SECTION.

       01 root-object          Pic 9(9) Binary Value 0.
       01 status-object        Pic 9(9) Binary Value 0.
       01 weather-object       Pic 9(9) Binary Value 0.

       01 search-string     Pic X(10) Value Spaces.
       01 search-string-len Pic 9(9) Binary Value 0.
       01 search-string-ptr Pointer Value Null.
       01 search-result-ptr Pointer Value Null.
       01 search-result-len Pic 9(9) Binary Value 0.
       01 data-copy-len     Pic 9(9) Binary Value 0.
       01 workarea-max      Pic 9(9) Binary Value 0.

       LINKAGE SECTION.
       01 http-response  Pic X(20).
       01 exit-flags     Pic X(4).
       01 resp-body-ptr  Pointer.
       01 resp-body-len  Pic 9(9) Binary.
       01 body-udata-ptr Pointer.
       01 body-udata-len Pic 9(9) Binary.

       01 body-udata.
         05 resp-body-eye        Pic X(8).
         05 hdr-flags-ptr        Pointer.
         05 resp-body-data-ptr   Pointer.

       01 hdr-flags.
         05 json-response-flag    Pic 9.
           88 json-response-true  Value 1.
           88 json-response-false Value 0.

       01 resp-body-data.
         05 resp-body-data-eye Pic X(8).
         05 airport-info.
           10 airport-name          Pic X(50).
           10 airport-iata          Pic X(6).
           10 airport-state         Pic X(30).
           10 airport-country       Pic X(50).
           10 airport-lat           Pic X(30).
           10 airport-long          Pic x(30).
           10 airport-status-type   Pic X(30).
           10 airport-status-reason Pic X(30).
           10 airport-average-delay Pic X(30).
           10 airport-weather-cond  Pic X(30).
           10 airport-temp          Pic X(30).
           10 airport-wind          Pic X(30).
           10 airport-delay-flag    Pic 9.
             88 airport-delay-true  Value 1.
             88 airport-delay-false Value 0.

       01 string-dsect Pic X(256).

       PROCEDURE DIVISION using http-response,
                                exit-flags,
                                resp-body-ptr,
                                resp-body-len,
                                body-udata-ptr,
                                body-udata-len.
       Begin.

           Display "*******************************************".
           Display "** Response Body Exit Receives Control   **".

           *> Make sure body user data was specified
           If body-udata-ptr = Null then
             Display "** No body user data was specified"
             EXIT PROGRAM
           End-If

           *> Get addressability to body user data
           Set address of body-udata to body-udata-ptr.

           *> Get addressability to the response header flags
           Set address of hdr-flags to hdr-flags-ptr.

           *> Did the response come back in JSON format?
           If json-response-true then
             Display "**  Response body is in JSON format"
             Display "**  Initializing JSON parser"
             Perform init-jparser
           else
             Display "**    Response body in control without ever "
             Display "      receiving indicator of JSON data!     "
           *> EXIT PROGRAM - removed by SMB
             Set address of resp-body-data to resp-body-data-ptr
             Display resp-body-data
             Perform init-jparser
           End-If

           *> Parse the response body as JSON
           If HWTJ-OK then
             Perform parse-json-body
           End-If

           If HWTJ-OK
             Perform retrieve-airport-data
           End-If

           *> Terminate the parser instance
           Perform free-jparser.

           *> Write "body exit exited" message
           Display "** Response Body Exit Returns            **".
           Display "*******************************************".

           EXIT PROGRAM.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      * Method: init-jparser                                          *
      *                                                               *
      * Initializes the parser handle variable.                       *
      *                                                               *
      * Services Used:                                                *
      *                                                               *
      * HWTJINIT: Provides a handle to a parse instance which is then *
      *           used iN subsequent service calls. The HWTJINIT      *
      *           service must be invoked before invoking any other   *
      *           parsing service.                                    *
      *                                                               *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
       init-jparser.

           Call "HWTJINIT" using
             HWTJ-RETURN-CODE
             workarea-max *> parser work area size in bytes (input)
             HWTJ-PARSERHANDLE
             HWTJ-DIAG-AREA.

           If (HWTJ-OK)
             Display "  Parser initialized."
           else
             Display "  ERROR: Parser initialization failed"
             Call "DSPJDIAG" using
                             HWTJ-RETURN-CODE
                             HWTJ-DIAG-AREA
           End-If
           .

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Method: parse-json-body                                        *
      *                                                                *
      * Parses the sample JSON data.                                   *
      *                                                                *
      * Services Used:                                                 *
      *                                                                *
      * HWTJPARS: Builds an internal representation of the specified   *
      *           JSON string. This allows efficient search, traversal,*
      *           and modification of the JSON data.                   *
      *                                                                *
      * USAGE: HWTJPARS does not make a local copy of the JSON source  *
      *        string. Therefore, the caller must ensure that the      *
      *        provided source string remains unmodified for the       *
      *        duration of the parser instance. If the source string   *
      *        is modified, subsequent service calls may result in     *
      *        unexpected behavior.                                    *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       parse-json-body.

           Call "HWTJPARS" using
                HWTJ-RETURN-CODE
                HWTJ-PARSERHANDLE
                resp-body-ptr
                resp-body-len
                HWTJ-DIAG-AREA.

           If (HWTJ-OK)
             Display "  Response body parsed successfully"
           else
             Display "  ERROR: Unable to parser JSON data"
             Call "DSPJDIAG" using
                             HWTJ-RETURN-CODE
                             HWTJ-DIAG-AREA

           End-If
           .

      ***************************************************************
      * Procedure: retrieve-airport-data                            *
      *                                                             *
      * function: Search for various data returned by the server    *
      *        and save them in a data structure for future use.    *
      *                                                             *
      * Services Used:                                              *
      *                                                             *
      * Almost all of the routines called by this routine and below *
      * were copied directly from the z/OS Client Web Enablement    *
      * Toolkit JSON parser sample (HWTJXC1).                       *
      *                                                             *
      * Usage:                                                      *
      *                                                             *
      * Use HWTJSRCH to find multipe name value pairs               *
      *                                                             *
      ***************************************************************
       retrieve-airport-data.

      *     __________________________________________________________
      *    |                                                          |
      *    | Retrieve general airport information (i.e. name,         |
      *    | abbreviation, and state) from the response body. The     |
      *    | find-string and find-object subprograms utilize the      |
      *    | JSON search services to extract the airport information  |
      *    | from the response body. For each key:value pair, we      |
      *    | copy the search key into search-string, compute the      |
      *    | length of the search string, and invoke either           |
      *    | "find-string" or "find-object" appropriately. If a match |
      *    | is found, the data is copied into the airport-info       |
      *    | structure. This demonstrates how to share data between   |
      *    | a callback routine and a main program.                   |
      *    |__________________________________________________________|

           *> Establish addressability to the airport data structure
           Set address of resp-body-data to resp-body-data-ptr.

           *> Perform a sanity check on the airport-info data.
           If resp-body-data-eye not equal "AIRPORT" then
             display "  Eyecatcher check failed for airport-info"
             exit program
           End-if

           Display "  Extracting airport status information...".

      *     __________________________________________________________
      *    |                                                          |
      *    | search-string functions as a dummy variable. It is       |
      *    | initialized with a new search string before each         |
      *    | invocation of find-string; because find-string requires  |
      *    | a pointer we set search-string-ptr only one time         |
      *    |__________________________________________________________|
           Set search-string-ptr to address of search-string.

           Move Name-Key to search-string.
           Compute search-string-len = function length(Name-Key).
           Call "find-string" using
                              root-object
                              search-string-ptr
                              search-string-len
                              search-result-ptr
                              search-result-len.

           If HWTJ-OK then
             Set address of string-dsect to search-result-ptr
             Compute data-copy-len =
               function Min(search-result-len,
                            function length(airport-name))
             Move string-dsect(1:search-result-len) to airport-name
           End-If

           Move Iata-Key to search-string.
           Compute search-string-len = function length(Iata-key).
           Call "find-string" using
                              root-object
                              search-string-ptr
                              search-string-len
                              search-result-ptr
                              search-result-len.
           If HWTJ-OK then
             Set address of string-dsect to search-result-ptr
             Compute data-copy-len =
               function min(search-result-len,
                            function length(airport-iata))
             Move  string-dsect(1:search-result-len) to airport-iata
           End-If

           Move State-Key to search-string.
           Compute search-string-len = function length(State-Key)
           Call "find-string" using
                              root-object
                              search-string-ptr
                              search-string-len
                              search-result-ptr
                              search-result-len.

           If HWTJ-OK then
             Set address of string-dsect to search-result-ptr
             Compute data-copy-len =
               function min(search-result-len,
                            function length(airport-state))
             Move  string-dsect(1:search-result-len) to airport-state
           End-If

           Move Country-Key to search-string.
           Compute search-string-len = function length(Country-Key)
           Call "find-string" using
                              root-object
                              search-string-ptr
                              search-string-len
                              search-result-ptr
                              search-result-len.

           If HWTJ-OK then
             Set address of string-dsect to search-result-ptr
             Compute data-copy-len =
               function min(search-result-len,
                            function length(airport-country))
             Move  string-dsect(1:search-result-len) to airport-country
           End-If

           Move Long-Key to search-string.
           Compute search-string-len = function length(Long-Key)
           Call "find-string" using
                              root-object
                              search-string-ptr
                              search-string-len
                              search-result-ptr
                              search-result-len.

           If HWTJ-OK then
             Set address of string-dsect to search-result-ptr
             Compute data-copy-len =
               function min(search-result-len,
                            function length(airport-long))
             Move  string-dsect(1:search-result-len) to airport-long
           End-If

           Move Lat-Key to search-string.
           Compute search-string-len = function length(Lat-Key)
           Call "find-string" using
                              root-object
                              search-string-ptr
                              search-string-len
                              search-result-ptr
                              search-result-len.

           If HWTJ-OK then
             Set address of string-dsect to search-result-ptr
             Compute data-copy-len =
               function min(search-result-len,
                            function length(airport-lat))
             Move  string-dsect(1:search-result-len) to airport-lat
           End-If



           .

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Method: free-jparser                                           *
      *                                                                *
      * Performs cleanup by freeing memory used by the parser and      *
      * invalidating the parser handle.                                *
      *                                                                *
      * Services Used:                                                 *
      *                                                                *
      *   HWTJTERM: Terminates a parser instance and frees the storage *
      *             allocated by the parse services.                   *
      *                                                                *
      *  USAGE: The third parameter to hwtjterm is used to specify the *
      *         behavior of terminate if the parser is determined to be*
      *         stuck in an "in-use" state. IBM recommends using the   *
      *         HWTJ-NOFORCE option in most cases. Because our sample  *
      *         is not multi-threaded, the risk of the parser getting  *
      *         stuck in an "in-use" state is low. Therefore, we       *
      *         provide a value of HWTJ-NOFORCE for the force option.  *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       free-jparser.

           Set HWTJ-NOFORCE to true.

           If (NOT HWTJ-PARSERHANDLE-INUSE)
             Call "HWTJTERM" using
                HWTJ-RETURN-CODE
                HWTJ-PARSERHANDLE
                HWTJ-FORCEOPTION
                HWTJ-DIAG-AREA
           End-If

           Evaluate true
             When HWTJ-OK
               Display "  Parser work area freed."
             When HWTJ-PARSERHANDLE-INUSE
               Display "  ERROR: Unable to perform cleanup."
                "Retrying cleanup with force option enabled."

               Set HWTJ-FORCE to true

               *> Attempt to force cleanup. Not recommended!
               Call "HWTJTERM" using
                               HWTJ-RETURN-CODE
                               HWTJ-PARSERHANDLE
                               HWTJ-FORCEOPTION
                               HWTJ-DIAG-AREA

               *> Check if cleanup was successful.
               If HWTJ-OK
                 Display "  Parser work area freed using force"
                          "option."
               else
                 Display "  ERROR: Unable to free resources with force"
                   "option enabled. Could not free parser work area."
                 Call "DSPJDIAG" using
                                 HWTJ-RETURN-CODE
                                 HWTJ-DIAG-AREA
               End-If
             When other
               Display "  ERROR: Unable to perform cleanup. Could not "
                 "free parser work area."
               Call "DSPJDIAG" using
                               HWTJ-RETURN-CODE
                               HWTJ-DIAG-AREA
           End-Evaluate
           .

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Method: find-string                                            *
      *                                                                *
      * Searches the specified JSON object for a name:value pair where *
      * the name matches the specified search string and the value     *
      * type is string. This is a convenience method that can be used  *
      * when the structure of the JSON data is known beforehand.       *
      *                                                                *
      *   Input:  - A handle of type object or array.                  *
      *           - A string used as the search parameter.             *
      *                                                                *
      *   Output: If a match is found, the string value of the         *
      *           name:value pair is returned.                         *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       IDENTIFICATION DIVISION.
       PROGRAM-ID find-string COMMON.
       DATA DIVISION.

       LINKAGE SECTION.
       01 object-handle       Pic 9(9).
       01 search-string-addr  Pointer.
       01 search-string-len   Pic 9(9).
       01 value-addr          Pointer.
       01 value-len           Pic 9(9) Binary.

       PROCEDURE DIVISION using object-handle,
                                search-string-addr,
                                search-string-len,
                                value-addr,
                                value-len.
       Begin.

           Set HWTJ-STRING-TYPE to true.

           Call "find-value" using
                             object-handle
                             search-string-addr
                             search-string-len
                             HWTJ-JTYPE
                             value-addr
                             value-len.

       End Program find-string.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Method: find-object                                            *
      *                                                                *
      * Searches the specified JSON object for a name:value pair where *
      * the name matches the specified search string and the value     *
      * type is object. This is a convenience method that can be used  *
      * when the structure of the JSON data is known beforehand.       *
      *                                                                *
      * Input:  - A handle of type object or array.                    *
      *         - A string used as the search parameter.               *
      *                                                                *
      * Output: If a match is found, a handle to the object value of   *
      *         the name:value pair is returned.                       *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       IDENTIFICATION DIVISION.
       PROGRAM-ID find-object COMMON.
       DATA DIVISION.

       WORKING-STORAGE SECTION.
       01 value-length Pic 9(9) Binary Value 4.
       01 result-addr  Pointer Value Null.

       LINKAGE SECTION.
       01 object-handle      Pic 9(9).
       01 search-string-addr Pointer.
       01 search-string-len  Pic 9(9).
       01 result-obj-handle  Pic 9(9).

       PROCEDURE DIVISION using object-handle,
                                search-string-addr,
                                search-string-len,
                                result-obj-handle.
       Begin.

           *> This allows find-value to update result-object-handle
           Set result-addr to address of result-obj-handle.

           Set HWTJ-OBJECT-TYPE to true.

           Call "find-value" using
                             object-handle
                             search-string-addr
                             search-string-len
                             HWTJ-JTYPE
                             result-addr
                             value-length.

       End Program find-object.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
      * Method: find-value                                             *
      *                                                                *
      * Searches the specified object for a name:value pair whose name *
      * matches the the specified search string. This is a utility     *
      * method used by the "find" routines to easily search and        *
      * retrieve a value from an object when the name and value type   *
      * are known.                                                     *
      *                                                                *
      * Input:  - A handle of type object or array.                    *
      *         - A string used as a search parameter.                 *
      *         - A JSON type as defined in the IBM-provided Cobol     *
      *           interface definition file.                           *
      *                                                                *
      * Output: A pointer to the value is returned.                    *
      *                                                                *
      * Services Used:                                                 *
      *    HWTJGJST: Gets the JSON type associated with a specified    *
      *              object or entry handle.                           *
      *    HWTJSRCH: Finds a particular name string within the JSON    *
      *              text.                                             *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
       IDENTIFICATION DIVISION.
       PROGRAM-ID. find-value common.
       DATA DIVISION.

       LOCAL-STORAGE SECTION.
       01 entry-value-handle     Pic 9(9) Binary Value 0.
       01 starting-search-handle Pic 9(9) Binary Value 0.
       01 entry-value-addr       Pointer Value Null.
       01 actual-entry-type      Pic 9(9) Binary Value 0.
       01 num-value              Pic 9(9) Binary Value 0.
       01 num-value-ptr          Pointer Value Null.
       01 num-value-length       Pic 9(9) Binary Value 0.

       LINKAGE SECTION.
       01 object-to-search    Pic 9(9) Binary.
       01 search-string-addr  Pointer.
       01 search-string-len   Pic 9(9) Binary.
       01 expected-entry-type Pic 9(9) Binary.
       01 value-addr          Pointer.
       01 value-len           Pic 9(9) Binary.

       01 result-handle Pic 9(9) Binary.
       01 string-dsect Pic X(256).

       PROCEDURE DIVISION using object-to-search,
                                search-string-addr,
                                search-string-len,
                                expected-entry-type,
                                value-addr,
                                value-len.
       Begin.

             *> Limit the search scope to within the specified object.
             Set HWTJ-SEARCHTYPE-OBJECT to true.

             *> Perform the search.
             Call "HWTJSRCH" using
                             HWTJ-RETURN-CODE
                             HWTJ-PARSERHANDLE
                             HWTJ-SEARCHTYPE
                             search-string-addr
                             search-string-len
                             object-to-search
                             starting-search-handle
                             entry-value-handle
                             HWTJ-DIAG-AREA.

             *> If match was found, the result is in entry-value-handle.
             If HWTJ-OK

               *> Determine the entry type returned by HWTJSRCH.
               Call "HWTJGJST" using
                               HWTJ-RETURN-CODE
                               HWTJ-PARSERHANDLE
                               entry-value-handle
                               actual-entry-type
                               HWTJ-DIAG-AREA

               *> Verify that the entry type matches the expected type.
               If (HWTJ-OK AND
                 (actual-entry-type is equal to expected-entry-type))

                 *> Initialize HWTJ-JTYPE with entry type for evaluate.
                 Move actual-entry-type to HWTJ-JTYPE

                 EVALUATE true
                   When HWTJ-OBJECT-TYPE *> copy result to output parm
                     Set address of result-handle to value-addr
                     Move entry-value-handle to result-handle
                   When HWTJ-ARRAY-TYPE *> copy result to output parm
                     Set address of result-handle to value-addr
                     Move entry-value-handle to result-handle
                   When HWTJ-NUMBER-TYPE or HWTJ-STRING-TYPE
                     *>  Retrieve the value.
                     Call "HWTJGVAL" using
                                     HWTJ-RETURN-CODE
                                     HWTJ-PARSERHANDLE
                                     entry-value-handle
                                     entry-value-addr
                                     value-len
                                     HWTJ-DIAG-AREA
                     If HWTJ-OK
                       *> Establish addressability to value.
                       Set value-addr to entry-value-addr

                       *> Check if value can be converted to numeric
                       If HWTJ-NUMBER-TYPE

                         *> HWTJGNUV expects an address to output buffer
                         Set num-value-ptr to
                             address of num-value
                         *> The length of the output buffer is required
                         Compute num-value-length =
                           function length(num-value)

                         *> Convert from character data to numeric data
                         Call "HWTJGNUV" using
                                         HWTJ-RETURN-CODE
                                         HWTJ-PARSERHANDLE
                                         entry-value-handle
                                         num-value-ptr
                                         num-value-length
                                         HWTJ-VALDESCRIPTOR
                                         HWTJ-DIAG-AREA
                         If NOT HWTJ-OK
                           Display "** ERROR: HWTJGNUV failed."
                           Call "DSPJDIAG" using
                                         HWTJ-RETURN-CODE
                                         HWTJ-DIAG-AREA
                         End-If
                       End-If
                     else
                       Display "** ERROR: HWTJGVAL failed."
                       Call "DSPJDIAG" using
                                       HWTJ-RETURN-CODE
                                       HWTJ-DIAG-AREA
                     End-If
                   When HWTJ-BOOLEAN-TYPE
                     Call "HWTJGBOV" using
                                     HWTJ-RETURN-CODE
                                     HWTJ-PARSERHANDLE
                                     entry-value-handle
                                     HWTJ-BOOLEANValue
                                     HWTJ-DIAG-AREA

                   When HWTJ-Null-TYPE
                     Display "Null"
                 End-Evaluate
               End-If
             Else
               Set address of string-dsect to search-string-addr
               Display "** ERROR: HWTJSRCH failed."
               Display "**   search-string:"
                   string-dsect(1:search-string-len)
               Call "DSPJDIAG" using
                               HWTJ-RETURN-CODE
                               HWTJ-DIAG-AREA
             End-If *> HWTJSRCH = HWTJ-OK
             .
       End Program Find-Value.

       End Program HWTHBDYX.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      * This program is used to display the current state of the      *
      * return code, reason code, and reason description.             *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
       IDENTIFICATION DIVISION.
       PROGRAM-ID. DSPJDIAG.
       DATA DIVISION.

       WORKING-STORAGE SECTION.
           COPY HWTJICOB.

       LOCAL-STORAGE SECTION.
       01 return-code-text Pic X(30) Value Spaces.
       01 reason-code-text Pic X(30) Value Spaces.

       LINKAGE SECTION.
       01 ret-code Pic X(4).
       01 diag-area.
           05  reason-code Pic X(4).
           05  reason-desc Pic X(128).

       PROCEDURE DIVISION using
                          ret-code,
                          diag-area.
       Begin.

           Move ret-code to HWTJ-RETURN-CODE

           *> Translate the return code integer into its text equivalent
           EVALUATE true
              When HWTJ-OK
                Move "HWTJ-OK" to return-code-text
              When HWTJ-WARNING
                Move "HWTJ-WARNING" to return-code-text
              When HWTJ-PARSERHANDLE-INV
                Move "HWTJ-PARSERHANDLE-INV" to return-code-text
              When HWTJ-PARSERHANDLE-INUSE
                Move "HWTJ-PARSERHANDLE-INUSE" to return-code-text
              When HWTJ-INACCESSIBLE-PARM
                Move "HWTJ-INACCESSIBLE-PARM" to return-code-text
              When HWTJ-HANDLE-INV
                Move "HWTJ-HANDLE-INV" to return-code-text
              When HWTJ-HANDLE-TYPE-ERROR
                Move "HWTJ-HANDLE-TYPE-ERROR" to return-code-text
              When HWTJ-BUFFER-TOO-SMALL
                Move "HWTJ-BUFFER-TOO-SMALL" to return-code-text
              When HWTJ-INDEX-OUT-OF-BOUNDS
                Move "HWTJ-INDEX-OUT-OF-BOUNDS" to return-code-text
              When HWTJ-WORKAREA-TOO-SMALL
                Move "HWTJ-WORKAREA-TOO-SMALL" to return-code-text
              When HWTJ-PARSE-ERROR
                Move "HWTJ-PARSE-ERROR" to return-code-text
              When HWTJ-ROOT-OBJECT-MISSING
                Move "HWTJ-ROOT-OBJECT-MISSING" to return-code-text
              When HWTJ-CANNOT-OBTAIN-WORKAREA
                Move "HWTJ-CANNOT-OBTAIN-WORKAREA" to return-code-text
              When HWTJ-JCREN-ENTRYNAMEADDR-INV
                Move "HWTJ-JCREN-ENTRYNAMEADDR-INV" to return-code-text
              When HWTJ-JCREN-ENTRYNAMELEN-INV
                Move "HWTJ-JCREN-ENTRYNAMELEN-INV" to return-code-text
              When HWTJ-JCREN-ENTRYValueADDR-INV
                Move "HWTJ-JCREN-ENTRYValueADDR-INV" to return-code-text
              When HWTJ-JCREN-ENTRYValueLEN-INV
                Move "HWTJ-JCREN-ENTRYValueLEN" to return-code-text
              When HWTJ-JCREN-ENTRYValueTYPE-INV
                Move "HWTJ-JCREN-ENTRYValueTYPE" to return-code-text
              When HWTJ-JCREN-ENTRYNAME-INV
                Move "HWTJ-JCREN-ENTRYNAME-INV" to return-code-text
              When HWTJ-JCREN-ENTRYValue-INV
                Move "HWTJ-JCREN-ENTRYValue-INV" to return-code-text
              When HWTJ-JGOEN-BUFFERADDR-INV
                Move "HWTJ-JGOEN-BUFFERADDR-INV" to return-code-text
              When HWTJ-JGOEN-BUFFERLEN-INV
                Move "HWTJ-JGOEN-BUFFERLEN-INV" to return-code-text
              When HWTJ-JPARS-JSONTEXTADDR-INV
                Move "HWTJ-JPARS-JSONTEXTADDR-INV" to return-code-text
              When HWTJ-JPARS-JSONTEXTLEN-INV
                Move "HWTJ-JPARS-JSONTEXTLEN-INV" to return-code-text
              When HWTJ-JPARS-WORKAREA-ERROR
                Move "HWTJ-JPARS-WORKAREA-ERROR" to return-code-text
              When HWTJ-JSERI-NEWJTXTBUFFADDR-INV
               Move "HWTJ-JSERI-NEWJTXTBUFFERADDR-INV"
                 to return-code-text
              When HWTJ-JSERI-NEWJTXTBUFFLEN-INV
                Move "HWTJ-JSERI-NEWJTXTBUFFLEN-INV" to return-code-text
              When HWTJ-JSRCH-SEARCHTYPE-INV
                Move "HWTJ-JSRCH-SEARCHTYPE-INV" to return-code-text
              When HWTJ-JSRCH-SRCHSTRADDR-INV
                Move "HWTJ-JSRCH-SRCHSTRINGADDR-INV" to return-code-text
              When HWTJ-JSRCH-SRCHSTRLEN-INV
                Move "HWTJ-JSRCH-SRCHSTRINGLEN-INV" to return-code-text
              When HWTJ-JSRCH-SRCHSTR-NOT-FOUND
                Move "HWTJ-JSRCH-SRCHSTR-NOT-FOUND" to return-code-text
              When HWTJ-JSRCH-STARTINGHANDLE-INV
                Move "HWTJ-JSRCH-STARTINGHANDLE-INV" to return-code-text
              When HWTJ-JTERM-CANNOT-FREE-WORKA
                Move "HWTJ-JTERM-CANNOT-FREE-WORKA" to return-code-text
              When HWTJ-JTERM-FORCEOPTION-INV
                Move "HWTJ-JTERM-FORCEOPTION-INV" to return-code-text
              When HWTJ-INTERRUPT-STATUS-INV
                Move "HWTJ-INTERRUPT-STATUS-INV" to return-code-text
              When HWTJ-LOCKS-HELD
                Move "HWTJ-LOCKS-HELD" to return-code-text
              When HWTJ-UNSUPPORTED-RELEASE
                Move "HWTJ-UNSUPPORTED-RELEASE" to return-code-text
              When HWTJ-UNEXPECTED-ERROR
                Move "HWTJ-UNEXPECTED-ERROR" to return-code-text
           End-Evaluate

           If return-code-text is equal to SPACES
             Move 'Unknown return code' to return-code-text
           End-If

           *> Not all errors result in a reason code. Therefore, only
           *> fill out the reason-code-text if the reason code is
           *> non-zero
           If reason-code is not equal ZERO

             Move reason-code to REASONCODE

             EVALUATE true
               When PARSE-ERR-UNEXPECTED-TOKEN
                 Move "PARSE-ERR-UNEXPECTED-TOKEN" to reason-code-text
               When PARSE-ERR-INCompLETE-OBJECT
                 Move "PARSE-ERR-INCompLETE-OBJECT" to reason-code-text
               When PARSE-ERR-INCompLETE-ARRAY
                 Move "PARSE-ERR-INCompLETE-ARRAY" to reason-code-text
               When PARSE-ERR-MISSING-COMMA
                 Move "PARSE-ERR-MISSING-COMMA" to reason-code-text
               When PARSE-ERR-MISSING-PAIR-NAME
                 Move "PARSE-ERR-MISSING-PAIR-NAME" to reason-code-text
               When PARSE-ERR-INVALID-OBJECT-KEY
                 Move "PARSE-ERR-INVALID-OBJECT-KEY" to reason-code-text
               When PARSE-ERR-MISSING-COLON
                 Move "PARSE-ERR-MISSING-COLON" to reason-code-text
               When PARSE-ERR-INV-UNICODE-SEQUENCE
                 Move "PARSE-ERR-INV-UNICODE-SEQUENCE"
                 to reason-code-text
               When PARSE-ERR-UNTERMINATED-STRING
                 Move "PARSE-ERR-UNTERMINATED-STRING"
                   to reason-code-text
               When PARSE-ERR-INVALID-NUMBER
                 Move "PARSE-ERR-INVALID-NUMBER" to reason-code-text
               When PARSE-ERR-INVALID-TOKEN
                 Move "PARSE-ERR-INVALID-TOKEN" to reason-code-text
               When CREATE-ENTRY-BAD-RESULT-CUR
                 Move "CREATE-ENTRY-BAD-RESULT-CUR" to reason-code-text
               When CREATE-ENTRY-BAD-OBJECT-HANDLE
                 Move "CREATE-ENTRY-BAD-OBJECT-HANDLE"
                   to reason-code-text
               When CREATE-ENTRY-BAD-RESULT-AREA
                 Move "CREATE-ENTRY-BAD-RESULT-AREA" to reason-code-text
               When CREATE-ENTRY-BAD-RESULT-AREA2
                 Move "CREATE-ENTRY-BAD-RESULT-AREA2"
                   to reason-code-text
               When CREATE-ENTRY-BAD-TARGET-OBJECT
                 Move "CREATE-ENTRY-BAD-TARGET-OBJECT"
                   to reason-code-text
               When CREATE-ENTRY-BAD-Value-TYPE
                 Move "CREATE-ENTRY-BAD-Value-TYPE" to reason-code-text
               When CREATE-ENTRY-BAD-STRING
                 Move "CREATE-ENTRY-BAD-STRING" to reason-code-text
               When CREATE-ENTRY-BAD-NAME-STRING
                 Move "CREATE-ENTRY-BAD-NAME-STRING" to reason-code-text
               When CREATE-ENTRY-BAD-Value-STRING
                 Move "CREATE-ENTRY-BAD-Value-STRING"
                   to reason-code-text
               When CREATE-ENTRY-CNT-FLAG-NOT-Set
                 Move "CREATE-ENTRY-CNT-FLAG-NOT-Set"
                   to reason-code-text
               When CREATE-ENTRY-CNT-VAR-NOT-Set
                 Move "CREATE-ENTRY-CNT-VAR-NOT-Set" to reason-code-text
               When CREATE-ENTRY-PARSE-Value-INV
                 Move "CREATE-ENTRY-PARSE-Value-INV" to reason-code-text
               When CREATE-ENTRY-INVNAM-UNICODESEQ
                 Move "CREATE-ENTRY-INVNAM-UNICODESEQ"
                   to reason-code-text
               When CREATE-ENTRY-INVVAL-UNICODESEQ
                 Move "CREATE-ENTRY-INVVAL-UNICODESEQ"
                   to reason-code-text
               When CREATE-ENTRY-INV-UNICODESEQ
                 Move "CREATE-ENTRY-INV-UNICODESEQ" to reason-code-text
             End-Evaluate
           End-If

           Display "Return Code: " return-code-text.
           Display "Reason Code: " reason-code-text.
           Display "Reason Desc: " reason-desc.

       End Program DSPJDIAG.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      * This program is used to display the current state of the      *
      * return code, reason code, and reason description.             *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
       IDENTIFICATION DIVISION.
       PROGRAM-ID. DSPHDIAG.
       DATA DIVISION.

       WORKING-STORAGE SECTION.
           COPY HWTHICOB.

       LOCAL-STORAGE SECTION.
       01 retcode-text Pic X(30) Value Spaces.
       01 rsncode-text Pic X(30) Value Spaces.

       LINKAGE SECTION.
       01 retcode      Pic 9(9) Binary.
       01 diag-area.
           05  srvcnum Pic 9(9) Binary.
           05  rsncode Pic 9(9) Binary.
           05  rsndesc Pic X(128).

       PROCEDURE DIVISION using
                          retcode,
                          diag-area.
       Begin.

           Compute HWTH-RETURN-CODE = retcode.

           *> Translate the return code integer into its text equivalent
           Evaluate true
              When HWTH-OK
                Move "HWTH-OK" to retcode-text
              When HWTH-WARNING
                Move "HWTH-WARNING" to retcode-text
              When HWTH-HANDLE-INV
                Move "HWTH-HANDLE-INV" to retcode-text
              When HWTH-HANDLE-INUSE
                Move "HWTH-HANDLE-INUSE" to retcode-text
              When HWTH-HANDLETYPE-INV
                Move "HWTH-HANDLETYPE-INV" to retcode-text
              When HWTH-INACCESSIBLE-PARM
                Move "HWTH-INACCESSIBLE-PARM" to retcode-text
              When HWTH-CANNOT-OBTAIN-WORKAREA
                Move "HWTH-CANNOT-OBTAIN-WORKAREA" to retcode-text
              When HWTH-COMMUNICATION-ERROR
                Move "HWTH-COMMUNICATION-ERROR" to retcode-text
              When HWTH-CANNOT-INCREASE-WORKAREA
                Move "HWTH-CANNOT-INCREASE-WORKAREA" to retcode-text
              When HWTH-CANNOT-FREE-WORKAREA
                Move "HWTH-CANNOT-FREE-WORKAREA" to retcode-text
              When HWTH-CONNECTION-NOT-ACTIVE
                Move "HWTH-CONNECTION-NOT-ACTIVE" to retcode-text
              When HWTH-HSet-OPTIONVALADDR-INV
                Move "HWTH-HSet-OPTIONVALADDR-INV" to retcode-text
              When HWTH-HSet-OPTIONVALLEN-INV
                Move "HWTH-HSet-OPTIONVALLEN-INV" to retcode-text
              When HWTH-HSet-OPTION-INV
                Move "HWTH-HSet-OPTION-INV" to retcode-text
              When HWTH-HSet-OPTIONValue-INV
                Move "HWTH-HSet-OPTIONValue-INV" to retcode-text
              When HWTH-HSet-CONN-ALREADY-ACTIVE
                Move "HWTH-HSet-CONN-ALREADY-ACTIVE" to retcode-text
              When HWTH-HSLST-SLIST-INV
                Move "HWTH-HSLST-SLIST-INV" to retcode-text
              When HWTH-HSLST-function-INV
                Move "HWTH-HSLST-function-INV" to retcode-text
              When HWTH-HSLST-STRINGLEN-INV
                Move "HWTH-HSLST-STRINGLEN-INV" to retcode-text
              When HWTH-HSLST-STRINGADDR-INV
                Move "HWTH-HSLST-STRINGADDR-INV" to retcode-text
              When HWTH-HTERM-FORCEOPTION-INV
                Move "HWTH-HTERM-FORCEOPTION-INV" to retcode-text
              When HWTH-HCONN-CONNECT-INV
                Move "HWTH-HCONN-CONNECT-INV" to retcode-text
              When HWTH-HRQST-REQUEST-INV
                Move "HWTH-HRQST-REQUEST-INV" to retcode-text
              When HWTH-INTERRUPT-STATUS-INV
                Move "HWTH-INTERRUPT-STATUS-INV" to retcode-text
              When HWTH-LOCKS-HELD
                Move "HWTH-LOCKS-HELD" to retcode-text
              When HWTH-MODE-INV
                Move "HWTH-MODE-INV" to retcode-text
              When HWTH-AUTHLEVEL-INV
                Move "HWTH-AUTHLEVEL-INV" to retcode-text
              When HWTH-ENVIRONMENTAL-ERROR
                Move "HWTH-ENVIRONMENTAL-ERROR" to retcode-text
              When HWTH-UNSUPPORTED-RELEASE
                Move "HWTH-UNSUPPORTED-RELEASE" to retcode-text
              When HWTH-UNEXPECTED-ERROR
                Move "HWTH-UNEXPECTED-ERROR" to retcode-text
           End-evaluate

           If retcode-text is equal to Spaces
             Move 'Unknown return code' to retcode-text
           End-If

           *> Not all errors result in a reason code. Therefore, only
           *> fill out the reason-code-text if the reason code is
           *> non-zero.
           If rsncode is not equal ZERO

             Move rsncode to HWTH-REASONCODE

             Evaluate true
               When HWTH-RSN-REDIRECTED
                 Move "HWTH-RSN-REDIRECTED" to rsncode-text
               When HWTH-RSN-NEEDED-REDIRECT
                 Move "HWTH-RSN-NEEDED-REDIRECT" to rsncode-text
               When HWTH-RSN-REDIRECT-XDOMAIN
                 Move "HWTH-RSN-REDIRECT-XDOMAIN" to rsncode-text
               When HWTH-RSN-REDIRECT-TO-HTTP
                 Move "HWTH-RSN-REDIRECT-TO-HTTP" to rsncode-text
               When HWTH-RSN-REDIRECT-TO-HTTPS
                 Move "HWTH-RSN-REDIRECT-TO-HTTPS" to rsncode-text
               When HWTH-RSN-NO-REDIRECT-LOCATION
                 Move "HWTH-RSN-NO-REDIRECT-LOCATION" to rsncode-text
               When HWTH-RSN-HDR-EXIT-ABORT
                 Move "HWTH-RSN-HDR-EXIT-ABORT" to rsncode-text
               When HWTH-RSN-TUNNEL-UNSUCCESSFUL
                 Move "HWTH-RSN-TUNNEL-UNSUCCESSFUL" to rsncode-text
               When HWTH-RSN-MALFORMED-CHNK-ENCODE
                 Move "HWTH-RSN-MALFORMED-CHNK-ENCODE" to rsncode-text
               When HWTH-RSN-COOKIE-STORE-FULL
                 Move "HWTH-RSN-COOKIE-STORE-FULL" to rsncode-text
               When HWTH-RSN-COOKIE-INVALID
                 Move "HWTH-RSN-COOKIE-INVALID" to rsncode-text
               When HWTH-RSN-COOKIE-STORE-INV-PARM
                 Move "HWTH-RSN-COOKIE-STORE-INV-PARM" to rsncode-text
               When HWTH-RSN-COOKIE-ST-INCompLETE
                 Move "HWTH-RSN-COOKIE-ST-INCompLETE" to rsncode-text
               When HWTH-RSN-COOKIE-ST-MALLOC-ERR
                 Move "HWTH-RSN-COOKIE-ST-MALLOC-ERR" to rsncode-text
               When HWTH-RSN-COOKIE-ST-FREE-ERROR
                 Move "HWTH-RSN-COOKIE-ST-FREE-ERROR" to rsncode-text
               When HWTH-RSN-COOKIE-ST-UNEXP-ERROR
                 Move "HWTH-RSN-COOKIE-ST-UNEXP-ERROR" to rsncode-text
             End-Evaluate
           End-If

           Display "Return code: " retcode-text.
           Display "Service: " srvcnum.
           Display "Reason Code: " rsncode-text.
           Display "Reason Desc: " rsndesc.

       End Program DSPHDIAG.
