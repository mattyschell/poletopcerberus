import sys
import dbutils
import itertools


class dossier(object):

    def __init__(self
                ,content):

        # content should be a list of text, one line each
        if type(content) is list:
            self.content = content
        else:
            raise ValueError('Input is not a list')

    @classmethod
    def fromText(cls
                ,text):

        # supports all line ending types
        return cls(text.splitlines())

    @classmethod
    def fromFile(cls
                ,fname):

        # open with no newline set translates all line endings to \n
        with open(fname) as f:
            incontent = f.readlines()

        return cls([x.strip() for x in incontent])

    def getDirt(self
               ,content):
        
        # expected test results should be input to getDirt as clean content
        # tests (self) may produce dirty dossiers
        
        dirt = []

        testlines = [i for i in self.content if i.startswith('POLETOPERROR')]
        expectedlines = [i for i in content if i.startswith('POLETOPERROR')]

        for testline, expectedline in itertools.izip_longest(testlines, 
                                                             expectedlines):

            if testline != expectedline:
                dirt.append('expected: {0}'.format(expectedline))
                dirt.append('test: {0}'.format(testline))
            else:
                # space reserved for debugging 
                pass                

        return dirt


def run_simple_test(dbhandle):

    # sloppy stuff bud
    print " "
    print "------ Expected POLETOPERRORS will print to the screen here ---------"
    print " "

    try:
        dbhandle.executescript('poletopcerberus.sql')
    except Exception as e:
        
        # expected

        # expected like <snip> 
        # DECLARE
        # *
        # ERROR at line 1:
        # ORA-20001:  
        # POLETOPERROR: reservation 15 changed franchisees  
        # POLETOPERROR: reservation 20 moved x and/or y (geometry)  
        # POLETOPERROR: reservation 25 moved x and/or y (geometry)  
        # POLETOPERROR: reservation 55 moved x and/or y (geometry)  
        # POLETOPERROR: reservation 30 moved x and/or y (data)  
        # POLETOPERROR: reservation 35 moved x and/or y (data)  
        # POLETOPERROR: reservation 55 moved x and/or y (data)  
        # POLETOPERROR: reservation 40 zombiefied, became active again  
        # POLETOPERROR: reservation 2 is suspect, lower ID than we have seen in the past 
        # ORA-06512: at line 111 
        
        testdossier = dossier.fromFile('poletopcerberus_output.txt')
        expecteddossier = dossier.fromFile('src/test/resources/test_expected.txt')
    
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

    else:

        print "failed to catch expected errors from poletopcerberus.sql"

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

    dbhandle.executescript('src/test/resources/teardowndb-oracle.sql')  