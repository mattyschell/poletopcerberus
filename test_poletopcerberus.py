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
        # tests (self) produce dirty dossiers
        
        dirt = []
        for testline, expectedline in itertools.izip_longest(self.content, 
                                                             content):
            if testline != expectedline:
                dirt.append('expected: {0}'.format(expectedline))
                dirt.append('test: {0}'.format(testline))
            else:
                # space reserved for debugging 
                pass                

        return dirt


def run_simple_test(dbhandle):

    testdossier = dossier.fromFile('src/test/resources/test_expected')
    expecteddossier = dossier.fromFile('src/test/resources/test_expected')
 
    dirtydossier = testdossier.getDirt(expecteddossier.content)

    if len(dirtydossier) > 0:
        print "failed comparing output to {0}".format('src/test/resources/test_expected')
        for dirtyline in dirtydossier:
            print "{0}{1}".format('   '
                                 ,dirtyline) 
    else:
        # fake pyunit
        print "{0}".format('.')


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