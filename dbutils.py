# Created on Jul 16, 2015
# mschell
from subprocess import Popen, PIPE


class oracle:
    
    # This is the connection class
    
    # simple usage
    # myconn = dbutils.oracle('MSCHELL','GEOCDEV','ILuvDoitt')
    # myconn.connect()
    # myconn.executecommand('select * from dual;')
    # thats all, work is done and connection is closed
    # use executescript method to execute a script on disk
    # use executestatement method for multiple commands
    # errors raise RuntimeError

    def __init__(self,
                 schema,
                 database,
                 password = None, 
                 domain = ".DOITT.NYCNET",
                 dbuglevel = 0):
        
        if not schema:
            raise ValueError("Missing schema")

        if not database:
            raise ValueError("Missing database")
        
        self.schema = schema
        self.database = database
        
        self.setpassword(password)
        
        self.domain = domain
        self.dbuglevel = dbuglevel
        
        self.connectionopen = False

    def setpassword(self,
                    password = None):
        
        if password is not None:
            self.password = password
        
        else:
            
            import getpass
            import sys
        
            msg = 'Feed me password for ' + self.schema + ' on ' + self.database + ':'
            pw = getpass.getpass(prompt=msg, stream=sys.stderr)
            self.password = pw.rstrip()
        
    def getpassword(self):
        
        return self.password

    def connect(self):
        
        if self.connectionopen == False:
        
            safe_str = "sqlplus " + self.schema + "@" + self.database \
                     + self.domain + "/" + "<password>"
        
            if self.dbuglevel > 0:
                print "   Executing " + safe_str + "\n" 
            
            connectstr = self.schema + "@" + self.database \
                       + self.domain + "/" + self.password
                       
            try:
                session = Popen(['sqlplus', connectstr], bufsize=1, universal_newlines=True, \
                                stdin=PIPE, stdout=PIPE, stderr=PIPE)
                self.session = session
                self.connectionopen = True
            except:
                print "Total failure to call sqlplus"
                print "like " + safe_str
                print "Is it installed and is your oracle home set up?"
                raise RuntimeError("Raising Total Failure to Call SQLPlus")
            
        else:
            raise RuntimeError("This connection is already open")
        
        if self.dbuglevel > 0:
            print "Successful connection"

    def finish(self,
               command = None):
        
        if self.connectionopen == False:
            raise RuntimeError("No open connection to finish")
        
        result, errormsg = self.session.communicate()
        self.connectionopen = False 
        
        if self.dbuglevel > 0:
            print "++++++++++SQL Plus output+++++++++++"
            print "STDOUT: "
            print result
            print "STDERR: "
            print errormsg
            print "++++++++++++++++++++++++++++++++++++"
        
        
        # sqlplus threw an error, not sure how to hit this actually
        # just in case...
        if errormsg:
            print "Got a total bomb from sqlplus"
            print "Heres the error: "
            print errormsg
            print "Heres the screen output: "
            print result
            raise RuntimeError('SQLPlus failed with ' + errormsg) 
              
        # sqlplus returned but there are fail messages in the output
        if 'ORA-' in result or 'Warning' in result \
        or 'SP2-' in result:
            print ""
            print "******************************************"
            print "Call to sqlplus errored"
            print "Here's the sqlplus output verbiage:"            
            print result + "\n"
            if command is not None:
                print "Here's the full executed command"
                print command
            print "******************************************"

            # return the mess
            raise RuntimeError('Error ' + result + ' calling SQLPlus')
        
        # caller must check for errors in the swamp that is sqlplus output
        # try:
        #    dbconnection.executescript(sql_file)
        # except RuntimeError, e:
        #    if any('ORA-00942' in item for item in e):

    def executescript(self,
                      script): 
        
        # open, execute script file, get messages, exit
        
        # pass path to script, dont prefix with the @
        # should include closing slashes, commits, and EXITs as necessary
        
        # goal is ala
        # sqlplus mschell@geocdev.doitt.nycnet/iluvdoitt 
        # >> @d:\matt_projects_data\importantproject\work\dostuff.sql
        
        # this isnt 100% correct, the call will be in two parts
        # 1) connection then 2) script execution
        
        # this function has no intelligence about closing slashes,
        # semicolons, and EXIT statements in the input script
        # for line by line statements:
        #   each line should end in a semicolon to execute the line
        # for pl/sql blocks:
        #    sqlplus escapes the end of line semicolons 
        #    each block should be followed by / (the only char on the line) 
        #    to execute what's in the sqlplus buffer
        # But dont add a / after line by line statements
        #   since there is nothing in the buffer SQLPlus will fail
    
        if self.connectionopen == False: 
            self.connect()
                
        if self.dbuglevel > 0:
            print "executing " + script
            print "in " + self.schema + "@" + self.database
            
        self.session.stdin.write("@" + script)      
        # communicate always waits for output and exits

        self.finish()

    def executecommand(self,
                       command): 
        
        # open, execute, get messages, exit
        
        if self.connectionopen == False: 
            self.connect()
            
        self.session.stdin.write(command)     
        
        # pass in command for reporting out on errors
        self.finish(command)

    def executestatement(self,
                         statement):
        
        # DIY.  Caller decides when to finish
        # All error messages for anything executed during the
        # connection will pile up
        # caller must pass in newlines just like being a poor 1980s era DBA
        # typing at an SQLPlus terminal
        # obj.executestatement("BEGIN\n NULL;\n END;\n /\n")
        
        if self.connectionopen == False: 
            self.connect()
            
        self.session.stdin.write(statement)  

    def getschema(self):
        return self.schema

    def getdatabase(self):
        return self.database

