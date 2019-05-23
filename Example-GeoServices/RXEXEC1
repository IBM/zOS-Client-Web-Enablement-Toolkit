/* REXX */

/* START OF SPECIFICATIONS *********************************************/
/* Beginning of Copyright and License                                  */
/*                                                                     */
/* Copyright 2015, 2019 IBM Corp.                                      */
/*                                                                     */
/* Licensed under the Apache License, Version 2.0 (the "License");     */
/* you may not use this file except in compliance with the License.    */
/* You may obtain a copy of the License at                             */
/*                                                                     */
/* http://www.apache.org/licenses/LICENSE-2.0                          */
/*                                                                     */
/* Unless required by applicable law or agreed to in writing,          */
/* software distributed under the License is distributed on an         */
/* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,        */
/* either express or implied.  See the License for the specific        */
/* language governing permissions and limitations under the License.   */
/*                                                                     */
/* End of Copyright and License                                        */
/***********************************************************************/
/*                                                                     */
/*  SCRIPT NAME=RXEXEC1                                                */
/*                                                                     */
/*    DESCRIPTIVE NAME=Sample Rexx code to use HTTP services           */
/*                     in the z/OS Client Web Enablement Toolkit       */
/*                     Based on HWTHXRX1 sample shipped in samplib     */
/*  FUNCTION:                                                          */
/*  This sample how to access the geosvcs REST API interface.          */
/*                                                                     */
/*  This script provides sample calls to these HTTP Enabler            */
/*       services:                                                     */
/*    HWTHINIT - Initialize a connection or request instance.          */
/*    HWTHSET  - Set various connection or request options.            */
/*    HWTHCONN - Connect to a web server.                              */
/*    HWTHRQST - Make an HTTP request over an existing connection.     */
/*    HWTHDISC - Disconnect from a web server.                         */
/*    HWTHTERM - Terminate a connection or request instance.           */
/*                                                                     */
/* OPERATION:                                                          */
/*                                                                     */
/*  CODE FLOW in this sample:                                          */
/*    Call HTTP_init to create a connection instance.                  */
/*    Call HTTP_setupConnection to set all the necessary connection    */
/*      options prior to connecting to the web server.                 */
/*    Call HTTP_connect to connect to the web server.                  */
/*    Call HTTP_init to create a request instance.                     */
/*    Call HTTP_setupRequest to set the necessary request options.     */
/*    Call HTTP_request to send the request over the established       */
/*      connection.                                                    */
/*      * Stem variable ResponseHeaders. accumulates each response     */
/*        header received from the HTTP server                         */
/*      * Variable ResponseBody holds any response body content        */
/*        received from the HTTP server.                               */
/*      * Variables ResponseStatusCode and ResponseReasonCode hold     */
/*        the status code and reason received from the HTTP server.    */
/*    Call writeData to work with the ResponseBody returned by the     */
/*      web server (this body should be in JSON format, by design,     */
/*      allowing JSON Parser services to be used, in doing so).        */
/*    Call HTTP_terminate to terminate the request instance.           */
/*    Call HTTP_disconnect to disconnect the connection (socket)       */
/*      from the web server.                                           */
/*    Call HTTP_terminate to terminate the connection instance.        */
/*                                                                     */
/*                                                                     */
/* INVOCATION:                                                         */
/*    This can run in any non-reentrant REXX environment (e.g., TSO,   */
/*    ISPF, zOS UNIX, SYSTEM REXX) where the HWTHTTP and HWTJSON host  */
/*    commands are available.                                          */
/*    (the optional -v enables verbose trace)                          */
/*                                                                     */
/* DEPENDENCIES                                                        */
/*     none.                                                           */
/*                                                                     */
/*    NOTES:                                                           */
/*                                                                     */
/* No recovery logic has been supplied in this sample.                 */
/*                                                                     */
/*    REFERENCE:                                                       */
/*        See the z/OS MVS Programming: Callable Services for          */
/*        High-Level Languages publication for more information        */
/*        regarding the usage of HTTP Enabler APIs.                    */
/*                                                                     */
/* Change Activity:                                                    */
/* $L0 xxxxxxxx HBB77B0 yyyyy PDSCW: z/OS Client Web Enablement        */
/*     Toolkit sample (HTTP) in REXX programming language              */
/*                                                                     */
/* END OF SPECIFICATIONS  * * * * * * * * * * * * * * * * * * * * * * **/

/************/
/* MAIN     */
/************/

/*********************/
/* Get program args  */
/*********************/
VERBOSE = 0
parse arg argString
if GetArgs( argString ) <> 0 then
   exit -1

/******************************************************************/
/* REST API requires: all countries must be 2 chars long; city    */
/* and state to be at least 1 character                           */
/******************************************************************/
 if (length(sCity)=0|length(sState)=0|length(sCountry)=0) then
   exit usage( '** Invalid start location **' )

 if (length(dCity)=0|length(dState)=0|length(dCountry)=0) then
   exit usage( '** Invalid dest location **' )

/*********************************************/
/* Get Web Enablement Toolkit REXX constants */
/*********************************************/
 call HTTP_getToolkitConstants
 if RESULT <> 0 then
    exit fatalError( '** Environment error **' )

/***************************/
/* Indicate Program start  */
/***************************/
 say 'HTTP Web Enablement Toolkit Sample (Begin)'
 programRc = -1
/*****************************************/
/* Initialize request-related variables  */
/*****************************************/
 ConnectionHandle = ''
 RequestHandle = ''

/******************************************/
/* Initialize response-related variables  */
/******************************************/
 ExpectedResponseStatus = 200
 ResponseStatusCode = ''
 ResponseReason = ''
 ResponseHeaders. = ''
 ResponseBody = ''

