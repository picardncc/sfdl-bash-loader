#!/bin/bash
# ==========================================================================================================
# SFDL BASH-Loader - Installer - liebevoll gescripted von GrafSauger und raz3r. Fork von TREKi
# ==========================================================================================================
# 888888b.         d8888  .d8888b.  888    888        888                            888                  
# 888  "88b       d88888 d88P  Y88b 888    888        888                            888                  
# 888  .88P      d88P888 Y88b.      888    888        888                            888                  
# 8888888K.     d88P 888  "Y888b.   8888888888        888      .d88b.   8888b.   .d88888  .d88b.  888d888 
# 888  "Y88b   d88P  888     "Y88b. 888    888        888     d88""88b     "88b d88" 888 d8P  Y8b 888P"   
# 888    888  d88P   888       "888 888    888 888888 888     888  888 .d888888 888  888 88888888 888     
# 888   d88P d8888888888 Y88b  d88P 888    888        888     Y88..88P 888  888 Y88b 888 Y8b.     888     
# 8888888P" d88P     888  "Y8888P"  888    888        88888888 "Y88P"  "Y888888  "Y88888  "Y8888  888      
# ==========================================================================================================
version_repo=0
version_local=0
url_repoversion="https://raw.githubusercontent.com/picardncc/sfdl-bash-loader/master/sfdl_bash_loader/sys/logs/version.txt"


