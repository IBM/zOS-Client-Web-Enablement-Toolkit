## Example-Slack

## Overview

This sample illustrates how an application using the toolkit can leverage the Slack REST APIs to
post messages to a Slack channel.

This sample will perform the following steps:

1. Read an input data set
1. Connect to Slack
1. Construct a JSON message body for each record read from the input data set
1. POST the request to Slack



## Slack prep work

1. Obtain an OAuth token


## System prep work

1. Store slack.rexx and slack.jcl into data sets
1. OAuth token data set
1. Fetch the Slack SSL certificate and store on zFS


## Invocation

Run the program by simply submitting the RUNSLACK job.

The results of the program ....


## Security considerations

This application takes input from a sequential dataset and posts
it as a notification to a specific Slack channel.

Each record in the dataset is sent to Slack using their JSON API
with very little formatting taking place. Use the constants in
the program below to control the output.

Note that the ability to post to a Slack channel is all keyed
from a single URI provided to us by the admins of the IBM Z Slack
workspace. This is in the form of an OAuth token, which must be
kept secret. This token permits the ability to post any message
to any channel within the IBM Z Slack workspace.

This application is expected to run as a user which has READ
access to the OAuth token dataset. The only other user who should
be able to access this dataset should be the maintainer of this
utility.

Note that this script should also be stored in a location which
is read-only to most users. Making this Rexx script editable to
everyone would mean they could simply change the target channel
and use this script to post whatever they desire to any channel.

Final note on security is that enabling HTTP trace will write out
the URI (and hence the OAuth token) to the output. If trace is
required to debug an issue, don't forget to disable afterwards,
and make sure old job output is purged.
