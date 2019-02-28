import sys
import datetime
import traceback
import mailer
import dbutils
import os


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

    # so sqlplus can find scripts when the callers
    # dir_path = os.path.dirname(os.path.realpath(__file__))N
    # os.chdir(dir_path)

    try:

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

    except Exception as e:
        logbody = "This is a FAILURE notification \n\n" + logstart
        #logbody += str(traceback.format_exception(*sys.exc_info()))
        with open(hardcodedresults) as f:
            errorlines = f.readlines()
            #testlines = [i for i in self.content if i.startswith('POLETOPERROR')]
        for errorline in [i for i in errorlines if i.startswith('POLETOPERROR')]:
            logbody += str(errorline)
    else:
        logbody = "This is a SUCCESS notification \n\n" + logstart

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