@echo off

:: Begin by gathering credentials from user
:: -------------------------------------------
set /P email="ucsd email: "
set /P uname="last 2 letters of cs30sp20??: "
set uname=cs30sp20%uname%

:: Verify that user inputted the correct credentials
:: -------------------------------------------------
echo: 
echo Please verify the credentials listed (to make corrections, press control-C to exit, then restart) & echo Email: %email% & echo Uname: %uname%
set /P resp=""

:: Make .ssh if it does not exist, ignore error message if it already exists
@mkdir "%userprofile%\.ssh"

:: Set path to .ssh directory for commands to follow
set sshdir=%userprofile%\.ssh

:: Generate a new ssh pub/priv key pair to use for cs30
echo %sshdir%\cs30_id_rsa| ssh-keygen -t rsa -b 4096 -C %email% -P ""

:: SSH connect using inputted user credentials once to append public key to authorized keys in ieng6
echo Connecting to ieng6 server to append public key to authorized_keys under %uname%...
type "%sshdir%\cs30_id_rsa.pub"| ssh %uname%@ieng6.ucsd.edu "cat>a.temp && mkdir -p .ssh && cat a.temp>>.ssh/authorized_keys && rm a.temp"

:: Ask for shortcut name for logging into ieng6
set /P short="Now choose a nickname for logging into your cse30 account (you'll use this to connect to your cs30sp20 account): "

:: Add configurations for logging into ieng6 onto ssh config file
(echo: & echo Host %short% & echo 	HostName ieng6.ucsd.edu & echo 	User %uname% &echo 	IdentityFile "%sshdir%\cs30_id_rsa")>> "%sshdir%\config"


:: Notify User of completed setup and how to connect
echo: & echo ssh-key pair and config complete! & echo to log into %uname% on the ieng6 server, all you need to do now is call 'ssh %short%'