## Configuring a key ring

This section describes how to create a key ring in order to successfully connect with the Slack servers.

There are five steps required to correctly configure SAF for use by the Client Web Enablement Toolkit.

1. Download the certificate of the CA (Certificate Authority) used by Slack
1. Copy the certificate into the z/OS environment
1. Add the CA certificate into SAF as TRUSTed
1. Create a key ring for use by the Rexx exec
1. Connect the CA certificate with the key ring

The commands here assume the use of RACF: see your SAF documentation if an alternative is used.
All commands assume they are being executed under the userid that will execute the SLACK Rexx exec.

### Download the correct CA certificate

Determine the root CA (Certificate Authority) used by Slack and the certificate.
You can determine this by visiting the [Slack homepage](https://slack.com/) using your browser and
examining the CA certificate used.

At the time of writing, this is [DigiCert](https://www.digicert.com/) and the root CA certificate
in use has the name *DigiCert Global Root CA*.
You can download the certificate from the
[*DigiCert Trusted Root Authority Certificates*](https://www.digicert.com/digicert-root-certificates.htm) page.

Save this binary-encoded CRT file onto your workstation.

### Copy the certificate to the z/OS environment

FTP the CRT file from your workstation to a z/OS UNIX environment using **binary mode** transfer.

To validate the certificate in the z/OS UNIX environment, the following command will display the
certificate details.

```sh
openssl x509 -in DigiCertGlobalRootCA.crt -inform der -text -noout
```

Now copy this DER-encoded certificate to a sequential data set:

```sh
tso OGET "'DigiCertGlobalRootCA.crt' 'hlq.SLACK.CRT' BINARY"
```

### Add the CA certificate into SAF as TRUSTed

Add the certificate into SAF as a TRUSTed Certificate Authority:

```
RACDCERT ADD('hlq.SLACK.CRT') CERTAUTH TRUST WITHLABEL('DigiCert Global Root CA')
```

### Create a key ring for use by the Rexx exec

Define a SAF key ring named SLACK for the current user:

```
RACDCERT ADDRING(SLACK)
```

### Connect the CA certificate with the key ring

Connect the newly-added certificate with the new key ring:

```
RACDCERT CONNECT(CERTAUTH LABEL('DigiCert Global Root CA') RING(SLACK))
```
