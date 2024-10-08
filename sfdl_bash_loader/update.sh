#!/bin/bash
# ==========================================================================================================
# SFDL BASH-Loader - Updater - raz3r - forked by TREKi
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
upd_version=1.0
version_repo=0
version_local=0
first_install=false
url_repoversion="https://raw.githubusercontent.com/picardncc/sfdl-bash-loader/master/sfdl_bash_loader/sys/logs/version.txt"
url_repodownload="https://github.com/picardncc/sfdl-bash-loader/tarball/master"


status=`ps aux | grep [-i] 'bashloader.sh' 2> /dev/null | wc -l | tr -d '[[:space:]]'`
if [ "$status" -gt 0 ]; then
    echo "[`date`] : BASH-Loader wird bereits ausgefuehrt! [pid: $status]"
    exit 1
fi

if ! [ -z $1 ]; then
	first_install=true
	mkdir sfdl_bash_loader/
	cd sfdl_bash_loader
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

# macht das bild sauber

clear
echo "# ======================================================================================================="
echo "# SFDL BASH-Loader - Installer/Updater - raz3r - Version $upd_version forked by TREKi"
echo "# ======================================================================================================="
echo "| system: $osxcheck"

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
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			brew=1   
		fi
	fi
    
	# wget
	wget=0
	if hash wget 2>/dev/null; then
		wget=1
	else
		installTools+=($(echo "wget "))
	fi
	
	if [ ! -z "$1" ]; then
		if [ "$1" == "true" ]; then
			echo "| -- TOOLS ----------------------------- "
			echo "| wget:    	$wget"
			if [ $osxcheck == "Darwin" ]; then
				echo "| brew:    	$brew"
			fi
			echo "| -------------------------------------- "
			echo "| tools fehlen: ${#installTools[@]}"
			echo "| Tools: ${installTools[@]}"
			echo "| ----------------------------- TOOLS -- "
		fi
	fi
}

loaderupdate()
{
    echo "| -------------------------------------- "

    #hole versionsnummern
    version_repo=$(wget -q -O - "$@" $url_repoversion)

    if [ -f "$pwd/sys/logs/version.txt" ]; then
	    version_local=$(cat "$pwd/sys/logs/version.txt")
	    rm $pwd/sys/logs/version.txt
    fi

    if [ $first_install = false ]; then
	    echo "|" # Installierte Version: $version_local
    fi

    echo "| Aktuelle Version: $version_repo"
    echo "| -------------------------------------- "
    if [ "$(echo -e "$version_local\n$version_repo" | sort -V | head -n 1)" != "$version_repo" ]; then
	    echo "| ! Neue Version wird installiert !"
	    echo "| -------------------------------------- "
	    
	    if [ -d "$pwd/sys" ]; then
		    echo "| Konfiguration speichern..."
		    rm -rf "/tmp/backup" >/dev/null 2>&1
		    mkdir "/tmp/backup"
		    cp -r "$pwd/sys/userscript/" /tmp/backup/userscript
		    cp "$pwd/sys/loader.cfg" "/tmp/backup/loader.cfg"
		    cp "$pwd/sys/passwords.txt" "/tmp/backup/passwords.txt"
		    cp "$pwd/update.sh" "/tmp/backup/update.sh"
	    fi
	    rm -rf "$pwd/sys/"
        rm -rf "$pwd/sys/userscript"
	    rm "$pwd/start.sh"

        echo
        echo "Script Pfad: "$pwd
        echo
	    echo "| Download wird gestartet."
	    echo "| Bitte warten ..."

        mkdir $pwd/tmp >/dev/null 2>&1
        mkdir $pwd/tmp2 >/dev/null 2>&1
        wget $url_repodownload -O /tmp/main.tgz
        tar -xvf /tmp/main.tgz -C $pwd/tmp2
        quelle="$pwd/tmp2/picardncc*/sfdl_bash_loader/*"
        ziel="$pwd/"
        cp -rf $quelle $ziel
        cp "$pwd/update.sh" "/tmp/backup/new.update.sh"
        cp "/tmp/backup/update.sh" "$pwd/update.sh"
        rm /tmp/main.tgz
        rm -rf $pwd/tmp >/dev/null 2>&1
        rm -rf $pwd/tmp2 >/dev/null 2>&1

	    chmod +x "$pwd/start.sh"
	    
	    if [ -d "/tmp/backup" ]; then
		    echo "| Konfiguration wiederherstellen..."
		    cp /tmp/backup/userscript/* "$pwd/sys/userscript"
		    mv "$pwd/sys/loader.cfg" "$pwd/sys/loader.cfg.new"
      		cp "/tmp/backup/loader.cfg" "$pwd/sys/loader.cfg"
		    chmod +x "$pwd/sys/updatecfg.sh" "$pwd/sys/force.cfg" "$pwd/sys/loader.cfg"
		    cp "/tmp/backup/passwords.txt" "$pwd/sys/passwords.txt"
#            cp "/tmp/backup/new.update.sh" "$pwd/update.sh"
		    rm -rf /tmp/backup
	    fi
	    
	    if ! [ -d "$pwd/sfdl" ]; then
		    mkdir sfdl
	    fi
	    
	    if ! [ -d "$pwd/downloads" ]; then
		    mkdir downloads
	    fi
	    if [ $first_install = true ]; then
		    echo "| Installation abgeschlossen "
	    else
		    echo "| Update abgeschlossen "
	    fi
	    echo "| -------------------------------------- "
    else
	    echo "| -------------------------------------- "
	    echo "| Version ist aktuell!"	
	    echo "| -------------------------------------- "	
    fi

    echo -e "\n\033[41m $pwd/start.sh erneut ausführen!\033[0m\n"
    sleep 5
}

chkTools

if [ "${#installTools[@]}" != 0 ]; then
	echo "| Es sind nicht alle Tools installiert!"
	echo "| Installiere ${#installTools[@]} fehlende Tools ... bitte warten ..."
	
	if [ $osxcheck == "Darwin" ]; then
		if hash brew 2>/dev/null; then
			brew install ${installTools[@]} > /dev/null
		else
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
			brew install ${installTools[@]} > /dev/null
		fi
	else
		if hash apt-get 2>/dev/null; then
			# sudo pass eingabe
			usesudo=0
			if hash sudo 2>/dev/null; then
				usesudo=1
				while [[ -z "$sudopass" ]]
				do
					read -p "| Bitte SUDO Passwort eingeben: " sudopass
				done
			fi
            echo "Allfällige Fragen mit y (ja) beantworten!"
			if [ $usesudo == 1 ]; then
				echo $sudopass | sudo -S apt-get --yes install ${installTools[@]} # > /dev/null
			else
				apt-get --yes install ${installTools[@]} # > /dev/null
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
			echo "| Installiere Homebrew: http://brew.sh"
			echo "| und installiere z.B. mit: brew install ${installTools[@]}"
		else
			echo "| Versuche Tools mit dem Paketmanager zu"
			echo "| installieren. Beispiel: sudo apt-get --yes install ${installTools[@]}"
		fi
	else
		echo "| -------------------------------------- "
		echo "| Alle Pakete installiert!"
		echo "| Starte Installation in 5 Sekunden ..."
		sleep 5
		loaderupdate
	fi
else
	echo "| -------------------------------------- "
	echo "| Alle Pakete installiert!"
	echo "| Starte Installation in 5 Sekunden ..."
	sleep 5
    loaderupdate
fi
