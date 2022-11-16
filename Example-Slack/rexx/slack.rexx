/* REXX */

/*********************************************************************/
/* Beginning of Copyright and License                                */
/*                                                                   */
/* Copyright 2015, 2021 IBM Corp.                                    */
/*                                                                   */
/* Licensed under the Apache License, Version 2.0 (the "License");   */
/* you may not use this file except in compliance with the License.  */
/* You may obtain a copy of the License at                           */
/*                                                                   */
/* http://www.apache.org/licenses/LICENSE-2.0                        */
/*                                                                   */
/* Unless required by applicable law or agreed to in writing,        */
/* software distributed under the License is distributed on an       */
/* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,      */
/* either express or implied.  See the License for the specific      */
/* language governing permissions and limitations under the License. */
/*                                                                   */
/* End of Copyright and License                                      */
/*********************************************************************/
/*                                                                   */
/* This application takes input from a sequential data set and posts */
/* it as a notification to a specific Slack channel.                 */
/*                                                                   */
/* Each record in the data set is sent to Slack using their JSON API */
/* with very little formatting taking place. Use the constants in    */
/* the program below to control the output.                          */
/*                                                                   */
/* See the accompanying README file for more information.            */
/*                                                                   */
/*********************************************************************/



/*********************************************************************/
/*                                                                   */
/* Application constants.                                            */
/*                                                                   */
/*********************************************************************/

/* Name of the channel to post to */
channelName = '#my-slack-channel'

/* Poster of the entry in the channel */
userName = 'My Rexx Slack bot'

/* Server URI (just protocol and host really) */
uri = 'https://hooks.slack.com'

/* Name of data set containing the text to post */
msgDataset = 'hlq.SLACK.MESSAGES'

/*
 * This file is confidential as it contains an OAuth token which is
 * allowed to post to *ANY* Slack channel in your workspace.
 */

/* Name of data set containing the secret OAuth token */
oauthDataset = 'hlq.SLACK.OAUTH'

/*
 * TLS cipher suites: we need to establish a list of what is acceptable
 * to us as a client.
 */

/* TLS cipher suite list (4-character variants) */
tlsCipherSuiteList = 'C02F' || 'C027' || 'C030' || ,
                     'C028' || '009C' || '009D' || '003C'

/* C02F = TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 */
/* C027 = TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 */
/* C030 = TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 */
/* C028 = TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 */
/* 009C = TLS_RSA_WITH_AES_128_GCM_SHA256 */
/* 009D = TLS_RSA_WITH_AES_256_GCM_SHA384 */
/* 003C = TLS_RSA_WITH_AES_128_CBC_SHA256 */

/*
 * Specify where we can find the Certificate Authority (CA)
 * certificates when we are connecting to Slack.
 *
 * keyStore = 'SAF'  : Use SAF keyrings
 * keyStore = 'FILE' : Use key database files on zFS
 */
keyStore = 'SAF'

/*
 * A key ring accessible by the user executing this Rexx script.
 * Only used to validate the SSL certificate provided by Slack.
 *
 * 'userid/keyring' or just 'keyring' for current user
 *
 * Only required when keyStore = 'SAF'
 */
safKeyRing = 'SLACK'

/*
 * A key database file accessible on zFS by the user executing this
 * Rexx script. Only used to validate the SSL certificate provided
 * by Slack.
 *
 * Specify the full path to the key database file
 *
 * Only required when keyStore = 'FILE'
 */
keyDatabaseFile = '/u/user1/myKeyDb'

/*
 * The key stash file for the key database file referenced above.
 * The file should be accessible on zFS by the user executing this
 * Rexx script.
 *
 * Specify the full path to the key stash file.
 *
 * Only required when keyStore = 'FILE'
 */
keyStashFile = '/u/user1/myKeyDb.sth'

/*
 * If set to a non-empty string, then SSL tracing will be enabled
 * to allow the debug of TLS connection problems.
 *
 * Specify the full path of a binary trace output file.
 *
 * Example:
 *    sslTraceFile = '/u/user1/ssltrace.bin'
 *
 * To format the resulting trace file, use the gsktrace utility. It
 * is recommended the utility output is redirected to a file.
 *
 * Example:
 *    gsktrace ssltrace.bin > ssltrace.txt
 */
