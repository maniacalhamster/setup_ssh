# Begin by gathering credentials from user
# ----------------------------------------
echo "
Enter some info first
------------------------------------------";
$hostname=read-host("Hostname (IP)`t");
$username=read-host("Username`t");

if (!(Test-Connection $hostname -Count 1 -Quiet)) {
    write-host "`n!Hostname " -nonewline;
    write-host "$hostname" -foregroundcolor Yellow -nonewline;
    echo " was unreachable - terminating script...";
    return;
}

# Path to current userprofile's .ssh folder to be used (beats typing it over
# and over again)
$path="$env:userprofile\.ssh";

# Create .ssh folder if not exist
if (!(test-path "$path")){ 
	mkdir $path;
}

# List all existing keys and ask user to input they key pair they wish to use
# Else, if no matches, new key will be created

echo "`nLooking for key pairs in the '$path' directory...";
foreach($pubkey in (ls $path\*.pub).Name){
    $key = $pubkey.Replace(".pub", "");
    if (test-path $path\$key){
        write-host -NoNewline "`to Key pair ";
        write-host -NoNewline -ForegroundColor Yellow "$key";
        Write-Host " was found";}
}
if (!($key)){
    write-host -ForegroundColor Yellow "`to No Key pairs found!!";
}

$key=read-host("`nSelect Key Pair`t");
if (!($key)){
	echo "No input provided - defaulting to id_rsa";
	$key="id_rsa";
}

if ((test-path $path\$key) -And (test-path "$path\$key.pub")){
    write-host "`nUsing existing key pair " -NoNewline;
    write-host $key -ForegroundColor Yellow;
}
else {
    write-host "`nGenerating new key pair " -NoNewline;
    write-host $key -ForegroundColor Yellow;

    $comment=read-host("`nComment to append to new key [e.g. device name or email]");
    write-host

    if ($comment){
        ssh-keygen -b 4096 -t rsa -C $comment -N '""' -f "$path\$key";
    }
    else {
        ssh-keygen -b 4096 -t rsa -N '""' -f "$path\$key";
    }

    write-host "`nSucessfully created key pair " -NoNewline;
    write-host $key -ForegroundColor Yellow;
}

echo "`nNow SSHing into $username@$hostname to add public key to list of authorized keys";
echo "This should be the last time you'll have to manually enter a password!`n";

# SSH into host to add user public key to 'authorized_keys' in host
cat "$path\$key.pub" | 
ssh $username@$hostname "cat>temp && mkdir -p ~/.ssh && cat temp>>~/.ssh/authorized_keys && rm temp";

if($LASTEXITCODE){
    echo "`nFailed to connet with SSH - terminating script...";
    return;
}

# Ask for shortcut name for logging into host
echo "`nPick a nickname for $hostname you'd prefer to use"
echo "[generally a short name to call when running ssh <nickname>]";
$nickname=read-host("Nickname`t")

# Add configurations for host onto user's ssh config file
echo "Host $nickname`n`tHostname $hostname`n`tUser $username`n`tIdentityFile `"$path\$key`"" |
Out-File -Append -Encoding ASCII "$path\config"

# Notify user of completion
write-host -NoNewline "Setup complete, you can log into $hostname as $username by just calling ";
write-host -NoNewline -ForegroundColor Yellow "ssh $nickname"; write-host " now";
