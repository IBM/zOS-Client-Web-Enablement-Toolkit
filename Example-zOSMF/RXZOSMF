//TKTxxx1 JOB 'IKJEFT01 REXX',CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID
//* LAB USERS:  Remember to change the xxx above to the last 3 chars
//* LAB USERS:  of your assigned userid in the JOBNAME.
//* LAB USERS:  For instance: SHAREC05 -> TKTC051 above for "TKTxxx1"
//* Copy the REXX exec below into a data set
//CREATE    EXEC  PGM=IEBGENER
//SYSIN     DD  DUMMY
//SYSPRINT  DD  SYSOUT=A,HOLD=YES
//SYSUT2    DD  DSN=&SYSUID..TEMPREX(REXTSO),DISP=(,PASS),
// SPACE=(CYL,(1,1,1)),UNIT=3390,
// DCB=(LRECL=80,RECFM=FB,DSORG=PO)
//SYSUT1    DD   *,DLM=##
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
/*---------------------------------------------------------------------*/
/*                                                                     */
/*  SCRIPT NAME=RXZOSMF1                                               */
/*                                                                     */
/*    DESCRIPTIVE NAME=Sample Rexx code to use HTTP services           */
/*                     in the z/OS Client Web Enablement Toolkit       */
/*                     to invoke various z/OSMF REST APIs              */
/*                                                                     */
/*  FUNCTION:                                                          */
/*  This sample invokes the z/OSMF REST API to submit a job to run     */
/*  a z/OS healthcheck on the system.  After the job is submitted, a   */
/*  second REST API is issued to check if the job completed            */
/*  successfully.  After this has been confirmed, the job output is    */
/*  retrieved from a data set using the z/OSMF data set REST API.      */
/*  Finally, if the z/OS healthcheck has failed, the z/OSMF            */
/*  notification REST API is invoked to send an email to warn them of  */
/*  the failure.                                                       */
/*                                                                     */
/*  This script provides sample calls to these HTTP Enabler            */
/*       services:                                                     */
/*    HWTHINIT - Initialize a connection or request instance.          */
/*    HWTHSET  - Set various connection or request options.            */
/*    HWTHCONN - Connect to a web server.                              */
/*    HWTHRQST - Make an HTTP request over an existing connection.     */
/*    HWTSLST  - Add HTTP headers to the request                       */
/*    HWTHDISC - Disconnect from a web server.                         */
/*    HWTHTERM - Terminate a connection or request instance.           */
/*                                                                     */
/*                                                                     */
/* INVOCATION:                                                         */
/*    This REXX must be submitted with a jobname prefixed with the     */
/*    letters TKTLAB.  This causes an AT-TLS policy to be activated to */
/*    automatically negotiate a TLS 1.2 handshake between this         */
/*    application and z/OSMF at the time of the toolkit Connect        */
/*    call (HWTHCONN).                                                 */
/*                                                                     */
/* DEPENDENCIES                                                        */
/*    The necessary security authorizations need to be set up to       */
/*    allow the user to submit a job, query the status of the job,     */
/*    retrieve the content of a dataset (including TSO/E authorization)*/
/*    and to notify the user via email.                                */
/*                                                                     */
/*    NOTES:                                                           */
/*                                                                     */
/*    No recovery logic has been supplied in this sample.              */
/*                                                                     */
/*    REFERENCE:                                                       */
/*        See the z/OS MVS Programming: Callable Services for          */
/*        High-Level Languages publication for more information        */
/*        regarding the usage of HTTP Enabler APIs.                    */
/*                                                                     */
/*        See the z/OS Management Facility (z/OSMF) Programming Guide  */
/*        for more information regarding the usage of the z/OSMF       */
/*        REST APIs.                                                   */
/*                                                                     */
/* Change Activity:                                                    */
/* $L0 xxxxxxxx HBB77B0 yyyyy PDSCW: z/OS Client Web Enablement        */
/*     Toolkit sample (HTTP) in REXX programming language              */
/*                                                                     */
/* END OF SPECIFICATIONS  * * * * * * * * * * * * * * * * * * * * * * **/

