#!/usr/bin/python3


  #To use it you have to add your token to DROPBOX
  #in astring bellow as TOKEN = '?????'



import sys
import dropbox
import getopt
import os.path
import datetime

from dropbox.files import WriteMode
from dropbox.exceptions import ApiError, AuthError


def main():  



  def backup():
    with open(LOCALFILE, 'rb') as f:
        print("Uploading " + LOCALFILE + " to Dropbox as " + BACKUPPATH + "...")
        try:
            dbx.files_upload(f.read(), BACKUPPATH, mode=WriteMode('overwrite'))
        except ApiError as err:
            # This checks for the specific error where a user doesn't have enough Dropbox space quota to upload this file
            if (err.error.is_path() and
                    err.error.get_path().error.is_insufficient_space()):
                sys.exit("ERROR: Cannot back up; insufficient space.")
            elif err.user_message_text:
                print(err.user_message_text)
                sys.exit()
            else:
                print(err)
                sys.exit()



  def checkFileDetails():
    print("Checking file details")

    for entry in dbx.files_list_folder('').entries:
        print("File list is : ")
        print(entry.name)




  #ARGUMENTS
    
  try:
    opts, args = getopt.getopt(sys.argv[1:],'hi:f:', ['help', 'input=', 'folder='])
    if len(opts)==0:
           raise getopt.GetoptError('No arguments')    
    for opt, arg in opts:
        if opt in ("-h", "--help"):
           print ('copyDBX.py -i <inputfile>')
           sys.exit()
        elif opt in ("-i", "--input"):
           LOCALFILE = arg
        elif opt in ("-f", "--folder"):
           BACKFOLDER = "/"+arg+"/"

  except getopt.GetoptError as err:
     print ('copyDBX.py -i <inputfile>')
     sys.exit(2)


  now = datetime.datetime.now()
  BACKUPPATH = BACKFOLDER+"backUp_"+now.strftime("%A")+LOCALFILE[-7:]


  if not os.path.isfile(LOCALFILE):
       print ('Error. No such file ', LOCALFILE)
       sys.exit(2)


  #Add your token to DROPBOX
  TOKEN = '?????'


  print ('Input file is "', LOCALFILE)
  print ('Output file is "', BACKUPPATH)


  dbx = dropbox.Dropbox(TOKEN)
  try:
        dbx.users_get_current_account()
  except AuthError as err:
        sys.exit(
            "ERROR: Invalid access token; try re-generating an access token from the app console on the web.")

  try:
        checkFileDetails()
  except Error as err:
        sys.exit("Error while checking file details")


  print("Creating backup...")
  backup()

  print("Done!")




# Run this script independently
if __name__ == '__main__':
    main()