/*******************************/
/* Obtain a connection handle  */
/*******************************/
 call HTTP_init HWTH_HANDLETYPE_CONNECTION
 if RESULT == 0 then
    do
    /**************************************************************/
    /* Set the necessary options before connecting to the server  */
    /**************************************************************/
    call HTTP_setupConnection
    if RESULT == 0 then
       do
       /*******************************/
       /* Connect to the HTTP server  */
       /*******************************/
       call HTTP_connect
       if RESULT == 0 then
          do
          /****************************/
          /* Obtain a request handle  */
          /****************************/
          call HTTP_init HWTH_HANDLETYPE_HTTPREQUEST
          if RESULT == 0 then
             do
             /****************************************************************/
             /* Set the necessary request options before making the request  */
             /****************************************************************/
             call HTTP_setupRequest
             if RESULT == 0 then
                do
                /**********************/
                /* Make the request   */
                /**********************/
                call HTTP_request
                if RESULT == 0 then
                   do
                   /*****************************************************/
                   /* If the response code was ok, then write the data  */
                   /* (for the purpose of this sample,  the writeData   */
                   /* outcome is purely illustrative).                  */
                   /*****************************************************/
                   if ResponseStatusCode == ExpectedResponseStatus then
                      programRc = writeData( ResponseBody )
                   else
                     say '***Bad resp received: 'ResponseStatusCode'.'
                   end /* endif request made */

                /**************************/
                /* Terminate the request  */
                /**************************/
                call HTTP_terminate RequestHandle, HWTH_NOFORCE
                end /* endif request setup */
             end /* endif request handle obtained */

          /******************************/
          /* Disconnect the connection  */
          /******************************/
          call HTTP_disconnect
          end  /* endif connected */
       end /* endif connection setup */

    /**********************************/
    /* Release the connection handle  */
    /**********************************/
    call HTTP_terminate ConnectionHandle, HWTH_NOFORCE
    end /* endif connection handle obtained */

 call closeToolkitTrace traceDD

 /*************************/
 /* Indicate Program end  */
 /*************************/
 say
 say 'HTTP Web Enablement Toolkit Sample (End)'

 exit programRc   /* end main */


 /*******************************************************************/
 /* Function:  writeData()                                          */
 /*                                                                 */
 /* Use JSON Parser services to process the airport data returned   */
 /* by the web server.  For simplicity, write results to standard   */
 /* out (in a real world application, this data could be displayed  */
 /* real-time in an application, written to storage media or        */
 /* displayed in some log or other media).                          */
 /*                                                                 */
 /* Return 0 if all parsing activity was performed successfully,    */
 /* -1 if otherwise.                                                */
 /*******************************************************************/
writeData:
 distanceData = arg(1)
 parserHandle = ''
 isJSON = 0;
 jRespHead = "application/json"
 l = length(jRespHead)
 /******************************************************************/
 /* Check to make sure that the data coming back is in JSON format */
 /* Loop thru all of the response headers and see if any of them   */
 /* say Content-Type=application/json                              */
 /******************************************************************/
 if VERBOSE then
   say "CHECKING HEADERS"

 do i = 1 to ResponseHeaders.0           /* 1 to total # of headers*/
   /* Header Name check */
   if ResponseHeaders.i = "Content-Type" then
     /* Header value check */
     if substr(ResponseHeaders.i.1,1,l) = jRespHead then
       isJSON = 1;
 end

 /* if none of the headers was JSON, then don't call parser */
 if isJSON = 0 Then do
   return fatalError( '** Data did not come back in JSON format ** ')
 end

 /***********************************/
 /* Obtain a JSON Parser instance.  */
 /***********************************/
 call JSON_initParser
 if RESULT <> 0 then
    return fatalError( '** Pre-processing error (parser init failure) **' )
 /****************************/
 /* Parse the airport data.  */
 /****************************/
 call JSON_parse distanceData
 if RESULT <> 0 then
    do
    call JSON_termParser
    return fatalError( '** Error while parsing distance data **' )
    end
 /*****************************************/
 /* Extract specific data and surface it, */
 /* then release the parser instance.     */
 /*****************************************/
 call JSON_searchAndDeserializeData
 call JSON_termParser
 return 0  /* end function */


 /*****************************************************/
 /*            HTTP-related functions                 */
 /*                                                   */
 /* These { HTTP_xxx } functions are located together */
 /* for ease of reference and are used to demonstrate */
 /* how this portion of the Web Enablement Toolkit    */
 /* can be used.                                      */
 /*****************************************************/

/*******************************************************/
/* Function:  HTTP_getToolkitConstants                 */
/*                                                     */
/* Access constants used by the toolkit (for return    */
/* codes, etc), via the HWTCONST toolkit api.          */
/*                                                     */
/* Returns: 0 if toolkit constants accessed, -1 if not */
/*******************************************************/
HTTP_getToolkitConstants:
 /***********************************************/
 /* Ensure that the toolkit host command is     */
 /* available in your REXX environment (no harm */
 /* done if already present).  Do this before   */
 /* your first toolkit api invocation.  Also,   */
 /* ensure no conflicting signal-handling in    */
 /* cases of running in USS environments.       */
 /***********************************************/
  if VERBOSE then
    say 'Setting hwtcalls on, syscalls sigoff'
 call hwtcalls 'on'
 call syscalls 'SIGOFF'
 /************************************************/
 /* Call the HWTCONST toolkit api.  This should  */
 /* make all toolkit-related constants available */
 /* to procedures via (expose of) HWT_CONSTANTS  */
 /************************************************/
 if VERBOSE then
    say 'Including HWT Constants...'
 address hwthttp "hwtconst ",
                 "ReturnCode ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwtconst', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwtconst (hwthttp) failure **' )
    end /* endif hwtconst failure */
 return 0  /* end function */


