## Example-Slack

## Overview

This sample illustrates how an application using the toolkit can leverage the Slack REST APIs to
post messages to a Slack channel.

This sample will perform the following steps:

1. Read input from a sequential data set
1. Connect to Slack
1. Construct a JSON message body for each record read from the input data set
1. POST the request to Slack

Each record in the dataset is sent to Slack using the JSON webhook API with very little formatting
taking place.


## Slack prep work

Create an Incoming Webhook - see the [Slack documentation](https://api.slack.com/messaging/webhooks)
for more details.

This will provide you with an OAuth token which looks something like this:

```
/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```


## System prep work

1. Create four data sets for the application
   * hlq.SLACK.REXX - DSORG=PO,RECFM=FB,LRECL=80 - used to store the Rexx script
   * hlq.SLACK.JCL - DSORG=PO,RECFM=FB,LRECL=80 - used to hold the JCL for invoking the Rexx script
   * hlq.SLACK.MESSAGES - DSORG=PS,RECFM=FB,LRECL=300 - used to hold the messages to send to Slack
   * hlq.SLACK.OAUTH - DSORG=PS,RECFM=FB,LRECL=80 - used to store the secret OAuth token
1. Store slack.rexx into hlq.SLACK.REXX and customize values in the *Application constants* section
for your environment
1. Store slack.jcl into hlq.SLACK.JCL and customize for your environment
1. Store the OAuth token from the Slack prep step above in hlq.SLACK.OAUTH
1. Setup a [SAF key ring](KeyRing.md) connected to the Slack CA's certificate, or a
[key database file](KeyDatabase.md) containing the Slack CA's certificate


## Invocation

Ensure there is at least one record in the hlq.SLACK.MESSAGES data set.

Run the program by submitting the SLACK job in the hlq.SLACK.JCL data set.


## Security considerations

Note that the ability to post to a Slack channel is all keyed from a single URI provided to us by
the admins of the Slack workspace.
This is in the form of an OAuth token, which must be kept secret.
This token permits the ability to post any message to any channel within the Slack workspace.

This application is expected to run as a user which has READ access to the OAuth token dataset.
The only other user who should be able to access this dataset should be the maintainer of this utility.

Note that this script should also be stored in a location which is read-only to most users.
Making this Rexx script editable to everyone would mean they could simply change the target channel and
use this script to post whatever they desire to any channel.

Final note on security is that enabling HTTP trace will write out the URI (and hence the OAuth token)
to the output.
If trace is required to debug an issue, don't forget to disable afterwards, and make sure old job
output is purged.
