import sys
import dbutils
import poletopcerberus


def run_simple_test(dbhandle):

    # sloppy stuff bud
    print " "
    print "------ Expected POLETOPERRORS will print to the screen here ---------"
    print " "

    try:
        dbhandle.executescript('poletopcerberus.sql')
    except:
        print "failed to write expected errors from poletopcerberus.sql"
  
    # POLETOPERROR: reservation 15 changed franchisees  
    # POLETOPERROR: reservation 20 moved x and/or y (geometry)  
    # POLETOPERROR: reservation 25 moved x and/or y (geometry)  
    # POLETOPERROR: reservation 55 moved x and/or y (geometry)  
    # POLETOPERROR: reservation 30 moved x and/or y (data)  
    # POLETOPERROR: reservation 35 moved x and/or y (data)  
    # POLETOPERROR: reservation 55 moved x and/or y (data)  
    # POLETOPERROR: reservation 40 zombiefied, became active again  
    # POLETOPERROR: reservation 2 is suspect, lower ID than we have seen in the past 
    
    testdossier = poletopcerberus.dossier.fromFile('poletopcerberus_output.txt')
    expecteddossier = poletopcerberus.dossier.fromFile('src/test/resources/test_expected.txt')

    dirtydossier = testdossier.getDirt(expecteddossier.content)
    print " " 
    print "------ {0}: Tests will print failed results here ----------------".format(sys.argv[0])
    
    if len(dirtydossier) > 0:
        print "failed comparing output to {0}".format('src/test/resources/test_expected.txt')
        for dirtyline in dirtydossier:
            print "{0}{1}".format('   '
                                 ,dirtyline) 
    else:
        # fake pyunit
        print "{0}".format('.')
    
    print "------ {0}: End of test results ---------------------------------".format(sys.argv[0])


if __name__ == "__main__":

    if len(sys.argv) != 4:
        msg = "I {0} request but 3 inputs, the scratch schema, password and database".format(sys.argv[0])
        msg += " Instead I have been given {0} inputs".format(len(sys.argv) - 1)                                                   
        print msg                                                                        
        raise ValueError(msg)

    ptestschema = sys.argv[1]   
    ptestpwd = sys.argv[2]
    ptestdb = sys.argv[3]

    dbhandle = dbutils.oracle(ptestschema
                             ,ptestdb
                             ,ptestpwd)

    dbhandle.executescript('src/main/resources/schema-oracle.sql')
    dbhandle.executescript('src/test/resources/data-oracle.sql')           

    run_simple_test(dbhandle)

    #dbhandle.executescript('src/test/resources/teardowndb-oracle.sql')  