/*************************************************/
/* Function: HTTP_init                           */
/*                                               */
/* Create a handle of the designated type, via   */
/* the HWTHINIT toolkit api.  Populate the       */
/* corresponding global variable with the result */
/*                                               */
/* Returns: 0 if successful, -1 if not           */
/*************************************************/
HTTP_init:
 HandleType = arg(1)
 /***********************************/
 /* Call the HWTHINIT toolkit api.  */
 /***********************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthinit ",
                 "ReturnCode ",
                 "HandleType ",
                 "HandleOut ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthinit', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthinit failure **' )
    end
 if HandleType == HWTH_HANDLETYPE_CONNECTION then
    ConnectionHandle = HandleOut
 else
    RequestHandle = HandleOut
 return 0  /* end Function */


/****************************************************/
/* Function: HTTP_setupConnection                   */
/*                                                  */
/* Sets the necessary connection options, via the   */
/* HWTHSET toolkit api.  The global variable        */
/* ConnectionHandle orients the api as to the scope */
/* of the option(s).                                */
/*                                                  */
/* Returns: 0 if successful, -1 if not              */
/****************************************************/
HTTP_setupConnection:
 if VERBOSE then
    do
    /*****************************************************************/
    /* Set the HWT_OPT_VERBOSE option, if appropriate.               */
    /* This option is handy when developing an application (but may  */
    /* be undesirable once development is complete).  Inner workings */
    /* of the toolkit are traced by messages written to standard     */
    /* output, or optionally redirected to file (by use of the       */
    /* HWTH_OPT_VERBOSE_OUTPUT option)                               */
    /*****************************************************************/
    say '****** Set HWTH_OPT_VERBOSE for connection ******'
    ReturnCode = -1
    DiagArea. = ''
    address hwthttp "hwthset ",
                    "ReturnCode ",
                    "ConnectionHandle ",
                    "HWTH_OPT_VERBOSE ",
                    "HWTH_VERBOSE_ON ",
                    "DiagArea."
    RexxRC = RC
    if HTTP_isError(RexxRC,ReturnCode) then
       do
       call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
       return fatalError( '** hwthset (HWTH_OPT_VERBOSE) failure **' )
       end /* endif hwthset failure */

    call TurnOnVerboseOutput
    end /* endif script invocation requested (-V) VERBOSE */

 /****************************************************************************/
 /* Set URI for connection to the Geo Services REST API                 host */
 /****************************************************************************/
 if VERBOSE then
    say '****** Set HWTH_OPT_URI for connection ******'
 ConnectionUri = 'http://api.geosvc.com'
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "ConnectionHandle ",
                 "HWTH_OPT_URI ",
                 "ConnectionUri ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_URI) failure **' )
    end  /* endif hwthset failure */
 /***********************************************************************/
 /* Set HWTH_OPT_COOKIETYPE                                             */
 /*   Enable the cookie engine for this connection.  Any "eligible"     */
 /*   stored cookies will be resent to the host on subsequent           */
 /*   interactions automatically.                                       */
 /***********************************************************************/
 if VERBOSE then
    say '****** Set HWTH_OPT_COOKIETYPE for session cookies ******'
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "ConnectionHandle ",
                 "HWTH_OPT_COOKIETYPE ",
                 "HWTH_COOKIETYPE_SESSION ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_COOKIETYPE) failure **' )
    end  /* endif hwthset failure */
 if VERBOSE then
    say 'Connection setup successful'
 return 0  /* end subroutine */


/*************************************************************/
/* Function: HTTP_connect                                    */
/*                                                           */
/* Connect to the configured domain (host) via the HWTHCONN  */
/* toolkit api.                                              */
/*                                                           */
/* Returns: 0 if successful, -1 if not                       */
/*************************************************************/
HTTP_connect:
 if VERBOSE then
    say 'Connect'
 /**********************************/
 /* Call the HWTHCONN toolkit api  */
 /**********************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthconn ",
                 "ReturnCode ",
                 "ConnectionHandle ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthconn', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthconn failure **' )
    end
 if VERBOSE then
    say 'Connect (hwthconn) successful'
 return 0  /* end function */


/************************************************************/
/* Function: HTTP_setupRequest                              */
/*                                                          */
/* Sets the necessary request options.  The global variable */
/* RequestHandle orients the api as to the scope of the     */
/* option(s).                                               */
/*                                                          */
/* Returns: 0 if successful, -1 if not                      */
/************************************************************/
HTTP_setupRequest:
 if VERBOSE then
    say '****** Set HWTH_OPT_REQUESTMETHOD for request ******'
 /**************************************************************/
 /* Set HTTP Request method.                                   */
 /* A GET request method is used to get data from the server.  */
 /**************************************************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_REQUESTMETHOD ",
                 "HWTH_HTTP_REQUEST_GET",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError 'hwthset (HWTH_OPT_REQUESTMETHOD) failure **' )
    end  /* endif hwthset failure */
