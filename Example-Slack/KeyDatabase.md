## Configuring a key database file

This section describes how to create a key database file in order to successfully connect with the Slack servers.

The key database stores the certificate for the Certificate Authority (CA) used by Slack. The SSL implementation
references this database when determining if the target TLS server is trusted.

This database file does not store any private keys, therefore it is not necessary to protect it with a strong
password. The database should use file system permissions to prevent other users updating the database.

Database management is performed with the `gskkyman` utility. The documentation for this utility can be found in the
[z/OS Cryptographic Services](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.4.0/com.ibm.zos.v2r4.gska100/sssl2gsk1725369.htm)
section of the IBM Knowledge Center.

There are five steps required to correctly configure a database file for use by the Client Web Enablement Toolkit.

1. Download the certificate of the CA used by Slack
1. Copy the certificate to the z/OS UNIX System Services (USS) environment
1. Create a key database
1. Import the certificate into the key database
1. Create a password stash file

### Download the correct CA certificate

Determine the root CA used by Slack and the certificate.
You can determine this by visiting the [Slack homepage](https://slack.com/) using your browser and
examining the CA certificate used.

At the time of writing, this is [DigiCert](https://www.digicert.com/) and the root CA certificate
in use has the name *DigiCert Global Root CA*.
You can download the certificate from the
[*DigiCert Trusted Root Authority Certificates*](https://www.digicert.com/digicert-root-certificates.htm) page.

Download the certificate in PEM format.

### Copy the certificate to the z/OS USS environment

FTP the PEM file from your workstation to the z/OS USS environment using **ASCII mode** transfer.

To validate the certificate in the z/OS USS environment, the following command will display the
certificate details.

```sh
openssl x509 -in DigiCertGlobalRootCA.crt.pem -inform pem -text -noout
```

### Create a key database

Create a new key database using the `gskkyman` utility.

1. Run the `gskkyman` utility with no arguments.
1. From the **Database Menu** select option 1 - **Create new database**
1. Enter the name of your database (for example, `myKeyDb`)
1. Enter a password for the database
1. Specify no password expiration for the database
1. Use the default database record length
1. Do not use FIPS mode

This new database contains a list of default certificates. The certificates stored in the database can be
listed using option 2 - **Manage certificates** on the **Key Management Menu**.

### Add the CA certificate into the database

You now need to import the certificate for the CA into the database.

1. From the **Key Management Menu** select option 7 - **Import a certificate**
1. Specify the file name of the certificate (for example, `DigiCertGlobalRootCA.crt.pem`)
1. Specify the label of the CA certificate (for example, `DigiCert Global Root CA`)

If the process completed succesfully, then the message `Certificate imported.` is displayed.

### Create a password stash file

A stash file allows access to the database when it is not possible to manually enter the password.

1. From the **Key Management Menu** select option 10 - **Store database password**

The stash file is written to the same location as the key database file, with the extension `.sth`.