/* MAIN     */

VERBOSE = 1

/* Get Web Enablement Toolkit REXX constants */
 call HTTP_getToolkitConstants
 if RESULT <> 0 then
    exit fatalError( '** Environment error **' )

/* Indicate Program start  */
 say '************************************************'
 say '** HTTP Web Enablement Toolkit Sample (Begin) **'
 say '************************************************'

/* Initialize variables in program */
 call InitializeVars

 /* Obtain a connection handle  */
 call HTTP_init HWTH_HANDLETYPE_CONNECTION
 if RESULT <> 0 then
   call fatalError('** Connection could not be initialized **')

 /* Set the necessary options before connecting to the server  */
 call HTTP_setupConnection
 if RESULT <> 0 then
   cleanup('CON','** Connection failed to be set up **')

 /* Connect to the HTTP server  */
 call HTTP_connect
 if RESULT <> 0 then
   cleanup('CON','** Connection failed **')

 /* Obtain a request handle  */
 call HTTP_init HWTH_HANDLETYPE_HTTPREQUEST
 if RESULT <> 0 then
   cleanup('CON','** Request could not be initialized **')

 /* Set necessary request options before making submit jobs req */
 call HTTP_setupSubmitReq
 if RESULT <> 0 then
   cleanup('CONREQ','** Submit job request failed to be setup **')

 /* Make the z/OSMF submit job request */
 call HTTP_request
 if RESULT <> 0 then
   cleanup('CONREQ','** Submit job request failed **')

 /* Analyze the submit job output */
 if VERBOSE then
   say "response body: "||ResponseBody

 call parseZOSMFJobOutput
 if (jobStatusObtained = true) & (condcodeValue > 0) then
   cleanup('CONREQ','** Healthcheck job did not complete successfully **')

 /* The job status is still not known. Invoke job status REST API */
 call checkJobStatus

 /* Set necessary request options before making data set req */
 call HTTP_setupDataSetRetrieveReq
 if RESULT <> 0 then
   cleanup('CONREQ','** Data set retrieve req failed to be setup **')

 /* Make the z/OSMF data set retreive request */
 call HTTP_request
 if RESULT <> 0 then
   cleanup('CONREQ','** Data set retrieve request failed **')

 /* Parse the submit job output */
 if VERBOSE then
   say "response body: "||ResponseBody
 call parseZOSMFDataSetOutput
 if RESULT <> 0 then
   cleanup('CONREQ','** Data set output invalid **')

 /* Set necessary request options before making email req */
 call HTTP_setupEmailRequest
 if RESULT <> 0 then
   cleanup('CONREQ','** Email request failed to be setup **')

 /* Make the z/OSMF email request */
 call HTTP_request
 if RESULT <> 0 then
   cleanup('CONREQ','** Email request failed **')

 /* Email response body received */
 if VERBOSE then
   say "email response body: "||ResponseBody

 /* Cleanup the request and connection */
 programRc = 0
 cleanup('CONREQ','HTTP Web Enablement Toolkit Sample (Ends)')
 exit 0

/*******************************************************/
/* Function:  InitalizeVars                            */
/*                                                     */
/* Initialize global vars used throughout the program  */
/*******************************************************/
InitializeVars:

 programRc = -1

/* Initialize request-related variables  */
 ConnectionHandle = ''
 RequestHandle = ''

/* Initialize response-related variables  */
 HTTP_OK = 200
 HTTP_Created = 201
 HTTP_Accepted = 202
 StatCode = ''
 ResponseStatusCode = ''
 ResponseReason = ''
 ResponseHeaders. = ''
 ResponseBody = ''

 jobName = ''

 return

/*******************************************************/
/* Function:  cleanup                                  */
/*                                                     */
/* Cleanup a connection and possibly a request         */
/* depending on the parameters pasted in.              */
/*******************************************************/
cleanup:
 cleanupType = arg(1)
 errorMsg = arg(2)

 if cleanupType = 'CONREQ' then
   call HTTP_terminate RequestHandle, HWTH_NOFORCE

 /* Unconditionally release the connection handle  */
 call HTTP_terminate ConnectionHandle, HWTH_NOFORCE

 /* Say error message */
 say errorMsg
 /*
 call closeToolkitTrace traceDD
 */
