## Poletop Cerberus

### Description

In late 2018 the legacy poletop application appeared to exhibit inexplicable and
very troubling buggy behavior.  Usually from the user perspective this meant 
something like creating a new reservation and having the entered reservation 
details being applied to an existing, unrelated reservation.

The goal of the code in this repo is to, as pro-actively as possible, capture
such misbehavior as it happens and report the infractions to the poletop 
support team (if one exists). 

### Dependencies


### Signature

`poletopcerberus.py <source login schema> <source login password> <source login database> <target schema> <target password> <target database> <emails>`

example:

`poletopcerberus.py <doitt_pt_mtf> <iluvpoletop247> <geocprd> <doitt_pt_mtf> <iluvmtf247> <geocdev> <mschell@doitt.nyc.gov;swim@doitt.nyc.gov>`