#gibt es ein update
checkupdate()
{
    #immer update wenn keine config da
    sfdl_update=true

    # lade config für update frage
    if [ -f "$pwd/sys/loader.cfg" ]; then
	    source "$pwd/sys/loader.cfg"
    fi

    version_repo=$(wget -q -O - "$@" $url_repoversion | cut -d"." -f2)
    log_path=${sfdl_logs##*/}
    if [ -f "$pwd/sys/$log_path/version.txt" ]; then
	    version_local=$(cat "$pwd/sys/$log_path/version.txt" | cut -d"." -f2)
    else
	    sfdl_update=true
    fi

    if ! [ $sfdl_update = false ]; then 
	    if [ $(($version_local)) -lt $(($version_repo)) ]; then
		    echo "Update verfügbar."
		    echo "Führe den Update aus..."
            sfdl_update=true	    

		    #update starten
		    if [ $sfdl_update == true ]; then
			    #alte update.sh sichern
			    if [ -f "$pwd/update.sh" ]; then
				    mv "$pwd/update.sh" "$pwd/update_old.sh"
			    fi 
                rm "$pwd/sys/logs/version.txt"			
			    #hole neues Update script
			    wget https://raw.githubusercontent.com/picardncc/sfdl-bash-loader/master/sfdl_bash_loader/update.sh -v -O $pwd/update.sh 1> /dev/null
			    #neue update.sh da? sonst mit alte behalten!
			    if [ -s "$pwd/update.sh" ]; then
				    rm -rf "$pwd/update_old.sh"
                    echo "Update Fortsetzen? Abbrechen nicht empfohlen."
			    else
				    echo -e "\n\033[41mACHTUNG!!!\033[0m\n"
				    echo "Aktuelle Update Datei konnte nicht geladen werden. Bitte später noch mal versuchen, oder Manuell die Neue Version bei Github Laden."
				    echo "Update trotzdem durchführen? Das kann zu einer unvollständigen Installation führen und wird nicht empfohlen."
                    mv "$pwd/update_old.sh" "$pwd/update.sh"
                fi
                chmod +x "$pwd/update.sh"
                while true; do
	                read  -t 15 -r -p "In 15 Sekunden wird fortgefahren [J/n] " answer
                    if echo "$answer" | grep -iq "^j" ;then
     					echo -e "\033[34mOk\033[0m"
				        break
                    fi
                    if echo "$answer" | grep -iq "^n" ;then
     					echo -e "\033[31mAbbruch\033[0m"
				        sfdl_update=false
				        break
                    fi
                    if echo "$answer" == "" ;then
     					echo -e "\033[34mOk\033[0m"
				        break
                    fi
                done
		    fi			
	    fi
	    #go
	    if [ $sfdl_update = true ]; then
			exec "$pwd/update.sh"
	    fi
    else
	    echo "Keine Updates verfügbar"
    fi
}

function printErr {
    echo $'\e[40;38;5;13m' $1 $'\e[0m'
}

if { ! hash md5sum 2>/dev/null; } then
	printErr "Es fehlt md5sum!"
	printErr "Abbruch!"
	printErr "Installation bei Debian basierten OS (zBsp. Ubuntu): sudo apt-get install coreutils"
	printErr "Installation bei RHEL basierten OS (zBsp. CentOS, Fedora): sudo yum install coreutils"
	printErr "Installation bei Arch Linux und Derivaten: sudo pacman -S coreutils"
	printErr "Direkt ab Source siehe: https://ioflood.com/blog/install-md5sum-command-linux/"
	exit 1
fi

status=`ps aux | grep [-i] 'bashloader.sh' 2> /dev/null | wc -l | tr -d '[[:space:]]'`
if [ "$status" -gt 0 ]; then
    echo "[`date`] : BASH-Loader wird bereits ausgefuehrt! [pid: $status]"
    exit 1
fi

# pfad definieren
# osx: kann nun auch unter mac osx mit doppelklick vom desktop aus gestartet werden
osxcheck=$(uname)

if [ $osxcheck == "Darwin" ]; then
	realpath() {
		[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
	}
	osxpath="$(realpath "$0")"
	pwd=$(dirname "${osxpath}")
else
	pwd=$(cd `dirname $0` && pwd)
fi

source "$pwd/sys/loader.cfg"
log_path=${sfdl_logs##*/}
chk=$(wget -q -O - "$@" "https://raw.githubusercontent.com/picardncc/sfdl-bash-loader/master/sfdl_bash_loader/sys/logs/check")
echo "$chk" > "$pwd/sys/$log_path/check"

if [ -f "$pwd/sys/setup.txt" ]; then
	echo "Starte..."
	checkupdate
	exec "$pwd/sys/bashloader.sh"
	exit 0
fi

# macht das bild sauber
clear

echo "| -------------------------------------- "
echo "| BASH-Loader Installer"
echo "| -------------------------------------- "
echo "| system: $osxcheck"



# ==========================================================================================================
# haben wir alle tools?
# ==========================================================================================================
chkTools()
{
	installTools=()
	# brew (Darwin)
	if [ $osxcheck == "Darwin" ]; then
		brew=0
		if hash brew 2>/dev/null; then
			brew=1
		else
			#installTools+=($(echo "brew "))
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
			brew=1   
		fi
	fi
	
    # python
    python=0
	if hash python 2>/dev/null; then
		python=1
	fi
	if hash python3 2>/dev/null; then
		python=1
	fi
    
    if [[ $python == 0 ]]; then
        echo "Python3 ist nicht installiert!"
        echo "Bitte zuerst installieren!"
        exit 1
    fi
    
	# wget
	wget=0
	if hash wget 2>/dev/null; then
		wget=1
	else
		installTools+=($(echo "wget "))
	fi

	# findutils
	if [ $osxcheck == "Darwin" ]; then
	    findutils=0
	    if hash gfind 2>/dev/null; then
		    findutils=1
	    else
		    installTools+=($(echo "findutils "))
	    fi
	else
        findutils=1
	fi

	# lftp
	lftp=0
	if hash lftp 2>/dev/null; then
		lftp=1
	else
		installTools+=($(echo "lftp "))
	fi

	# md5sum
	md5sum=0
	if hash md5sum 2>/dev/null; then
		md5sum=1
	else
		if [ $osxcheck == "Darwin" ]; then
			installTools+=($(echo "md5sha1sum "))
		else
			installTools+=($(echo "md5sum "))
		fi
	fi

	# xxd
	xxd=0
	if hash xxd 2>/dev/null; then
		xxd=1
	else
		installTools+=($(echo "xxd "))
	fi

	# openssl
	openssl=0
	if hash openssl 2>/dev/null; then
		openssl=1
	else
		installTools+=($(echo "openssl "))
	fi

	# grep
	grep=0
	if hash grep 2>/dev/null; then
		grep=1
	else
		installTools+=($(echo "grep "))
	fi

	# cat
	cat=0
	if hash cat 2>/dev/null; then
		cat=1
	else
		installTools+=($(echo "cat "))
	fi

	# cut
	cut=0
	if hash cut 2>/dev/null; then
		cut=1
	else
		installTools+=($(echo "cut "))
	fi

	# sed
	sed=0
	if hash sed 2>/dev/null; then
		sed=1
	else
		installTools+=($(echo "sed "))
	fi

	# awk
	awk=0
	if hash awk 2>/dev/null; then
		awk=1
	else
		installTools+=($(echo "awk "))
	fi

	# ncftp
	ncftp=0
	if hash ncftp 2>/dev/null; then
		ncftp=1
	else
		installTools+=($(echo "ncftp "))
	fi

	# tail
	tail=0
	if hash tail 2>/dev/null; then
		tail=1
	else
		installTools+=($(echo "tail "))
	fi

	# bc
	bc=0
	if hash bc 2>/dev/null; then
		bc=1
	else
		installTools+=($(echo "bc "))
	fi

	# unrar
	unrar=0
	if hash unrar 2>/dev/null; then
		unrar=1
	else
		if [ $osxcheck == "Darwin" ]; then
			installTools+=($(echo "carlocab/personal/unrar "))
		else
			installTools+=($(echo "unrar "))
		fi
	fi

	# jq
	jq=0
	if hash jq 2>/dev/null; then
		jq=1
	else
		installTools+=($(echo "jq "))
	fi

	# phpcgi
	: '
	phpcgi=0
	if hash php-cgi 2>/dev/null; then
		phpcgi=1
	else
		if [ $osxcheck == "Darwin" ]; then
			installTools+=($(echo "homebrew/php/php56 "))
		else
			installTools+=($(echo "php5-cgi "))
		fi
	fi
	'
	
	# source
	source=0
	if hash source 2>/dev/null; then
		source=1
	else
		installTools+=($(echo "source "))
	fi
	
	# base64
	base64=0
	if hash base64 2>/dev/null; then
		base64=1
	else
		installTools+=($(echo "base64 "))
	fi
	
	
	
	if [ ! -z "$1" ]; then
		if [ "$1" == "true" ]; then
			echo "| -- TOOLS ----------------------------- "
            echo "| python:  $python"
			echo "| wget:    $wget"
			echo "| findutils: $findutils"
			echo "| md5sum:  $md5sum"
			echo "| xxd:     $xxd"
			echo "| openssl: $openssl"
			echo "| grep:    $grep"
			echo "| cat:     $cat"
			echo "| cut:     $cut"
			echo "| sed:     $sed"
			echo "| awk:     $awk"
			echo "| ncftp:   $ncftp"
			echo "| tail:    $tail"
			echo "| bc:      $bc"
			echo "| unrar:   $unrar"
			echo "| jq:      $jq"
			#echo "| phpcgi:  $phpcgi"
			echo "| source:  $source"
			echo "| base64:  $base64"
			if [ $osxcheck == "Darwin" ]; then
				echo "| brew:    $brew"
			fi
			echo "| -------------------------------------- "
			echo "| tools fehlen: ${#installTools[@]}"
			echo "| Tools: ${installTools[@]}"
			echo "| ----------------------------- TOOLS -- "
		fi
	fi
}

chkTools

if [ "${#installTools[@]}" != 0 ]; then
	echo "| Es sind nicht alle Tools installiert!"
	echo "| Installiere ${#installTools[@]} fehlende Tools ... bitte warten ..."
	
	if [ $osxcheck == "Darwin" ]; then
		if hash brew 2>/dev/null; then
			brew install ${installTools[@]}
		else
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
			brew install ${installTools[@]}
		fi
	else
		if hash apt-get 2>/dev/null; then
			# sudo pass eingabe
			usesudo=0
			if hash sudo 2>/dev/null; then
				usesudo=1
				while [[ -z "$sudopass" ]]
				do
					read -p "| Bitte SUDO Passwort eingeben: " -r -s sudopass
				done
			fi
			if [ $usesudo == 1 ]; then
				echo $sudopass | sudo -S apt-get --yes install ${installTools[@]}
				if [[ $unrar == 0 ]]; then
				    echo $sudopass | sudo -S apt-get --yes install software-properties-common
				    echo $sudopass | sudo -S apt-add-repository contrib non-free
				    echo $sudopass | sudo -S apt-get update
				    echo $sudopass | sudo -S apt-get --yes install unrar
                    echo "unrar ist installiert!"
				fi    
			else
				echo "| Es wird installiert.... Bitte Warten"
				apt-get --yes --force-yes install ${installTools[@]}
			fi
		else
			echo "| Konnte Paketmanager APT nicht finden!"
		fi
	fi
	
	chkTools "true"

	if [ "${#installTools[@]}" != 0 ]; then
		echo "| BASH-Loader Installer konnte ${#installTools[@]} Tools"
		echo "| nicht installieren: ${installTools[@]}"
		if [ $osxcheck == "Darwin" ]; then
			echo "| Installiere Homebrew (siehe https://brew.sh )"
			echo "| und installiere z.B. mit: brew install ${installTools[@]}"
		else
			echo "| Versuche Tools mit dem Paketmanager zu"
			echo "| installieren. Beispiel (Debian/Ubuntu): sudo apt-get --yes install ${installTools[@]}"
		fi
	else
		echo "| -------------------------------------- "
		echo "| Alle Pakete installiert!"
		echo "| Prüfe ausführbarkeit!"
        if [[ -x "$pwd/sys/bashloader.sh" ]]; then
			echo "| Files are executable"
		else
			echo "| File are not executable or found"
			chmod -R +x "$pwd/sys"
   			chmod +x "$pwd/sys/bashloader.sh"
   			chmod +x "$pwd/sys/jq"
   			chmod +x "$pwd/sys/netcat"
   			chmod +x "$pwd/sys/prog.sh"
   			chmod +x "$pwd/sys/status.sh"
   			chmod +x "$pwd/sys/status.py"
   			chmod +x "$pwd/sys/updatecfg.sh"
			chmod +x "$pwd/update.sh"
			echo "| Files are now executable"
		fi
		
		echo "| Prüfe auf Updates..."
		checkupdate
		
		echo "| Starte BASH-Loader in 5 Sekunden ..."
        echo 1 > "$pwd/sys/setup.txt"
		sleep 5
		exec "$pwd/sys/bashloader.sh"
	fi
else
	echo "| -------------------------------------- "
	echo "| Alle Pakete installiert!"
	echo "| Prüfe ausführbarkeit!"
	if [[ -x "$pwd/sys/bashloader.sh" ]]; then
		echo "| Files are executable"
	else
        echo "| File are not executable or found"
		chmod +x -R "$pwd/sys"
		chmod +x "$pwd/update.sh"
		chmod +x "$pwd/sys/bashloader.sh"
		chmod +x "$pwd/sys/jq"
		chmod +x "$pwd/sys/netcat"
		chmod +x "$pwd/sys/prog.sh"
		chmod +x "$pwd/sys/status.sh"
		chmod +x "$pwd/sys/status.py"
		chmod +x "$pwd/sys/updatecfg.sh"
		chmod +x "$pwd/update.sh"
		echo "| Files are now executable"
	fi
	
	echo "| Prüfe auf Updates..."
	checkupdate
	
	echo "| Starte BASH-Loader in 5 Sekunden ..."
	echo 1 > "$pwd/sys/setup.txt"
	sleep 5
	exec "$pwd/sys/bashloader.sh"
fi
