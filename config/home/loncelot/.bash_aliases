alias vim='nvim'
alias mykeyboard='/home/loncelot/.local/bin/mykeyboard.sh --setup'
alias codes='sudo code --no-sandbox --user-data-dir ~/.config/Code '
alias codessh='codes --folder-uri "vscode-remote://ssh-remote+root-ssh.loncelot/home/loncelot/Workspace"'
alias hl='steam -silent -offline -applaunch 70 -windowed -w 2520 -h 1175'
alias cs='steam -silent -offline -applaunch 10 -windowed -w 2520 -h 1175'

alias forever='WINEPREFIX="/home/loncelot/games/blizzard/prefix" anv_emulate_read_without_format=true wine "/home/loncelot/games/blizzard/prefix/drive_c/Program Files (x86)/World of Warcraft/_forever_/Wow.exe" >/dev/null 2>&1 &'
alias tbc='WINEPREFIX="/home/loncelot/games/blizzard/prefix" wine "/home/loncelot/games/blizzard/prefix/drive_c/Program Files (x86)/World of Warcraft/_anniversary_/WowClassic.exe" >/dev/null 2>&1 &'
alias blizz='WINEPREFIX="/home/loncelot/games/blizzard/prefix" wine "/home/loncelot/games/blizzard/prefix/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"  >/dev/null 2>&1 &'
alias stopblizz='WINEPREFIX="/home/loncelot/games/blizzard/prefix" wineserver -k'

alias wow='WINEPREFIX="/home/loncelot/games/ChromieCraft_3.3.5a/prefix" wine "/home/loncelot/games/ChromieCraft_3.3.5a/Wow.exe" >/dev/null 2>&1 &'
alias classic='WINEPREFIX="/home/loncelot/games/WowEs/prefix" wine "/home/loncelot/games/WowEs/WoW.exe" >/dev/null 2>&1 &'

alias gtasa='nohup env WINEESYNC=0 WINEFSYNC=0 WINEDEBUG=+ntsync WINEPREFIX="/home/loncelot/games/gtasa/prefix" wine start /unix "/home/loncelot/games/gtasa/gta_sa.exe" >/dev/null 2>&1 </dev/null &'

function sshWeb {
	ssh -p 2222 -L 8080:"$@":80 root@ssh.loncelot.com
}
alias killWeb='pkill -f 'ssh.*ssh.loncelot.com''
alias copyy='rsync -ah --info=progress2 '
alias fast='fastfetch -l gnome'
alias gnu='fastfetch -l gnu'
alias mac='fastfetch -l mac'

alias calibre-server='calibre-server /home/loncelot/Calibre\ Library --num-per-page 500'

alias spotify='kitty -e spotify_player >/dev/null 2>&1 &'
alias chat='thorium-browser --incongnito --app=https://chatgpt.com/?temporary-chat=true >/dev/null 2>&1 &'
alias tg='thorium-browser --app=https://web.telegram.org/k/ >/dev/null 2>&1 &'

function thorium {
    if command -v thorium-browser &> /dev/null; then
        thorium-browser --remote-debugging-port=9222 --no-first-run --no-default-browser-check "$@"
    else
        /home/loncelot/.local/bin/thorium-browser-arm64/thorium "$@"
    fi
}
function yt {
	if [[ $# -eq 2 && ( $1 == "audio" || $1 == "720" || $1 == "1080" ) ]]; then
		quality=$1
		url=$2
		if [[ $quality == "audio" ]]; then
			yt-dlp -o "~/Downloads/%(title)s.%(ext)s" -f "bestaudio/best" "$url"
		elif [[ $quality == "720" ]]; then
			yt-dlp -o "~/Downloads/%(title)s.%(ext)s" -f "(mp4) bestvideo[height<=?720]+bestaudio/best" "$url"
		elif [[ $quality == "1080" ]]; then
			yt-dlp -o "~/Downloads/%(title)s.%(ext)s" -f "(mp4) bestvideo[height<=?1080]+bestaudio/best" "$url"
		fi
	else
		# YTFZF
			# cd ~/Downloads
			# ytfzf -l -t "$@"
		# YT-Z
			kitty -e yt-x "$@" >/dev/null 2>&1 &
	fi
}

PATH="$PATH:/home/loncelot/.local/bin"
PATH="$PATH:/home/loncelot/.cargo/bin"