exit programRC

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
    /* HWTH_OPT_VERBOSE_OUTPUT option).                              */
    /*****************************************************************/
    say '**** Set HWTH_OPT_VERBOSE for connection ****'
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

     Call TurnOnVerboseOutput

    end /* endif script invocation requested (-V) VERBOSE */

 /****************************************************************************/
 /* Set URI for connection to z/OSMF on the SHARE z/OS LPAR                  */
 /****************************************************************************/
 if VERBOSE then
    say '****** Set HWTH_OPT_URI for connection ******'
 ConnectionUri = 'https://mvs1.centers.ihost.com'
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
    say 'Issue Connect'
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
/* Function: HTTP_setupSubmitReq                            */
/*                                                          */
/* Sets the necessary request options.  The global variable */
/* RequestHandle orients the api as to the scope of the     */
/* option(s).                                               */
/*                                                          */
/* Returns: 0 if successful, -1 if not                      */
/************************************************************/
HTTP_setupSubmitReq:
 if VERBOSE then
    say '** Set HWTH_OPT_REQUESTMETHOD for request **'
 /**************************************************************/
 /* Set HTTP Request method.                                   */
 /* A ??? request method is used to modify a resource on server*/
 /**************************************************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_REQUESTMETHOD ",
                 "HWTH_HTTP_REQUEST_PUT ",
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
 requestPath = '/zosmf/restjobs/jobs'
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
/*****************************************************************/
/* Authenticating to z/OSMF                                      */
/*  Single sign-on uses HTTP basic authentication to fulfill the */
/*    request.  Set the authentication level to basic and        */
/*    specify userid and password                                */
/*****************************************************************/
userid = xxxxxxx
password = yyyyyyy
ReturnCode = setHTTPAuth(RequestHandle, userid, password, VERBOSE)

if ReturnCode = 0 then
  do
    /* Set the request body for the job to submit               */
    RequestBody = '{"file":"//''example.dataset(HLTHCHK)''"}'
    ReturnCode = setRequestBodyOptions(RequestHandle,VERBOSE)

    call setRequestBody

    if ReturnCode = 0 then
      /* Set the response headers and response body REXX variables */
      call setResponseHdrandBodyLocation
  end
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

/************************************************************/
/* checkJobStatus                                           */
/*                                                          */
/* Iterates up to 5 times to check if the job has completed */
/*                                                          */
/* Returns: job condition code                              */
/************************************************************/
 checkJobStatus:

 /* Set necessary request options before making job status req */
 call HTTP_setupJobStatusReq
 if RESULT <> 0 then
   cleanup('CONREQ','** Job status request failed to be setup **')

 do i = 1 to 99 while jobStatusObtained = false
   ResponseBody = ''

   /* Wait 0.25 seconds before retrying status request */
   call delay

   /* Make the z/OSMF job status request */
   call HTTP_request
   if RESULT <> 0 then
     cleanup('CONREQ','** Job status request failed **')

   /* Analyze the job status output */
   if VERBOSE then
     say "response body: "||ResponseBody

   call parseZOSMFJobOutput
   if (jobStatusObtained = true) & (condcodeValue > 0) then
     cleanup('CONREQ','** Healthcheck job did not complete successfully **')
 end /* do while */
 return 0

/************************************************************/
/* Function: HTTP_setupJobStatusReq                         */
/*                                                          */
/* Sets the necessary request options.  The global variable */
/* RequestHandle orients the api as to the scope of the     */
/* option(s).                                               */
/*                                                          */
/* Returns: 0 if successful, -1 if not                      */
/************************************************************/
HTTP_setupJobStatusReq:

 if VERBOSE then
    say '** Set HWTH_OPT_REQUESTMETHOD for request **'

 /* Set HTTP Request method.                                      */
 /* A GET request method is used to retrieve a resource on server */
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_REQUESTMETHOD ",
                 "HWTH_HTTP_REQUEST_GET ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError('hwthset (HWTH_OPT_REQUESTMETHOD) failure **' )
    end  /* endif hwthset failure */