sslTraceFile = ''

/*********************************************************************/
/*                                                                   */
/* Main application starts here.                                     */
/*                                                                   */
/*********************************************************************/

/* Provide access to TSO commands */
Address TSO

/* Make the HWTHTTP host environment available */
Call hwtcalls on

/* Initialise some variables we use */
DiagArea. = ''
Messages. = ''
ReturnCode = 0
ReqHandle = 0
ConnectHandle = 0
HttpStatusCode = 0
HttpReasonCode = 0
ResponseBody = ''
RequestPath = ''

/*
 * Pull in the secret OAuth token.
 */

/* Open the data set containing the OAuth token */
Address TSO "ALLOCATE DA('" || oauthDataset || "') FILE(OAUTH) OLD"

/* Read in the first record */
Address MVS "EXECIO * DISKR OAUTH (FINIS"

/* Parse to the path variable                          */
/*  - No uppercase translation                         */
/*  - breaking on first space and discarding remainder */
Parse Pull requestPath .

/* Close the OAuth token data set */
Address TSO "FREE FILE(OAUTH)"


/*
 * Initialise the environment.
 */

/* Initialise some HWT constants */
Address hwthttp "hwtconst" "ReturnCode" "DiagArea."

If ReturnCode \= 0 Then Call ShowError "hwtconst"


/*
 * Initialise a connection
 */

/* Tell HWT we are creating a connection handle */
HandleType = HWTH_HANDLETYPE_CONNECTION
Address hwthttp "hwthinit" "ReturnCode" ,
                "HandleType" "ConnectHandle" "DiagArea."

If ReturnCode \= 0 Then Call ShowError "hwthinit (connection)"


/*
 * Setup the connection options
 */

/* Uncomment to enable debug messages */
/* Call SetConnOpt "HWTH_OPT_VERBOSE", "HWTH_VERBOSE_ON" */

/* Connection URI (hostname really) */
Call SetConnOpt "HWTH_OPT_URI", uri

/* Timeout on the send after 10 seconds */
Call SetConnOpt "HWTH_OPT_SNDTIMEOUTVAL", 10

/* Timeout on the receive after 10 seconds */
Call SetConnOpt "HWTH_OPT_RCVTIMEOUTVAL", 10

/* Want to use SSL */
Call SetConnOpt "HWTH_OPT_USE_SSL", "HWTH_SSL_USE"

/* Should we enable SSL tracing? */
If sslTraceFile \= '' Then Do

    /* Specify the output trace file */
    Call SetConnOpt "HWTH_OPT_SSLTRACE", sslTraceFile

End

/* Force use of TLS 1.2 */
Call SetConnOpt "HWTH_OPT_SSLVERSION", "HWTH_SSLVERSION_TLSv12"

/* Specify the list of acceptable cipher suites */
Call SetConnOpt "HWTH_OPT_SSLCIPHERSPECS", tlsCipherSuiteList

/* Are we using SAF? */
If keyStore = 'SAF' Then Do

    /* Use a SAF key ring */
    Call SetConnOpt "HWTH_OPT_SSLKEYTYPE", ,
                    "HWTH_SSLKEYTYPE_KEYRINGNAME"

    /* Use this key ring */
    Call SetConnOpt "HWTH_OPT_SSLKEY", safKeyRing

End
Else If keyStore = 'FILE' Then Do

    /* Use a key database file */
    Call SetConnOpt "HWTH_OPT_SSLKEYTYPE", ,
                    "HWTH_SSLKEYTYPE_KEYDBFILE"

    /* Use this database file */
    Call SetConnOpt "HWTH_OPT_SSLKEY", keyDatabaseFile

    /* Use this stash file */
    Call SetConnOpt "HWTH_OPT_SSLKEYSTASHFILE", keyStashFile

