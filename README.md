# SFDL Bash Loader

Zum einfachen herunterladen von SFDL Dateien unter Linux

## Installation

```
wget https://raw.githubusercontent.com/picardncc/sfdl-bash-loader/master/sfdl_bash_loader/update.sh -v -O update.sh && chmod +x ./update.sh && ./update.sh install; rm -rf update.sh
```

#### Alternativ:
Auspacken: 
```
unzip sfdl-bash-loader-master.zip
```
Ins Verzeichnis wechseln: 
```
cd sfdl-bash-loader-master/sfdl_bash_loader  
```

Rechte vergeben: 
```
sudo chmod +x ./start.sh 
```

## sfdl Datei

ins Unterverzeichnis sfdl speichern 


## Starten
Download starten: 
```
./start.sh
```

Zum einfachen Starten des Scripts, folgender Inhalt in /usr/local/bin/sfdl speichern und ausführbar machen.
Anschliessend kann lediglich sfdl in einem Terminal eingegeben werden um den Loader zu starten.
```
#!/bin/bash
/home/DEIN_USERNAME/sfdl_bash_loader/start.sh # Hier Pfad zur start.sh anpassen!
```

## Kompatibilität (getestet)
-Linux  