/*  Set the request URI                                          */
 if VERBOSE then
    say'****** Set HWTH_OPT_URI for request ******'
 requestPath = '/zosmf/restjobs/jobs/'||jobname||'/'jobid

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
/*****************************************************************/
/* Authenticating to z/OSMF                                      */
/*  We are already signed-on by previous requests so there is no */
/*  need to specify security credentials here. Reset to off      */
/*****************************************************************/
call resetHTTPAuth

 /*************************************************************/
 /* Stem variable already set for receiving response headers  */
 /* Already set to convert ASCII response to EBCDIC           */
 /* Variable already set to receive response body             */
 /*************************************************************/
requestBody = ''

call HTTP_setRequestHeaders
if RESULT <> 0 then
  return fatalError( '** Unable to set Request Headers **' )

if VERBOSE then
  say 'Job status request setup successful'

return 0   /* end function */

/************************************************************/
/* Function: HTTP_setupDataSetRetrieveReq                   */
/*                                                          */
/* Sets the necessary request options.  The global variable */
/* RequestHandle orients the api as to the scope of the     */
/* option(s).                                               */
/*                                                          */
/* Returns: 0 if successful, -1 if not                      */
/************************************************************/
HTTP_setupDataSetRetrieveReq:
 if VERBOSE then
    say '** Set HWTH_OPT_REQUESTMETHOD for request **'
 /* Set HTTP Request method.                                      */
 /* A GET request method is used to retrieve a resource on server */
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_REQUESTMETHOD ",
                 "HWTH_HTTP_REQUEST_GET ",
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
 requestPath = '/zosmf/restfiles/ds/'||userid||'.HC.SYSOUT'

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
/*****************************************************************/
/* Authenticating to z/OSMF                                      */
/*  We are already signed-on by previous requests so there is no */
/*  need to specify security credentials here. Reset to off      */
/*****************************************************************/
call resetHTTPAuth

 /*************************************************************/
 /* Stem variable already set for receiving response headers  */
 /* Already set to convert ASCII response to EBCDIC           */
 /* Variable already set to receive response body             */
 /*************************************************************/
requestBody = ''

call HTTP_setRequestHeaders_nonJSON
if RESULT <> 0 then
  return fatalError( '** Unable to set Request Headers **' )

if VERBOSE then
  say 'Data Set retrieve request setup successful'
return 0   /* end function */


/************************************************************/
/* Function: HTTP_setupEmailRequest                         */
/*                                                          */
/* Sets the necessary request options.  The global variable */
/* RequestHandle orients the api as to the scope of the     */
/* option(s).                                               */
/*                                                          */
/* Returns: 0 if successful, -1 if not                      */
/************************************************************/
HTTP_setupEmailRequest:
 if VERBOSE then
    say '** Set HWTH_OPT_REQUESTMETHOD for request **'
 /**************************************************************/
 /* Set HTTP Request method.                                   */
 /* A PUT request method is used to modify a resource on server*/
 /**************************************************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_REQUESTMETHOD ",
                 "HWTH_HTTP_REQUEST_POST ",
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
 requestPath = '/zosmf/notifications/new'
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
/*****************************************************************/
/* Authenticating to z/OSMF                                      */
/*  We are already signed-on by previous requests so there is no */
/*  need to specify security credentials here. Reset to off      */
/*****************************************************************/
call resetHTTPAuth

 /*********************************************************/
 /* Set the variable for sending the request body         */
 /*********************************************************/
 RB= '{"subject":"HealthCheck Exception!",'
 RB=RB||'"content":"'||responseBody||'",'
 RB=RB||'"assignees":"xxxxxxx@yy.zzzzzzz",'
 RB=RB||'"sendTo":"mail"}'
 RequestBody = RB
 call setRequestBody
 /*************************************************************/
 /* Stem variable already set for receiving response headers  */
 /* Already set to convert ASCII response to EBCDIC           */
 /* Variable already set to receive response body             */
 /* Can reuse all the request headers sent earlier            */
 /*************************************************************/
