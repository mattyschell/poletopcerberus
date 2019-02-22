import sys
import datetime
import traceback
import mailer
import dbutils
import os


def main(srcdb,
         srcpassword,
         targetdb,
         targetpassword):

    logstart = "Starting {0} at {1} {2}".format(sys.argv[0],
                                                str(datetime.datetime.now()),
                                                '\n\n')


    print logstart

    # Next 10 lines are an embarassment to god and country.  But concise
    hardcodesourcescript = 'dump_mn_dcpinfo.sql'
    hardcodetargetscript = 'wc_sandy_gis_data.sql'
    hardcodeverifyscript = 'verify_wc_sandy_gis_data.sql'
    hardcodesourceschema = 'GEOCOMMON'
    hardcodetargetschema = 'SANDY_GIS'

    logstart += "Dumping {0}.mn_dcpinfo@{1} to {2}{3}".format(hardcodesourceschema,
                                                              srcdb,
                                                              hardcodesourcescript,
                                                              '\n\n')

    # so sqlplus can find scripts when the caller s
    dir_path = os.path.dirname(os.path.realpath(__file__))
    os.chdir(dir_path)

    try:




        srcdbhandle = dbutils.oracle(hardcodesourceschema,
                                     srcdb,
                                     srcpassword)

        srcdbhandle.executescript(hardcodesourcescript)

        logstart += "Loading data into SANDY.WC_SANDY_GIS_DATA on {0}{1}".format(targetdb,
                                                                                   '\n\n')
        targetdbhandle = dbutils.oracle(hardcodetargetschema,
                                        targetdb,
                                        targetpassword)

        targetdbhandle.executescript(hardcodetargetscript)

        targetdbhandle.executescript(hardcodeverifyscript)

    except Exception as e:
        logbody = "This is a FAILURE notification \n\n" + logstart
        logbody += str(traceback.format_exception(*sys.exc_info()))
    else:
        logbody = "This is a SUCCESS notification \n\n" + logstart
        logbody += "completed Loading data into SANDY.WC_SANDY_GIS_DATA@{0} at {1} {2} ".format(targetdb,
                                                                                                str(datetime.datetime.now()),
                                                                                                '\n\n')

    print "Full log text being returned to the caller: "
    print logbody

    return logbody

if __name__ == "__main__":

    if len(sys.argv) != 6:
        raise ValueError('Expected 5 inputs, sourcedatabase, sourcepassword, targetdb, targetpwd, emaillist')

    psrcdb = sys.argv[1]
    psrcpassword = sys.argv[2]
    ptargetdb = sys.argv[3]
    ptargetpassword = sys.argv[4]
    ptomails = sys.argv[5]         # "mschell@doitt.nyc.gov;swim@doitt.nyc.gov"

    logtext = main(psrcdb,
                   psrcpassword,
                   ptargetdb,
                   ptargetpassword)

    if logtext.startswith('This is a SUCCESS'):

        emailshout = 'Completed'

    else:

        emailshout = 'FAILED'

    logtext += "{0}Brought to you by gis-development@doitt.nyc.gov{1}".format('\n\n',
                                                                              '\n\n')
    logtext += "additional info at "
    logtext += "https://msdlva-gisprc01.csc.nycnet/projects/gis-support/wiki/ScheduledScripts {0}".format('\n\n')

    message = mailer.Message()
    message.From = "gis-development@doitt.nyc.gov"
    message.To = ptomails
    message.Subject = "Sandy Tracker ETL {0}".format(emailshout)
    message.Body = logtext

    mailer = mailer.Mailer('doittsmtp.nycnet')
    mailer.send(message)