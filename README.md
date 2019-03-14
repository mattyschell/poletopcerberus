## Poletop Cerberus

### Description

In late 2018 a legacy application appeared to exhibit unexpected behavior. From 
the perspective of a casual user this behavior looked like new reservations or 
existing reservations were changing state or exchanging details with an
unrelated reservation.  

We don't know what is causing this behavior, whether application, environment,
or user error.

The goal of the code in this repo is to, as pro-actively as possible, capture
such misbehavior as it happens and report the infractions to the business owner 
and support team (if one exists). 

This repository contains no real data from production or identifiers of actual 
data.  All data in the testing scripts is completely phony, as are 
authentication info in the examples below.


### Dependencies

* python (tested on 2.7)
* sqlplus and Oracle client
* access to source application data (best practice: a read-only account) 
* target oracle schema (different database is good) for stashing data and running tests


### Test 

`python test_poletopcerberus.py <testingschema> <testingschemapassword> <testingdatabase>`

example: 

`python test_poletopcerberus.py MSCHELL LarryEllisonIsMyDatabae GEOCDEV`


### Signature

`python poletopcerberus.py <source login schema> <source login password> <source login database> <target schema> <target password> <target database> <emails>`

example:

`python poletopcerberus.py doitt_pt_mtf iluvpoletop247 geocprd doitt_pt_mtf iluvnyc247 geocdev "mschell@doitt.nyc.gov;swim@doitt.nyc.gov"`


### Initial Setup

Execute src/main/resources/schema-oracle.sql in the target schema.  

Then either populate reservationsnapshot on the target manually, or run 
poletopcerberus.py once to initialize the target with current data.  It will 
perform no meaningful QA on this first run.


## Ongoing Maintenance

If we wish to acknowlege reported reservation changes we can insert the flagged
records `<targetschema>.reservationnow` into 
`<targetschema>.reservationack` and they will no longer generate reports.