/*****************************************************************/
/* Set the request URI                                           */
/*  Set the URN URI that identifies a resource by name that is   */
/*    the target of our request.                                 */
/*****************************************************************/
 if VERBOSE then
    say'****** Set HWTH_OPT_URI for request ******'
 /* Add the request path portion of the request */
 requestPath = '/rest/'||sCountry||'/'||sState||'/'||sCity||'/distance'

 /* Add the apikey to the query parms portion of the request */
 queryParms = '?apikey='apikey


 /* Add the destination to the query parms portion of the request */
 queryParms = queryParms||'&p='||dCity||'&r='||dState
 queryParms = queryParms||'&c='dCountry

 requestPath = requestPath||queryParms

 if VERBOSE then
    say 'request URI:' requestPath

 ReturnCode = -1
 DiagArea. = ''

 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_URI ",
                 "requestPath ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_URI) failure **' )
    end  /* endif hwthset failure */
 /*********************************************************/
 /* Set the stem variable for receiving response headers  */
 /*********************************************************/
 ReturnCode = -1
 DiagArea. = ''
 if VERBOSE then
    say '****** Set HWTH_OPT_RESPONSEHDR_USERDATA for request ******'
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_RESPONSEHDR_USERDATA ",
                 "ResponseHeaders. ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_RESPONSEHDR_USERDATA) failure **')
    end /* endif hwthset failure */
 /*******************************************************************/
 /* Have the toolkit convert the response body from ASCII to EBCDIC */
 /* (so that we may pass it to our parser in a form that the latter */
 /* will understand)                                                */
 /*******************************************************************/
 ReturnCode = -1
 DiagArea. = ''
 if VERBOSE then
    say '****** Set HWTH_OPT_TRANSLATE_RESPBODY for request ******'
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_TRANSLATE_RESPBODY ",
                 "HWTH_XLATE_RESPBODY_A2E ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_TRANSLATE_RESPBODY) failure **' )
    end /* endif hwthset failure */
 /*************************************************/
 /* Set the variable for receiving response body  */
 /**************************************************/
 ReturnCode = -1
 DiagArea. = ''
 if VERBOSE then
    say '****** Set HWTH_OPT_RESPONSEBODY_USERDATA for request ******'
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_RESPONSEBODY_USERDATA ",
                 "ResponseBody ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_RESPONSEBODY_USERDATA) failure **')
    end /* endif hwthset failure */
 /*************************************************************/
 /* Set any request header(s) we may have.  This depends upon */
 /* the Http request (often we might not have any).           */
 /*************************************************************/
 call HTTP_setRequestHeaders
 if RESULT <> 0 then
    return fatalError( '** Unable to set Request Headers **' )
 if VERBOSE then
    say 'Request setup successful'
 return 0   /* end function */


/****************************************************************/
/* Function: HTTP_disconnect                                    */
/*                                                              */
/* Disconnect from the configured domain (host) via the         */
/* HWTHDISC toolkit api.                                        */
/*                                                              */
/* Returns: 0 if successful, -1 if not                          */
/****************************************************************/
HTTP_disconnect:
 if VERBOSE then
    say 'Disconnect'
 /***********************************/
 /* Call the HWTHDISC toolkit api.  */
 /***********************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthdisc ",
                 "ReturnCode ",
                 "ConnectionHandle ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthdisc', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthdisc failure **' )
    end /* endif hwthdisc failure */
 if VERBOSE then
    say 'Disconnect (hwthdisc) succeeded'
 return 0  /* end function */


/****************************************************************/
/* Function: HTTP_terminate                                     */
/*                                                              */
/* Release the designated Connection or Request handle via the  */
/* HWTHTERM toolkit api.                                        */
/*                                                              */
/* Returns:                                                     */
/* 0 if successful, -1 if not                                   */
/****************************************************************/
HTTP_terminate:

 handleIn = arg(1)
 forceOption = arg(2)
 if VERBOSE then
    say 'Terminate'
 /***********************************/
 /* Call the HWTHTERM toolkit api.  */
 /***********************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthterm ",
                 "ReturnCode ",
                 "handleIn ",
                 "forceOption ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthterm', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthterm failure **' )
    end  /* endif hwthterm failure */
 if VERBOSE then
    say 'Terminate (hwthterm) succeeded'
 return 0  /* end function */


/****************************************************************/
/* Function: HTTP_request                                       */
/*                                                              */
/* Make the configured Http request via the HWTHRQST toolkit    */
/* api.                                                         */
/*                                                              */
/* Returns: 0 if successful, -1 if not                          */
/****************************************************************/
HTTP_request:
 ReturnCode = -1
 DiagArea. = ''

 /***********************************/
 /* Call the HWTHRQST toolkit api.  */
 /***********************************/
 if VERBOSE then
    say 'Making HTTP Request'

 address hwthttp "hwthrqst ",
                 "ReturnCode ",
                 "ConnectionHandle ",
                 "RequestHandle ",
                 "HttpStatusCode ",
                 "HttpReasonCode ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthrqst', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthrqst failure **' )
    end  /* endif hwthrqst failure */
 /****************************************************************/
 /* The ReturnCode indicates merely whether the request was made */
 /* (and response received) without error.  The origin server's  */
 /* response, of course, is another matter.  The HttpStatusCode  */
 /* and HttpReasonCode record how the server responded.  Any     */
 /* header(s) and/or body included in that response are to be    */
 /* found in the variables which we established earlier.         */
 /****************************************************************/
 ResponseStatusCode = strip(HttpStatusCode,'L',0)
 ResponseReasonCode = strip(HttpReasonCode)
 return 0  /* end function */