End
Else Do
    Say "keyStore (" || keyStore || ") should be one of SAF or FILE"
    Exit 12
End


/* Perform the connect */
Address hwthttp "hwthconn" "ReturnCode" "ConnectHandle" "DiagArea."

If ReturnCode \= 0 Then Call ShowError "hwthconn"


/*
 * Pull in messages to be emitted to Slack as a stem variable.
 */

/* Open the data set containing the message data */
Address TSO "ALLOCATE DA('" || msgDataset || "') FILE(MESSAGES) OLD"

/* Check this allocate worked OK */
If RC \= 0 Then Exit 12

/* Read in all the records */
Address MVS "EXECIO * DISKR MESSAGES (STEM Messages. FINIS"

/* Do an empty write to clear the data set */
Address MVS "EXECIO 0 DISKW MESSAGES (OPEN FINIS"

/* Close the message data set */
Address TSO "FREE FILE(MESSAGES)"


/*
 * Loop through each line in the file and send each as a separate
 * Slack notification.
 */

Do i = 1 To Messages.0

    /* Strip leading and trailing spaces */
    textToDisplay = Strip(Messages.i)

    /* Build the request body */
    requestData = '{' || ,
     '"channel":"'    || channelName   || '",' || ,
     '"username":"'   || userName      || '",' || ,
     '"text":"'       || textToDisplay || '"'  || ,
     '}'

    /* Confirm the request body */
    Say requestData

    /* Initialise the request */
    HandleType = HWTH_HANDLETYPE_HTTPREQUEST
    Address hwthttp "hwthinit" "ReturnCode" ,
                    "HandleType" "ReqHandle" "DiagArea."

    If ReturnCode \= 0 Then Call ShowError "hwthinit (request)"


    /*
     * Setup the request options
     */

    /* Setup list of headers */
    sList = 0
    headerContentType = 'Content-type: application/json'

    Address hwthttp "hwthslst" "ReturnCode" ,
                    "ReqHandle" "HWTH_SLST_NEW" "sList" ,
                    "headerContentType" "DiagArea."

    If ReturnCode \= 0 Then Call ShowError "hwthslst (new)"

    /* HTTP GET request */
    Call SetReqOpt "HWTH_OPT_REQUESTMETHOD", "HWTH_HTTP_REQUEST_POST"

    /* Request path */
    Call SetReqOpt "HWTH_OPT_URI", requestPath

    /* Use the HTTP headers list we have created */
    Call SetReqOpt "HWTH_OPT_HTTPHEADERS", sList

    /* Translate to ASCII outbound please */
    Call SetReqOpt "HWTH_OPT_TRANSLATE_REQBODY", ,
                   "HWTH_XLATE_REQBODY_E2A"

    /* Translate to EBCDIC inbound please */
    Call SetReqOpt "HWTH_OPT_TRANSLATE_RESPBODY", ,
                   "HWTH_XLATE_RESPBODY_A2E"

    /*
      The following options take a reference to the internal Rexx
      string buffer, but Rexx does not allow us to pass arguments by
      references and we can therefore not use the handy SetReqOpt
      subroutine used above.
    */

    /* Use the request body we created earlier */
    Address hwthttp "hwthset" "ReturnCode" "ReqHandle" ,
            "HWTH_OPT_REQUESTBODY" "requestData" "DiagArea."
    If ReturnCode \= 0 Then
        Call ShowError "hwthset HWTH_OPT_REQUESTBODY"

    /* Grab the response data into here */
    Address hwthttp "hwthset" "ReturnCode" "ReqHandle" ,
            "HWTH_OPT_RESPONSEBODY_USERDATA" "ResponseBody" "DiagArea."
    If ReturnCode \= 0 Then
        Call ShowError "hwthset HWTH_OPT_RESPONSEBODY_USERDATA"


    /* Perform the request */
    Address hwthttp "hwthrqst" "ReturnCode" ,
                    "ConnectHandle" "ReqHandle" ,
                    "HttpStatusCode" "HttpReasonCode" "DiagArea."

    If ReturnCode \= 0 Then Call ShowError "hwthrqst"

    /* Check for good HTTP response */
    If HttpStatusCode \= 200 Then Do

        /* Dump out the HTTP response code */
        Say "HTTP status" HttpStatusCode

        /* Dump out the HTTP reason code */
        Say "HTTP reason" HttpReasonCode

        /* Dump out the response body */
        Say "Response" ResponseBody

    End

    /* Free the request headers */
    Address hwthttp "hwthslst" "ReturnCode" ,
                    "ReqHandle" "HWTH_SLST_FREE" "sList" ,
                    "headerContentType" "DiagArea."

    If ReturnCode \= 0 Then Call ShowError "hwthslst (free)"

    /* Reset the request for next use */
    Address hwthttp "hwthrset" "ReturnCode" ,
                    "ReqHandle" "DiagArea."

    If ReturnCode \= 0 Then Call ShowError "hwthrset (free)"

