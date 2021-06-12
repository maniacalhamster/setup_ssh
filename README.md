# SSH Key and config setup powershell script
============================================    
Originally made in early 2020 to set up ssh key and config files for logging 
into the ieng6 servers for cse30, which was generally not very well tested.

Updated with a new powershell script that sets up ssh keys and configs for a 
more general case and has had significantly more testing as well as an improved 
flow.

* Reads curent process to user and gives clearer instructions for less confusion
* Tests user data and terminates script if error detected
* Searches through pre-existing keys and offers the ability to use them
* Colors added to better emphasize certain texts

=== Old readme follows below ===============

SSH key and config setup batch for Windows
============================================
Heyya, this is just a small batch file that will automate the process of setting up easy ssh connections to your cs30sp20 account on the ieng6 server.

The motivation behind making this small batch file was to help others (using windows) set up a secure and easy way to log into their cs30sp20 account for doing PAs.

The built in openSSH client supported by Windows supports is used along with SSH keys (rather than entering the whole username@server and password each time)!

## Using it
Just git clone from your windows command prompt or download as a zip and extract

Once copied over, just cd into the directory it was saved to and run the batch file:

In command prompt >setup_ssh.bat

Follow the instructions of the batch and just call 'ssh [name]' afterwards to log-in/ 

## How it works
The batch file itself is commented and echo statements on what's happening are printed out each step of the way but the flow of what's happening is as follows:

- Gathering info
  - First, the user is prompted for their ucsd email and the last 2 letters of their cs30sp20 account - asking them to verify before running any commands with that info.

- Generate key
  - Then, a new ssh public/private key pair is generated using ssh-keygen (4096 bit under RSA algorithm with no passphrase)

- Add key to Ieng6 account
  - After that, the contents of the public key are appended to the authorized_keys file under the .ssh folder within the users account on the ieng6 server via initial ssh. A .ssh directory is created if one does not already exist, storing the key in a temporary file in the meanwhile.
    - Note: if this is the first time the user is ssh-ing into the ieng6 server, they will be asked whether they trust the source (you trust the ieng6 server so enter "yes")
    - Also: the user will be asked to enter their password to log into their cs30sp20 account (make sure you changed the old password through ETS first!)

- Saving to config file
  - Finally, the user will be prompted for the shortcut name they want to use to log in with.
    - This is the nickname that the user will connect to their account with in afterwards (just type out 'ssh [nickname]' to log in after this!)
  - Using the input username, shortcut name, generated ssh key, and the known hostname (ieng6.ucsd.edu), an entry is generated in the ssh config file.
  - The user is notified when the batch file is over and told how to utilize all these to log easily.

### End
Thanks for reading, if there's any problems you run into lmk in the discussions of the piazza post!