if VERBOSE then
    say 'Email Request setup successful'
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
 if VERBOSE then
   say 'Making Http Request'
 ReturnCode = -1
 DiagArea. = ''
 /***********************************/
 /* Call the HWTHRQST toolkit api.  */
 /***********************************/
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
 StatCode = strip(HttpStatusCode,'L',0)
 ResponseReasonCode = strip(HttpReasonCode)
 if VERBOSE then
   do
     say 'Request completed'
     say 'HTTP Status Code: '||StatCode
     say 'HTTP Response Reason Code: '||ResponseReasonCode
   end

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
 acceptLanguageHeader = 'Accept-Language: en-US'
 contentTypeHeader = 'Content-Type: application/json'
 zOSMFHeader = 'X-CSRF-ZOSMF-HEADER: yes'
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
 /* Append the Content-Type request header to the SList     */
 /* to specify that the data sent on the put request is in  */
 /* JSON format                                             */
 /***********************************************************/
 if VERBOSE then
    say 'Append to SList'
 address hwthttp "hwthslst ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_SLST_APPEND ",
                 "SList ",
                 "contentTypeHeader ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthslst (HWTH_SLST_APPEND) failure **' )
    end /* endif hwthslst failure */
 /**************************************************************/
 /* Append the X-CSRF-ZOSMF-HEADER request header to the SList */
 /* to specify that this is a cross-site request               */
 /**************************************************************/
 if VERBOSE then
    say 'Append to SList'
 address hwthttp "hwthslst ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_SLST_APPEND ",
                 "SList ",
                 "zOSMFHeader ",
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
    say 'Set HWTH_OPT_HTTPHEADERS for request'
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
/* Function:  HTTP_setRequestHeaders_nonJSON                 */
/*                                                           */
/* Add appropriate Request Headers, by first building an     */
/* "SList", and then setting the HWTH_OPT_HTTPHEADERS        */
/* option of the Request with that list.                     */
/*                                                           */
/* Returns: 0 if successful, -1 if not                       */
/*************************************************************/
HTTP_setRequestHeaders_nonJSON:
 SList = ''
 acceptLanguageHeader = 'Accept-Language: en-US'
 zOSMFHeader = 'X-CSRF-ZOSMF-HEADER: yes'
 /**********************************************************************/
 /* Create a brand new SList and specify the first header to be an     */
 /* "AcceptLanguageHeader"                                             */
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
                 "acceptLanguageHeader ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthslst (HWTH_SLST_NEW) failure **' )
    end  /* endif hwthslst failure */
 /**************************************************************/
 /* Append the X-CSRF-ZOSMF-HEADER request header to the SList */
 /* to specify that this is a cross-site request               */
 /**************************************************************/
 if VERBOSE then
    say 'Append to SList'
 address hwthttp "hwthslst ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_SLST_APPEND ",
                 "SList ",
                 "zOSMFHeader ",
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
    say 'Set HWTH_OPT_HTTPHEADERS for request'
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
/* Sets the zFS UNIX file where the toolkit    */
/* trace will be written                       */
/***********************************************/
TurnOnVerboseOutput:
 /**********************************************************/
 say '**** Set HWTH_OPT_VERBOSE_OUTPUT for connection ****'
 traceDD = 'MYTRACE'
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "ConnectionHandle ",
                 "HWTH_OPT_VERBOSE_OUTPUT ",
                 "traceDD ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_VERBOSE) failure **' )
    end /* endif hwthset failure */
 return

 /***********************************************************/
 /* Procedure:  setHTTPAuth                                 */
 /*                                                         */
 /* Turn Basic Auth On                                      */
 /***********************************************************/
 setHTTPAuth: procedure expose DiagArea.

 parse arg RequestHandle, userName, Password, VERBOSE

 if VERBOSE then
    say'****** Set HWTH_OPT_HTTPAUTH for request ******'
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_HTTPAUTH ",
                 "HWTH_HTTPAUTH_BASIC ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_HTTPAUTH) failure **' )
    end  /* endif hwthset failure */

 /* Set username */
 if VERBOSE then
    say'****** Set HWTH_OPT_USERNAME for request ******'
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_USERNAME ",
                 "userName ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_USERNAME) failure **' )
    end  /* endif hwthset failure */

 /* Set password */
 if VERBOSE then
    say'****** Set HWTH_OPT_PASSWORD for request ******'
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_PASSWORD ",
                 "password ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_PASSWORD) failure **' )
    end  /* endif hwthset failure */