/*************************************************************/
/* Function:  HTTP_setRequestHeaders                         */
/*                                                           */
/* Add appropriate Request Headers, by first building an     */
/* "SList", and then setting the HWTH_OPT_HTTPHEADERS        */
/* option of the Request with that list.                     */
/*                                                           */
/* Returns: 0 if successful, -1 if not                       */
/*************************************************************/
HTTP_setRequestHeaders:
 SList = ''
 acceptJsonHeader = 'Accept:application/json'
 acceptXMLHeader = 'Accept:application/xml'
 acceptLanguageHeader = 'Accept-Language: en-US'
 hostHeader = 'Host: api.geosvc.com'
 /**********************************************************************/
 /* Create a brand new SList and specify the first header to be an     */
 /* "Accept" header that requests that the server return any response  */
 /* body text in JSON format.                                          */
 /**********************************************************************/
 ReturnCode = -1
 DiagArea. = ''
 if VERBOSE then
    say 'Create new SList'
 address hwthttp "hwthslst ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_SLST_NEW ",
                 "SList ",
                 "acceptJsonHeader ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthslst (HWTH_SLST_NEW) failure **' )
    end  /* endif hwthslst failure */
 /***********************************************************/
 /* Append the Accept-Language request header to the SList  */
 /* to infer to the server the regional settings which are  */
 /* preferred by this application.                          */
 /***********************************************************/
 if VERBOSE then
    say 'Append to SList'
 address hwthttp "hwthslst ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_SLST_APPEND ",
                 "SList ",
                 "acceptLanguageHeader ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthslst (HWTH_SLST_APPEND) failure **' )
    end /* endif hwthslst failure */
 /***********************************************************/
 /* Append the Host request header to the SList             */
 /***********************************************************/
 if VERBOSE then
    say 'Append to SList'
 address hwthttp "hwthslst ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_SLST_APPEND ",
                 "SList ",
                 "hostHeader ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthslst (HWTH_SLST_APPEND) failure **' )
    end /* endif hwthslst failure */
 /************************************/
 /* Set the request headers with the */
 /* just-produced list               */
 /************************************/
 if VERBOSE then
    say '****** Set HWTH_OPT_HTTPHEADERS for request ******'
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_HTTPHEADERS ",
                 "SList ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_HTTPHEADERS) failure **' )
    end  /* endif hwthset failure */
 return 0  /* end function */


/*************************************************************/
/* Function:  HTTP_isError                                   */
/*                                                           */
/* Check the input processing codes. Note that if the input  */
/* RexxRC is nonzero, then the toolkit return code is moot   */
/* (the toolkit function was likely not even invoked). If    */
/* the toolkit return code is relevant, check it against the */
/* set of { HWTH_xx } return codes for evidence of error.    */
/* This set is ordered: HWTH_OK < HWTH_WARNING < ...         */
/* with remaining codes indicating error, so we may check    */
/* via single inequality.                                    */
/*                                                           */
/* Returns:  1 if any toolkit error is indicated, 0          */
/* otherwise.                                                */
/*************************************************************/
HTTP_isError:
 RexxRC = arg(1)
 if RexxRC <> 0 then
    return 1
 ToolkitRC = strip(arg(2),'L',0)
 if ToolkitRC == '' then
       return 0
 if ToolkitRC <= HWTH_WARNING then
       return 0
 return 1  /* end function */


/*************************************************************/
/* Function:  HTTP_isWarning                                 */
/*                                                           */
/* Check the input processing codes. Note that if the input  */
/* RexxRC is nonzero, then the toolkit return code is moot   */
/* (the toolkit function was likely not even invoked). If    */
/* the toolkit return code is relevant, check it against the */
/* specific HWTH_WARNING return code.                        */
/*                                                           */
/* Returns:  1 if toolkit rc HWTH_WARNING is indicated, 0    */
/* otherwise.                                                */
/*************************************************************/
HTTP_isWarning:
 RexxRC = arg(1)
 if RexxRC <> 0 then
    return 0
 ToolkitRC = strip(arg(2),'L',0)
 if ToolkitRC == '' then
    return 0
 if ToolkitRC <> HWTH_WARNING then
    return 0
 return 1 /* end function */


/***********************************************/
/* Procedure: HTTP_surfaceDiag()               */
/*                                             */
/* Surface input error information.  Note that */
/* when the RexxRC is nonzero, the ToolkitRC   */
/* and DiagArea content are moot and are       */
/* suppressed (so as to not mislead).          */
/***********************************************/
HTTP_surfaceDiag: procedure expose DiagArea.
  say
  say '*ERROR* ('||arg(1)||') at time: '||Time()
  say 'Rexx RC: '||arg(2)', Toolkit ReturnCode: '||arg(3)
  say 'DiagArea.Service: '||DiagArea.HWTH_service
  say 'DiagArea.ReasonCode: '||DiagArea.HWTH_reasonCode
  say 'DiagArea.ReasonDesc: '||DiagArea.HWTH_reasonDesc
  say
 return /* end procedure */


 /*****************************************************/
 /*            JSON-related functions                 */
 /*                                                   */
 /* These { JSON_xxx } functions are located together */
 /* for ease of reference and are used to demonstrate */
 /* how this portion of the Web Enablement Toolkit    */
 /* can be used in conjunction with the Http-related  */
 /* toolkit functions.                                */
 /*****************************************************/

 /**********************************************************/
 /* Function: JSON_initParser                              */
 /*                                                        */
 /* Initializes the global parserHandle variable via       */
 /* call to toolkit service HWTJINIT.                      */
 /*                                                        */
 /* Returns: 0 if successful, -1 if unsuccessful           */
 /**********************************************************/
JSON_initParser:
 if VERBOSE then
    say 'Initializing Json Parser'
 /***********************************/
 /* Call the HWTJINIT toolkit api.  */
 /***********************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwtjson "hwtjinit ",
                 "ReturnCode ",
                 "handleOut ",
                 "DiagArea."
 RexxRC = RC
 if JSON_isError(RexxRC,ReturnCode) then
    do
    call JSON_surfaceDiag 'hwtjinit', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwtjinit failure **' )
    end  /* endif hwtjinit failure */
 parserHandle = handleOut
 if VERBOSE then
    say 'Json Parser init (hwtjinit) succeeded'
 return 0  /* end function */


