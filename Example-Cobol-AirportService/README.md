## Example-Cobol-AirportService
Airport Info is a published REST API that allows applications to pull descriptive information about an airport. The input is a three character IATA code which represents the airport.

Example: http://www.airport-data.com/api/ap_info.json?iata=LAX

This example is based upon the Cobol code distributed with the Toolkit in SYS1.SAMPLIB. The SAMPLIB version invokes an FAA service that is no longer available.



## Prep work

Insure that the service host and port 80 is available to the z/OS system running the example. Recommend that you try to invoke the API using cURL (if it's available.) The API should return something like:

{"icao":"KLAX","iata":"LAX","name":"Los Angeles International Airport","location":"Los Angeles, CA","country":"United States","country_code":"US","longitude":"-118.408068","latitude":"33.942495","link":"http:\/\/www.airport-data.com\/airport\/LAX\/","status":200} 

## What to do if you can't get z/OS to hit http://www.airport-data.com:80

Tiny Server is a freeware web server that runs in Windows and serves files. Install Tiny Server, then create a file named index.htm in C:\Program Files (x86)\Tiny Server. Cut and paste the JSON response string in to the file. Look through the example code and uncomment the lines that will direct the API to an IP address of your choosing.