return 0

 /***********************************************************/
 /* Procedure:  resetHTTPAuth                               */
 /*                                                         */
 /* Turn Basic Auth Off                                     */
 /***********************************************************/
resetHTTPAuth:
 if VERBOSE then
    say'****** Turning Basic Auth Off ******'
 ReturnCode = -1
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_HTTPAUTH ",
                 "HWTH_HTTPAUTH_NONE ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_HTTPAUTH) failure **' )
    end  /* endif hwthset failure */

 /* Set username */
 if VERBOSE then
    say'****** Resetting USERNAME for request ******'
 ReturnCode = -1
 userName = ''
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_USERNAME ",
                 "userName ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_USERNAME) failure **' )
    end  /* endif hwthset failure */

 /* Set password */
 if VERBOSE then
    say'****** Resetting PASSWORD for request ******'
 ReturnCode = -1
 password = ''
 DiagArea. = ''
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_PASSWORD ",
                 "password ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_PASSWORD) failure **' )
    end  /* endif hwthset failure */

 return

/***********************************************************/
/* Procedure:  setRequestBodyOptions                       */
/*                                                         */
/* Set the necessary attributes to set the request body    */
/***********************************************************/
setRequestBodyOptions: procedure expose DiagArea.

parse arg RequestHandle,VERBOSE
 /*******************************************************************/
 /* Have the toolkit convert the request body from EBCDIC to ASCII */
 /*******************************************************************/
 ReturnCode = -1
 DiagArea. = ''
 if VERBOSE then
    say 'Set HWTH_OPT_TRANSLATE_REQBODY for request'
 address hwthttp "hwthset ",
                 "ReturnCode ",
                 "RequestHandle ",
                 "HWTH_OPT_TRANSLATE_REQBODY ",
                 "HWTH_XLATE_REQBODY_E2A ",
                 "DiagArea."
 RexxRC = RC
 if HTTP_isError(RexxRC,ReturnCode) then
    do
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwthset (HWTH_OPT_TRANSLATE_REQBODY) failure  **' )
    end /* endif hwthset failure */

return 0
 /***********************************************************/
 /* Procedure:  setResponseHdrandBodyLocation               */
 /*                                                         */
 /* Set the necessary attributes to set the request body    */
 /***********************************************************/
 setResponseHdrandBodyLocation:
 /*********************************************************/
 /* Set the stem variable for receiving response headers  */
 /*********************************************************/
 ReturnCode = -1
 DiagArea. = ''
 if VERBOSE then
    say 'Set HWTH_OPT_RESPONSEHDR_USERDATA for request'
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
    say 'Set HWTH_OPT_TRANSLATE_RESPBODY for request'
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
    say 'Set HWTH_OPT_RESPONSEBODY_USERDATA for request'
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

 return 0
 /***********************************************************/
 /* Procedure:  setRequestBody                              */
 /*                                                         */
 /* Set the request body                                    */
 /***********************************************************/
 setRequestBody:
    /*********************************************************/
    /* Set the variable for sending the request body         */
    /* Need to set RequestBody in mainline due to scoping    */
    /* issues                                                */
    /*********************************************************/
    if VERBOSE then
      Say "RequestBody:"||RequestBody
      ReturnCode = -1
      DiagArea. = ''
      if VERBOSE then
         say 'Set HWTH_OPT_REQUESTBODY for request'
      address hwthttp "hwthset ",
                      "ReturnCode ",
                      "RequestHandle ",
                      "HWTH_OPT_REQUESTBODY ",
                      "RequestBody ",
                      "DiagArea."
      RexxRC = RC
      if HTTP_isError(RexxRC,ReturnCode) then
         do
         call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.
         return fatalError( '** hwthset (HWTH_OPT_REQUESTBODY) failure **')
         end /* endif hwthset failure */
 return
 /***********************************************************/
 /* parseZOSMFJobOutput                                     */
 /*                                                         */
 /* Verify that the job completed successfully.             */
 /***********************************************************/
