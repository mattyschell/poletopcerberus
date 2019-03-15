import sys
import datetime
import mailer
import dbutils
import os
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
        
        # this is for testing 
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


def main(srcloginschema
        ,srcloginpassword
        ,srclogindb
        ,targetschema
        ,targetpassword
        ,targetdb):

    logstart = "Starting {0} at {1} {2}".format(sys.argv[0],
                                                str(datetime.datetime.now()),
                                                '\n\n')

    print logstart

    # a concise embarassment to god and country
    hardcodesourcescript = os.path.join('src'
                                       ,'main'
                                       ,'resources'
                                       ,'dump-reservationnow-data.sql')
    hardcodetargetscript = os.path.join('src'
                                       ,'main'
                                       ,'resources'
                                       ,'load-reservationnow-data.sql')
    hardcodeverifyscript = 'poletopcerberus.sql'
    hardcodedresults = 'poletopcerberus_output.txt'
    
    logstart += "Dumping {0}.reservation@{1} using {2}{3}".format('DOITT_PT'
                                                                  ,srclogindb
                                                                  ,hardcodesourcescript
                                                                  ,'\n\n')
    
    srcdbhandle = dbutils.oracle(srcloginschema
                                ,srclogindb
                                ,srcloginpassword)

    srcdbhandle.executescript(hardcodesourcescript)

    logstart += "Loading data into {0}.reservationnow on {1}{2}".format(targetschema
                                                                       ,targetdb
                                                                       ,'\n\n')
        
    targetdbhandle = dbutils.oracle(targetschema,
                                    targetdb,
                                    targetpassword)

    targetdbhandle.executescript(hardcodetargetscript)

    targetdbhandle.executescript(hardcodeverifyscript)

    dodgydossier = dossier.fromFile('poletopcerberus_output.txt')

    logprestart = 'This is a SUCCESS notification \n\n'
    logbody = ''

    for errorline in [i for i in dodgydossier.content if i.startswith('POLETOPERROR')]:
        logprestart = "This is a FAILURE notification \n\n" 
        logbody += str(errorline) + '\n'

    for ackline in [i for i in dodgydossier.content if i.startswith('POLETOPACKNOWLEDGED')]:
        logbody += str(ackline) + '\n'

    logbody = logprestart + logstart + logbody

    print "Full log text being returned to the caller: "
    print logbody

    return logbody


if __name__ == "__main__":

    if len(sys.argv) != 8:
        badinputs = 'Expected 7 inputs: ' + \
                    'sourceloginschema, sourceloginpassword, sourcelogindatabase, ' + \
                    'targetschema, targetpassword, targetdatabase, emails ' 
        raise ValueError(badinputs)

    psrcloginschema = sys.argv[1]       # doitt_pt_mtf (but always selects from doitt_pt)
    psrcloginpassword = sys.argv[2]     # iluvpoletop247
    psrclogindb = sys.argv[3]           # geocprd
    ptargetschema = sys.argv[4]         # doitt_pt_mtf (writes directly to target)
    ptargetpassword = sys.argv[5]       # iluvmtf247
    ptargetdb = sys.argv[6]             # geocdev
    ptomails = sys.argv[7]              # "mschell@doitt.nyc.gov;swim@doitt.nyc.gov"

    logtext = main(psrcloginschema
                  ,psrcloginpassword
                  ,psrclogindb
                  ,ptargetschema
                  ,ptargetpassword
                  ,ptargetdb)

    if logtext.startswith('This is a SUCCESS'):

        emailshout = 'Completed'

    else:

        emailshout = 'FAILED'

    logtext += "{0}Brought to you by your pals at gis-development@doitt.nyc.gov{1}".format('\n\n',
                                                                                           '\n\n')
    logtext += "additional info is at {0}".format('\n\n')
    logtext += "https://msdlva-gisprc01.csc.nycnet/projects/gis-support/wiki/ScheduledScripts {0}".format('\n\n')
    logtext += "you should go there some time {0}".format('\n\n')

    message = mailer.Message()
    message.From = "gis-development@doitt.nyc.gov"
    message.To = ptomails
    message.Subject = "Poletop QA {0}".format(emailshout)
    message.Body = logtext

    mailer = mailer.Mailer('doittsmtp.nycnet')
    mailer.send(message)