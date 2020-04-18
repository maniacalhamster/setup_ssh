Heyya, this is just a small batch file that will automate the process of setting up easy ssh connections to your cs30sp20 account on the ieng6 server.

Just git copy (or just download as a zip and extract) the batch file and call it in command line to run (in the directory it's located in: setup_ssh).

The motivation behind making this small batch file was to help others (using windows) set up a secure and easy way to log into their cs30sp20 account for doing
PAs through the built in openSSH client that Windows supports and using SSH keys (rather than entering the whole username@server and password each time)!

The batch file itself is commented and echo statements on what's happening are printed out each step of the way but the flow of what's happening is as follows:

First, the user is prompted for their ucsd email and the last 2 letters of their cs30sp20 account - asking them to verify before running any commands with that info.

Then, a new ssh public/private key pair is generated using ssh-keygen (4096 bit under RSA algorithm with no passphrase)

After that, the contents of the public key are appended to the authorized_keys file under the .ssh folder within the users account on the ieng6 server via initial ssh.
Note: if this is the first time the user is ssh-ing into the ieng6 server, they will be asked whether they trust the source, just enter "yes" (or "y", idk)
Also: the user will be asked to enter their password to log into their cs30sp20 account (make sure you changed the old password through ETS first!)

Finally, the user will be prompted for the shortcut name they want to use to log in (just type out 'ssh <nickname>' to log in after this!)
Using the input username, shortcut name, generated ssh key, and the known hostname (ieng6.ucsd.edu), an entry is generated in the ssh config file.

The user is notified when the batch file is over and told how to utilize all these to log easily.

Thanks for reading, if there's any problems you run into lmk in the discussions of the piazza post!