End /* End of Messages.i loop */


/*
 * Processing of messages complete.
 * Now clean up the various handles we have open.
 */

/* Close the connection to Slack */
Address hwthttp "hwthdisc" "ReturnCode" "ConnectHandle" "DiagArea."

If ReturnCode \= 0 Then Call ShowError "hwthdisc"

/* Free the work area associated with the request */
Address hwthttp "hwthterm" "ReturnCode" "ReqHandle" ,
                "HWTH_NOFORCE" "DiagArea."

If ReturnCode \= 0 Then Call ShowError "hwthterm (request)"

/* Free the work area associated with the connection */
Address hwthttp "hwthterm" "ReturnCode" "ConnectHandle" ,
                "HWTH_NOFORCE" "DiagArea."

If ReturnCode \= 0 Then Call ShowError "hwthterm (connection)"


/* All complete */
Exit 0


/*********************************************************************/
/*                                                                   */
/* Routine to remove the drudgery of setting HTTP connection options */
/*                                                                   */
/*********************************************************************/

SetConnOpt:

/* Input arguments */
@optName  = Arg(1)
@optValue = Arg(2)

/* Clear current status */
ReturnCode = -1
DiagArea. = ''

/* Perform the call */
Address hwthttp "hwthset" "ReturnCode" "ConnectHandle" ,
                "@optName" "@optValue" "DiagArea."

/* Check for good return */
If ReturnCode \= 0 Then Call ShowError "hwthset (conn) " || @optName

/* All complete */
Return


/*********************************************************************/
/*                                                                   */
/* Routine to remove the drudgery of setting HTTP request options    */
/*                                                                   */
/*********************************************************************/

SetReqOpt:

/* Input arguments */
@optName  = Arg(1)
@optValue = Arg(2)

/* Clear current status */
ReturnCode = -1
DiagArea. = ''

/* Perform the call */
Address hwthttp "hwthset" "ReturnCode" "ReqHandle" ,
                "@optName" "@optValue" "DiagArea."

/* Check for good return */
If ReturnCode \= 0 Then Call ShowError "hwthset (req) " || @optName

/* All complete */
Return


/*********************************************************************/
/*                                                                   */
/* Displays the diagnostic data following a bad function call and    */
/* terminates the runtime with RC=8.                                 */
/*                                                                   */
/*********************************************************************/

ShowError: Procedure Expose ReturnCode DiagArea.

/* Pull in the function name and diagnostic data */
@fn = Arg(1)

/* Keep track of the sign of the return code (D2X must be 0 or +ve) */
If ReturnCode >= 0 Then SignReturnCode = '' ; Else SignReturnCode = '-'

/* Say what went wrong */
Say @fn || ,
    ": RC " || ReturnCode || ,
    "=" || SignReturnCode || "'" || D2X(ABS(ReturnCode)) || "'x"

/* Dump out the error */
Say "Service =" DiagArea.HWTH_Service
Say "Reason  =" DiagArea.HWTH_ReasonCode
Say "Desc    =" Strip(DiagArea.HWTH_ReasonDesc,,'00'x)

/* Terminate the runtime */
Exit 8

Return