/**********************************************************************/
/* Function:  JSON_parse                                              */
/*                                                                    */
/* Parses the input text body (which should be syntactically correct  */
/* JSON text) via call to toolkit service HWTJPARS.                   */
/*                                                                    */
 /* Returns: 0 if successful, -1 if unsuccessful                      */
/**********************************************************************/
JSON_parse:
 jsonTextBody = arg(1)
  if VERBOSE then
    say 'Invoke Json Parser'
 /**************************************************/
 /* Call the HWTJPARS toolkit api.                 */
 /* Parse scans the input text body and creates an */
 /* internal representation of the JSON data,      */
 /* suitable for search and create operations.     */
 /**************************************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwtjson "hwtjpars ",
                 "ReturnCode ",
                 "parserHandle ",
                 "jsonTextBody ",
                 "DiagArea."
 RexxRC = RC
 if JSON_isError(RexxRC,ReturnCode) then
    do
    call JSON_surfaceDiag 'hwtjpars', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwtjpars failure **' )
    end  /* endif hwtjpars failure */
 if VERBOSE then
    say 'JSON data parsed successfully'
 return 0  /* end function */


/*******************************************************************/
/* Subroutine: JSON_searchAndDeserializeData                       */
/*                                                                 */
/* Search for specific values and objects in the parsed response   */
/* body, and deserialize them into the distanceData. stem variable */
/*                                                                 */
/*******************************************************************/
JSON_searchAndDeserializeData:
 distanceData. = ''
 /***************************************/
 /* Get Value (String) from root object */
 /***************************************/
 distanceValue = JSON_findValue( 0, "Value", HWTJ_NUMBER_TYPE )
 distanceData.distanceValue = distanceValue
 /***************************************/
 /* Get Units (String) from root object */
 /***************************************/
 unit = JSON_findValue( 0, "Unit", HWTJ_STRING_TYPE )
 distanceData.unit = unit
 say
 say 'The distance between 'sCity', 'sState', 'sCountry' and '
 say ' 'dCity', 'dState', 'dCountry' is 'distanceData.distanceValue
 say ' 'distanceData.unit'.'
 say
 return  /* end subroutine */


/******************************************************************/
/* Function:  JSON_findValue                                      */
/*                                                                */
/* Searches the appropriate portion of the parsed JSON data (that */
/* designated by the objectToSearch argument) for an entry whose  */
/* name matches the designated searchName argument.  Returns a    */
/* value or handle, depending on the expectedType.                */
/*                                                                */
/* Returns: value or handle as described above, or  a null result */
/* if no suitable value or handle is found.                       */
/******************************************************************/
JSON_findValue:
 objectToSearch = arg(1)
 searchName = arg(2)
 expectedType = arg(3)
/*********************************************************/
/* Trying to find a value for a null entry is perhaps a  */
/* bit nonsensical, but for completeness we include the  */
/* possibility.  We make an arbitrary choice on what to  */
/* return, and do this first, to avoid wasted processing */
/*********************************************************/
 if expectedType == HWTJ_NULL_TYPE then
    return '(null)'
 if VERBOSE then
    say 'Invoke Json Search'
 /********************************************************/
 /* Search the specified object for the specified name.  */
 /* The value 0 is specified (for the "startingHandle")  */
 /* to indicate that the search should start at the      */
 /* beginning of the designated object.                  */
 /********************************************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwtjson "hwtjsrch ",
                 "ReturnCode ",
                 "parserHandle ",
                 "HWTJ_SEARCHTYPE_OBJECT ",
                 "searchName ",
                 "objectToSearch ",
                 "0 ",
                 "searchResult ",
                 "DiagArea."
 RexxRC = RC
 /************************************************************/
 /* Differentiate a not found condition from an error, and   */
 /* tolerate the former.  Note the order dependency here,    */
 /* at least as the called routines are currently written.   */
 /************************************************************/
 if JSON_isNotFound(RexxRC,ReturnCode) then
    return '(not found)'
 if JSON_isError(RexxRC,ReturnCode) then
    do
    call JSON_surfaceDiag 'hwtjsrch', RexxRC, ReturnCode, DiagArea.
    say '** hwtjsrch failure **'
    return ''
    end /* endif hwtjsrch failed */
 /******************************************/
 /* Verify the type of the search result   */
 /******************************************/
 resultType = JSON_getType( searchResult )
 if resultType <> expectedType then
    do
    say '** Type mismatch ('||resultType||','||expectedType||') **'
    return ''
    end /* endif unexpected type */
 /******************************************************/
 /* Return the located object or array, as appropriate */
 /******************************************************/
 if expectedType == HWTJ_OBJECT_TYPE | expectedType == HWTJ_ARRAY_TYPE then
    do
    return searchResult
    end /* endif object or array type */
 /*******************************************************/
 /* Return the located string or number, as appropriate */
 /*******************************************************/
 if expectedType == HWTJ_STRING_TYPE | expectedType == HWTJ_NUMBER_TYPE then
    do
    if VERBOSE then
       say 'Invoke Json Get Value'
    ReturnCode = -1
    DiagArea. = ''
    address hwtjson "hwtjgval ",
                    "ReturnCode ",
                    "parserHandle ",
                    "searchResult ",
                    "result ",
                    "DiagArea."
    RexxRC = RC
    if JSON_isError(RexxRC,ReturnCode) then
       do
       call JSON_surfaceDiag 'hwtjgval', RexxRC, ReturnCode, DiagArea.
       say '** hwtjgval failure **'
       return ''
       end /* endif hwtjgval failed */
    return result
    end /* endif string or number type */
 /****************************************************/
 /* Return the located boolean value, as appropriate */
 /****************************************************/
  if expectedType == HWTJ_BOOLEAN_TYPE then
    do
    if VERBOSE then
       say 'Invoke Json Get Boolean Value'
    ReturnCode = -1
    DiagArea. = ''
    address hwtjson "hwtjgbov ",
                    "ReturnCode ",
                    "parserHandle ",
                    "searchResult ",
                    "result ",
                    "DiagArea."
    RexxRC = RC
    if JSON_isError(RexxRC,ReturnCode) then
       do
       call JSON_surfaceDiag 'hwtjgbov', RexxRC, ReturnCode, DiagArea.
       say '** hwtjgbov failure **'
       return ''
       end /* endif hwtjgbov failed */
    return result
    end /* endif boolean type */
 if VERBOSE then
    say '** No return value found **'
 return ''  /* end function */