parseZOSMFJobOutput:
 parserHandle = ''

 /* Obtain a JSON Parser instance.  */
 call JSON_initParser
 if RESULT <> 0 then
    return fatalError( '** Pre-processing error (parser init failure) **' )

 /* Parse the JSON string    */
 call JSON_Parse responseBody
 if RESULT <> 0 then
    return fatalError( '** Parsing error (parser failure) **' )

 /* Parse the job results.   */

 /* Get jobname and jobid so that we can check status later if
    necessary */
 call searchForJobInfo
 if RESULT <> 0 then
    return fatalError( '** Unable to extract jobname or jobid **' )

 jobStatusObtained = false
 condCodeValue = searchForCondCode()
 /* No need to obtain the status of the job.  We already have it */
 if (condCodeValue <> 9999) & (condCodeValue <> -1) then
   do
     jobStatusObtained = true
     if VERBOSE then
       say 'Job condition code:'||condCodeValue
   end

 call JSON_termParser
 return 0  /* end function */

 /***********************************************************/
 /* searchForJobInfo                                        */
 /*                                                         */
 /* Extract the jobname and jobid info                      */
 /***********************************************************/
searchForJobInfo:

 /* Extract jobname */
 jobname=''
 jobname = JSON_findValue( 0, "jobname", HWTJ_STRING_TYPE )

 if jobname = '' then
   return fatalError('** Unable to find returned jobname **')

 if VERBOSE then
   say 'Extracted jobname: '||jobname

 /* Extract jobid */
 jobid=''
 jobid = JSON_findValue( 0, "jobid", HWTJ_STRING_TYPE )

 if jobid = '' then
   return fatalError('** Unable to find returned jobname **')

 if VERBOSE then
   say 'Extracted jobid: '||jobid

 return 0  /* end function */

 /***********************************************************/
 /* searchForCondCode                                       */
 /*                                                         */
 /* Verify that the job completed successfully.             */
 /***********************************************************/
searchForCondCode:

 /* The return-code name contains the outcome of the job */
 condCode=''
 condCode = JSON_findValue( 0, "retcode", HWTJ_STRING_TYPE )

 /* If the condition code is the value "null", then it means that the
    job has not completed yet.  Attempt to pull status of job again  */
 if condCode = '' then
   do
     say '** Job execute not completed **'
     return 9999
   end

 /* Get the value for condcode         */
 connCodeValue = -1
 parse value condCode with 'CC 'condCodeValue
 if condCodeValue = -1 then
   return fatalError('** Unable to find Condition Code for Job **')

 if condCodeValue = '0000' then
   condCodeValue = 0
 else
   strip(condCodeValue,'L',0)

 return condCodeValue  /* end function */

 /***********************************************************/
 /* parseZOSMFDataSetOutput                                 */
 /*                                                         */
 /* Find the status of the z/OS healthcheck                 */
 /***********************************************************/
parseZOSMFDataSetOutput:
 parse value responseBody with 'STATUS: 'statusValue'-'restOfData

 if VERBOSE then
   say "HealthCheck Status Value :"||statusValue

 if statusValue <> 'EXCEPTION' then
   return -1

 return 0  /* end function */

 /***********************************************************/
 /* parseZOSMFDataSetOutput                                 */
 /*                                                         */
 /* Find the status of the z/OS healthcheck                 */
 /***********************************************************/
parseZOSMFDataSetOutput:
 parse value responseBody with 'STATUS: 'statusValue'-'restOfData

 if VERBOSE then
   say "HealthCheck Status Value :"||statusValue

 if statusValue <> 'EXCEPTION' then
   return -1

 return 0  /* end function */

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

