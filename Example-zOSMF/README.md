## Example-zOSMF

## Overview ##
z/OS Management Facility, z/OSMF, provides a rich set of [REST APIs](https://ibm.biz/BdYXHX) that allow your application to perform many different types of tasks including working with jobs, data sets, provisioning z/OS Middleware, Notification services, TSO/E functions, z/OS Console and much, much more.   

Imagine that your shop would like a certain job on a remote system to be run on a regular basis.  If the resulting job output shows a problem, then you also want to email the output information to the appropriate person so they can address the issue.

This sample illustrates how an application, using the toolkit, can leverage some of the REST APIs listed above, to implement this scenario.

The sample will perform the following steps:
1. Submit a simple z/OS healthcheck job, `HLTHCHK`, using [z/OSMF Submit job REST API](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_API_PutSubmitJob.htm)
2. Check the status of the job to make sure it has completed successfully, using [z/OSMF job status retrieval REST API](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_API_GetJobStatus.htm)
3. If the job completed successfully, it will retrieve the output written to a data set, using [z/OSMF data set retrieval REST API](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_API_GetReadDataSet.htm)
4. It will then analyze the output.  If the healthcheck failed in any way, then it will send the output to an email address, using [z/OSMF notification REST API](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_API_NOTIFICATIONS.htm)


## System Prep work
This sample requires the following
-  A userid on an active z/OSMF server that has permission to issue the following z/OSMF REST services
    - [z/OSMF Submit job](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_API_RESTJOBS.htm)
    - [z/OSMF data set retrieval](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_API_RESTFILES.htm)
    - [z/OSMF notification](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.izua700/IZUHPINFO_API_NOTIFICATIONS.htm)


- The z/OSMF REST Services require an HTTPS connection, this sample assumes there is an [AT-TLS Policy](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.ieac100/attlstoolkit.htm) in place to handle this requirement. This [AT-TLS Policy](ATTLSPolicy) allows for communication with the z/OSMF server for jobs prefixed with the letters `TKT`.

- Store `RXZOSMF` and `HLTHCHK` into datasets

## RXZOSMF Prep work
- This sample is designed to be a REXX program run as a batch job. Update the job name, `TKTxxx1`, to something more appropriate. Keep in mind, the AT-TLS policy definition and if it applies to a specific job prefix

- Update `userid` and `password` with valid credentials for an active z/OSMF server referenced above.
    ```
    userid = xxxxxxx
    password = yyyyyyy
    ```

- Update `example.dataset(HLTHCHK)` with the location of your `HLTHCK` job. Don't remove any of the quotes or you will likely get a REXX syntax error.  

- Next, update the location of a zFS file where the trace output will be directed to. This samples is setup to generate verbose output, [`HWTH_OPT_VERBOSE`](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.ieac100/ieac1-cwe-http-options.htm), and direct it to a location pointed to by the `MYTRACE` DD name, [`HWTH_OPT_VERBOSE_OUTPUT`](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.ieac100/ieac1-cwe-http-options.htm). The `MYTRACE` DD is defined at the bottom of the sample. Replace `/sharelab/sharxxx/sharxxx.trace` with your desired zFS location.

- Lastly, replace `xxxxxxx@yy.zzzzzzz` with a valid email address that the job failure notification should be sent to.

## Invocation
Run the program by simply submitting the RXZOSMF member.

The results of the program are split up between two locations
  - The output of the program is contained in SDSF. Depending on your system, you can go into option 13.14 from the main ISPF menu and then select the H option.  You can sort on jobs with your jobname prefix or owned by your  userid.  For example, if your jobname is TKTLAB01, you can type prefix TKTLAB01.

  - The trace output is at the location pointed to by `MYTRACE` DD. For example, if you had update the value of `MYTRACE` to `/sharelab/shara01/shara01.trace` then if you `cd` into `/sharelab/shara01` directory you should now see the `shara01.trace` file.

In addition, if the `HLTHCHK` failed, as it is expected to, the email address you specified should have received an email with **HealthCheck Exception!** as the subject line.