/***********************************************************/
/* Function:  JSON_getType                                 */
/*                                                         */
/* Determine the Json type of the designated search result */
/* via the HWTJGJST toolkit api.                           */
/*                                                         */
/* Returns: Non-negative integral number indicating type   */
/* if successful, -1 if not.                               */
/***********************************************************/
JSON_getType:
 searchResult = arg(1)
 if VERBOSE then
    say 'Invoke Json Get Type'
 /*********************************/
 /* Call the HWTHGJST toolkit api */
 /*********************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwtjson "hwtjgjst ",
                 "ReturnCode ",
                 "parserHandle ",
                 "searchResult ",
                 "resultTypeName ",
                 "DiagArea."
 RexxRC = RC
 if JSON_isError(RexxRC,ReturnCode) then
    do
    call JSON_surfaceDiag 'hwtjgjst', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwtjgjst failure **' )
    end /* endif hwtjgjst failure */
 else
    do
    /******************************************************/
    /* Convert the returned type name into its equivalent */
    /* constant, and return that more convenient value.   */
    /* Note that the interpret instruction might more     */
    /* typically be used here, but the goal here is to    */
    /* familiarize the reader with these types.           */
    /******************************************************/
    type = strip(resultTypeName)
    if type == 'HWTJ_STRING_TYPE' then
       return HWTJ_STRING_TYPE
    if type == 'HWTJ_NUMBER_TYPE' then
       return HWTJ_NUMBER_TYPE
    if type == 'HWTJ_BOOLEAN_TYPE' then
       return HWTJ_BOOLEAN_TYPE
    if type == 'HWTJ_ARRAY_TYPE' then
       return HWTJ_ARRAY_TYPE
    if type == 'HWTJ_OBJECT_TYPE' then
       return HWTJ_OBJECT_TYPE
    if type == 'HWTJ_NULL_TYPE' then
       return HWTJ_NULL_TYPE
    end
 /***********************************************/
 /* This return should not occur, in practice.  */
 /***********************************************/
 return fatalError( 'Unsupported Type ('||type||') from hwtjgjst' )


/**********************************************************/
/* Function:  JSON_termParser                             */
/*                                                        */
/* Cleans up parser resources and invalidates the parser  */
/* instance handle, via call to the HWTJTERM toolkit api. */
/* Note that as the REXX environment is single-threaded,  */
/* no consideration of any "busy" outcome from the api is */
/* done (as it would be in other language environments).  */
/*                                                        */
/* Returns: 0 if successful, -1 if not.                   */
/**********************************************************/
JSON_termParser:
 if VERBOSE then
    say 'Terminate Json Parser'
 /**********************************/
 /* Call the HWTJTERM toolkit api  */
 /**********************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwtjson "hwtjterm ",
                 "ReturnCode ",
                 "parserHandle ",
                 "DiagArea."
 RexxRC = RC
 if JSON_isError(RexxRC,ReturnCode) then
    do
    call JSON_surfaceDiag 'hwtjterm', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwtjterm failure **' )
    end /* endif hwtjterm failure */
 if VERBOSE then
    say 'Json Parser terminated'
 return 0  /* end function */


/*************************************************************/
/* Function:  JSON_isNotFound                                */
/*                                                           */
/* Check the input processing codes. Note that if the input  */
/* RexxRC is nonzero, then the toolkit return code is moot   */
/* (the toolkit function was likely not even invoked). If    */
/* the toolkit return code is relevant, check it against the */
/* specific return code for a "not found" condition.         */
/*                                                           */
/* Returns:  1 if a HWTJ_JSRCH_SRCHSTR_NOT_FOUND condition   */
/* is indicated, 0 otherwise.                                */
/*************************************************************/
JSON_isNotFound:
 RexxRC = arg(1)
 if RexxRC <> 0 then
    return 0
 ToolkitRC = strip(arg(2),'L',0)
 if ToolkitRC == HWTJ_JSRCH_SRCHSTR_NOT_FOUND then
    return 1
 return 0  /* end function */


/*************************************************************/
/* Function:  JSON_isError                                   */
/*                                                           */
/* Check the input processing codes. Note that if the input  */
/* RexxRC is nonzero, then the toolkit return code is moot   */
/* (the toolkit function was likely not even invoked). If    */
/* the toolkit return code is relevant, check it against the */
/* set of { HWTJ_xx } return codes for evidence of error.    */
/* This set is ordered: HWTJ_OK < HWTJ_WARNING < ...         */
/* with remaining codes indicating error, so we may check    */
/* via single inequality.                                    */
/*                                                           */
/* Returns:  1 if any toolkit error is indicated, 0          */
/* otherwise.                                                */
/*************************************************************/
JSON_isError:
 RexxRC = arg(1)
 if RexxRC <> 0 then
    return 1
 ToolkitRC = strip(arg(2),'L',0)
 if ToolkitRC == '' then
       return 0
 if ToolkitRC <= HWTJ_WARNING then
       return 0
 return 1  /* end function */