/***********************************************************/
/* Function:  JSON_getNumberElem                           */
/*                                                         */
/* Determine the number of elments contained in the input  */
/* JSON handle via the HWTJGNUE service                    */
/*                                                         */
/* Returns: Non-negative number indicating number          */
/* if successful, -1 if not.                               */
/***********************************************************/
JSON_getNumberElem:
 inputHandle = arg(1)

 /***********************************/
 /* Call the HWTJGNUE toolkit api.  */
 /***********************************/
 ReturnCode = -1
 DiagArea. = ''
 objDim = 0
 address hwtjson "hwtjgnue ",
                 "ReturnCode ",
                 "parserHandle ",
                 "inputHandle ",
                 "dimOut ",
                 "DiagArea."
 RexxRC = RC
 if JSON_isError(RexxRC,ReturnCode) then
    do
    call JSON_surfaceDiag 'hwtjgnue', RexxRC, ReturnCode, DiagArea.
    return fatalError( '** hwtjgnue failure **' )
    end /* endif hwtjgnue failure */
 objDim = strip(dimOut,'L',0)
 if objDim == '' then
    return 0
 return objDim  /* end function */

/*************************************************/
/* Function:  JSON_getArrayEntry                 */
/*                                              */
/* Return a handle to the designated entry of   */
/* the array designated by the input handle,    */
/* obtained via the HWTJGAEN toolkit api.       */
/*                                              */
/* Returns: Output handle from toolkit api if   */
/* successful, empty result if not.             */
/************************************************/
JSON_getArrayEntry:
 arrayHandle = arg(1)
 whichEntry = arg(2)
 result = ''
 if VERBOSE then
    say 'Getting array entry'
 /***********************************/
 /* Call the HWTJGAEN toolkit api.  */
 /***********************************/
 ReturnCode = -1
 DiagArea. = ''
 address hwtjson "hwtjgaen ",
                 "ReturnCode ",
                 "parserHandle ",
                 "arrayHandle ",
                 "whichEntry ",
                 "handleOut ",
                 "DiagArea."
 RexxRC = RC
 if JSON_isError(RexxRC,ReturnCode) then
    do
    call JSON_surfaceDiag 'hwtjgaen', RexxRC, ReturnCode, DiagArea.
    say '** hwtjgaen failure **'
    end /* endif hwtjgaen failure */
 else
    result = handleOut
 return result  /* end function */

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
/* Procedure: JSON_decode                      */
/*                                             */
/* Decode the encoded JSON for printing        */
/***********************************************/
JSON_decode: procedure expose DiagArea. decodedJSON
  parse arg encodedJSON

  ReturnCode = -1
  RequestType = HWTJ_DECODE
  decodedJSON = ''
  DiagArea. = ''
  address hwtjson "hwtjesct ",
                  "ReturnCode ",
                  "RequestType ",
                  "encodedJSON ",
                  "decodedJSON ",
                  "DiagArea."

 return  /* end procedure */
 /*******************************************************/
 /* Function:  quoted                                   */
 /*******************************************************/
 quoted:
  stringIn = arg(1)
 return "'"||stringIn||"'"
 /*******************************************************/
 /* Function:  delay                                    */
 /*******************************************************/
 delay:
  /* Rexx Delay */
  DelaySec = 0.250000 /* readable width */
  elapsed = TIME(R)
  do until elapsed >= DelaySec
  elapsed = TIME('E')
  end
 return
##
//* Execute the REXX exec under a TSO environment
//RUN       EXEC PGM=IKJEFT01,PARM='REXTSO'
//MYTRACE   DD PATH='/sharelab/sharxxx/sharxxx.trace'
//SYSEXEC   DD DSN=&SYSUID..TEMPREX,DISP=(SHR,PASS)
//SYSTSPRT  DD SYSOUT=A,HOLD=YES
//SYSTSIN   DD DUMMY
//* Delete the temp dataset when we are done
//DELETE    EXEC PGM=IEFBR14
//SYSPRINT  DD SYSOUT=*
//MYDSN     DD DSN=&SYSUID..TEMPREX,DISP=(OLD,DELETE,DELETE)
//
