# Begin by gathering credentials from user
# ----------------------------------------
Write-Host "
Enter some info first
------------------------------------------";
$hostname=Read-host("Hostname (IP)`t");
$testNetwork = Start-Job {Test-NetConnection -ComputerName $using:hostname -Port 22};
$username=Read-Host("Username`t");

# Test the given host for a network connection, notifying user and terminating
# script if failed to connect to host (specifically check port 22)
Write-Host -NoNewLine "Checking if ";
Write-Host -NoNewline -ForegroundColor Yellow "$hostname";
Write-Host -NoNewline " is reachable";

$temporary = $ProgressPreference
$ProgressPreference = "Silently Continue"

while($testNetwork.State -eq "Running"){
    Write-Host -NoNewline "...";
    Start-Sleep -Seconds 1.5;
}

Write-Host "`n"
$testResults = Receive-Job $testNetwork;

if ($testResults.TcpTestSucceeded){
    Write-Host "Hostname is valid!";
    Remove-Job $testNetwork;
}
else {
    Write-Host "`nHostname was unreachable - terminating script...";
    return;
}

# Path to current userprofile's .ssh folder to be used
$path="$env:userprofile\.ssh";

# Create .ssh folder if not exist
if (!(Test-Path "$path")){ 
	New-Item $path -ItemType "directory";
}

# Look through ~/.ssh for existing key/key.pub pairs and list them to user
Write-Host "`nLooking for key pairs in the '$path' directory...";
foreach($pubkey in (ls $path\*.pub).Name){
    $key = $pubkey.Replace(".pub", "");
    if (Test-Path $path\$key){
        Write-Host -NoNewline "`to Key pair ";
        Write-Host -NoNewline -ForegroundColor Yellow "$key";
        Write-Host " was found";
    }
}

# List all existing keys and prompt user to input they key pair they wish to use
# Else, if no matches, prompt user for new key pair name
if (!($key)){
    Write-Host -ForegroundColor Yellow "`to No Key pairs found!!";
    $key=Read-Host("`nNew Key Pair Name`t");
}
else{
    $key=Read-Host("`nSelect Key Pair`t");
}

# Default to id_rsa if no input provided
if (!($key)){
	Write-Host "No input provided - defaulting to id_rsa";
	$key="id_rsa";
}

# Notify user of whether new key will be generated (user input non-existing) 
# or selected key will be used (use input existing)
if ((Test-Path $path\$key) -And (Test-Path "$path\$key.pub")){
    Write-Host -NoNewline "`nUsing existing key pair ";
    Write-Host -ForegroundColor Yellow $key;
}

# If input key unrecognized (regardless of pre-existing keys), a new key with
# given name will be generated
else {
    Write-Host -NoNewline "`nGenerating new key pair ";
    Write-Host -ForegroundColor Yellow $key;

# Key created using rsa algorithm with 4096 Bytes and no passphrase
# Prompt user for addition comment info to generate new key with and use 
# appropriate arguments based on whether comment was given or not
    Write-Host "`n[Comments are usually the name of device you're connecting with or user email]";
    $comment=Read-Host("Comment to append to new key");
    Write-Host;

    if ($comment){
        ssh-keygen -b 4096 -t rsa -C $comment -N '""' -f "$path\$key";
    }
    else {
        ssh-keygen -b 4096 -t rsa -N '""' -f "$path\$key";
    }

# Notify upon successful key creation
    Write-Host -NoNewline "`nSuccessfully created key pair ";
    Write-Host -ForegroundColor Yellow $key;
}

# Before copying the key into the server, figure out what commands can be run by
# asking the user to select whether the host is Windows or Linux
Write-Host "Before copying over the public key, pick the server's OS (default Linux):";
Write-Host -NoNewline "`to ";
Write-Host -ForegroundColor Yellow "Linux";
Write-Host "`to Windows";
$host_os = Read-Host("`nSelect server's OS");

# Announce the need to enter a password and the reason (appending public key)
Write-Host "`nNow SSHing into $username@$hostname to add public key to list of authorized keys";
Write-Host "This should be the last time you'll have to manually enter a password!`n";

# Process for copying pubkey over is similar for Windows and Linux w/ diff commands
# - store piped input (pubkey) temporarily
# - create .ssh directory if not exist
# - append the temporarily stored pubkey contents into authorized_keys file
$cmd_commands  = "(mkdir .ssh 2>nul & set /p pubkey= & call echo %pubkey% >> .ssh\authorized_keys)";
$bash_commands = "cat>temp && mkdir -p ~/.ssh && cat temp>>~/.ssh/authorized_keys && rm temp";

# SSH into host to add user public key to 'authorized_keys' in host
if($host_os -eq "Windows") {
    Get-Content "$path\$key.pub" | ssh $username@$hostname "$cmd_commands";
} else {
    Get-Content "$path\$key.pub" | ssh $username@$hostname "$bash_commands";
}

# If ssh connection failed (wrong password or non-response), notify user of
# detected failure and exit script
if($LASTEXITCODE){
    Write-Host "`nFailed to connect with SSH - terminating script...";
    return;
}

# Ask for shortcut name for logging into host if key successfully appended
Write-Host "`nPick a nickname for $hostname you'd prefer to use"
Write-Host "[Generally a short name, so you can connect like this: ssh <nickname>]";
$nickname=Read-Host("Nickname`t")

# Add configurations for host onto user's ssh config file
# Specify ASCII encoding for Powershell V 5.1 (defaults to utf-8)
if ($host_os -eq "Windows"){
    $win_options = "`n`tRequestTTY force`n`tRemoteCommand powershell";
}
Write-Output "Host $nickname`n`tHostname $hostname`n`tUser $username`n`tIdentityFile `"$path\$key`"$win_options" |
Out-File -Append -Encoding ASCII "$path\config"

# Notify user of script completion and how to use the new shortcut
Write-Host -NoNewline "Setup complete, you can log into $hostname as $username by just calling ";
Write-Host -NoNewline -ForegroundColor Yellow "ssh $nickname"; Write-Host " now";

$ProgressPreference = $temporary