/***********************************************/
/* Procedure: JSON_surfaceDiag                 */
/*                                             */
/* Surface input error information.  Note that */
/* when the RexxRC is nonzero, the ToolkitRC   */
/* and DiagArea content are moot and are       */
/* suppressed (so as to not mislead).          */
/*                                             */
/***********************************************/
JSON_surfaceDiag: procedure expose DiagArea.
  who = arg(1)
  RexxRC = arg(2)
  ToolkitRC = arg(3)
  say
  say '*ERROR* ('||who||') at time: '||Time()
  say 'Rexx RC: '||RexxRC||', Toolkit ReturnCode: '||ToolkitRC
  if RexxRC == 0 then
     do
     say 'DiagArea.ReasonCode: '||DiagArea.ReasonCode
     say 'DiagArea.ReasonDesc: '||DiagArea.ReasonDesc
     end
  say
 return  /* end procedure */


/***********************************************/
/* Function:  GetArgs                          */
/*                                             */
/* Parse script arguments and make appropriate */
/* variable assignments, or return fatal error */
/* code via usage() invocation.                */
/*                                             */
/* Returns: 0 if successful, -1 if not.        */
/***********************************************/
GetArgs:
 S = arg(1)
 argCount = words(S)
 if argCount == 0 | argCount < 3 | argCount > 4 then
    return usage( 'Wrong number of arguments' )

 do i = 1 to argCount
   localArg = word(S,i)
   select
     when (i == 1) then
       do
         apikey = localArg
       end
     when (i == 2) | (i == 3) then
       call parseLocation
     otherwise
       if localArg == '-v' then
         VERBOSE = 1
   end
 end
return 0  /* end function */

/***********************************************/
/* Function:  parseLocation                    */
/*                                             */
/* Parses one of the 2 location fields         */
/* Expects comma-delineated names              */
/*                                             */
/* Returns: 0 if successful, -1 if not.        */
/***********************************************/
parseLocation:

 UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
 lower = 'abcdefghijklmnopqrstuvwxyz'

 City = ''
 State = ''
 Country = ''

 parse value localArg with City ',' State ',' Country

 if i = 2 then
   do
     if (length(City)=0|length(State)=0|length(Country)<>2) then
       exit usage( '** Invalid start location **' )

     /* Make the start location all lower case */
     sCity = translate(City,lower,UPPER)
     sState = translate(State,lower,UPPER)
     sCountry = translate(Country,lower,UPPER)
   end
 else
   do
     if (length(City)=0|length(State)=0|length(Country)<>2) then
       exit usage( '** Invalid dest location **' )

     /* Make the dest location all lower case */
     dCity = translate(City,lower,UPPER)
     dState = translate(State,lower,UPPER)
     dCountry = translate(Country,lower,UPPER)
   end

return 0  /* end function */


/***********************************************/
/* Function: usage                             */
/*                                             */
/* Provide usage guidance to the invoker.      */
/*                                             */
/* Returns: -1 to indicate fatal script error. */
/***********************************************/
usage:
 whyString = arg(1)
 say
 say 'usage:'
 say 'ex RXEXEC1 <apikey> <start city,state,country>'
 say '<dest city,state,code> <optional -V for verbose>'
 say
 say '('||whyString||')'
 say
 return -1  /* end function */

/***********************************************/
/* Function:  fatalError                       */
/*                                             */
/* Surfaces the input message, and returns     */
/* a canonical failure code.                   */
/*                                             */
/* Returns: -1 to indicate fatal script error. */
/***********************************************/
 fatalError:
 errorMsg = arg(1)
 say errorMsg
 return -1  /* end function */

/***********************************************/
/* Function:  TurnOnVerboseOutput              */
/*                                             */
/* Allocates the trace dataset and sets the    */
/* output data set                             */
/***********************************************/
TurnOnVerboseOutput:
 /**********************************************************/
 say '****** Set HWTH_OPT_VERBOSE_OUTPUT for connection ******'
 traceDataSetName = 'REPLACE.ME'
 traceDD = 'MYTRACE'

 allocRc = allocateDsnToolkitTracefile(traceDataSetName,traceDD)

 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "ConnectionHandle ",
                 "HWTH_OPT_VERBOSE_OUTPUT ",
                 "traceDD",
                 "DiagArea."

 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_VERBOSE) failure **')
    end /* endif hwthset failure */

 say 'Trace output location: 'traceDataSetName
 return

 /*************************************************/
 /* Procedure:  allocateDsnToolkitTracefile       */
 /*                                               */
 /* Allocate a previously created trace data set  */
 /* with the required attributes (which           */
 /* must already exist), and a known DDname.      */
 /*************************************************/
 allocateDsnToolkitTracefile: procedure expose (PROC_GLOBALS)
  datasetName = arg(1)
  DDname = arg(2)

  /* allocates datasetName to DDName and directs messages */
  /* to z/OS UNIX standard error (sdterr)                 */
  alloc = 'alloc fi('||DDname||') '
  alloc = alloc||'da('||quoted(datasetName)||') old msg(2)'
  call bpxwdyn alloc
  allocRc = Result
  say 'BPXWDYN Result: '||allocRc

  return allocRc  /* end procedure */

 /***********************************************************/
 /* Procedure:  closeToolkitTrace                           */
 /*                                                         */
 /* Free the ddname which an earlier redirectToolkitTraceXX */
 /* caused allocation to associate with an HFS file.        */
 /***********************************************************/
 closeToolkitTrace: procedure expose (PROC_GLOBALS)
  DDname = arg(1)
  call bpxwdyn 'free fi('DDname')'
  return /* end procedure */

 /*******************************************************/
 /* Function:  quoted                                   */
 /*******************************************************/
 quoted:
  stringIn = arg(1)
 return "'"||stringIn||"'"
