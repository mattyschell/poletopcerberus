## Poletop Cerberus

### Description

In late 2018 the legacy poletop application appeared to exhibit inexplicable and
very troubling buggy behavior.  Usually from the user perspective this meant 
something like creating a new reservation and having the entered reservation 
details being applied to an existing, unrelated reservation.

The goal of the code in this repo is to, as pro-actively as possible, capture
such misbehavior as it happens and report the infractions to the poletop 
support team (if one still exists). 


### Dependencies

* python
* sqlplus and Oracle client
* access to source poletop reservation data (best not to log in directly to prod) 
* target oracle schema (different database is fine) for writing reservation data and running tests


### Test

`python test_poletopcerberus.py <testingschema> <testingschemapassword> <testingdatabase>`

example: 

`python test_poletopcerberus.py MSCHELL LarryEllisonIsMyDatabae GEOCDEV`


### Signature

`python poletopcerberus.py <source login schema> <source login password> <source login database> <target schema> <target password> <target database> <emails>`

example:

`python poletopcerberus.py doitt_pt_mtf iluvpoletop247 geocprd doitt_pt_mtf iluvmtf247 geocdev "mschell@doitt.nyc.gov;swim@doitt.nyc.gov"`


### Initial Setup

Either populate reservationsnapshot on the target manually, or run 
poletopcerberus.py once to initialize the target with current data.  It will 
perform no meaningful QA on this first run.


## Ongoing Maintenance

If we wish to acknowlege reported reservation changes we can insert the bad
reservations from `<targetschema>.reservationnow` into 
`<targetschema>.reservationack` and they will no longer generate reports.



