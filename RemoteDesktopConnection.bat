Rem http://woshub.com/rdp-session-shadow-to-windows-10-user/
set /P rcomp="Enter name or IP of a Remote PC: "
query session /server:%rcomp%
set /P rid="Enter RDP user ID: "
start mstsc /shadow:%rid% /v:%rcomp% /control /noconsentprompt
