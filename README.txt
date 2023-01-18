# mydealz-alerter
powershell script with custom notifications for mydealz keywords\

### SCHNELLINSTALLATION
Öffne die .ps1 datei mit einem Texteditor.\
Bearbeite die $searchwords (Suchbegriffe) sodass sie deinen Präferenzen entsprechen.\
Die Suchbegriffe sollten von sternchen (*) und anführungszeichen (") umschlossen sein und durch kommas getrennt werden, also genau wie es dort schon beispielhaft gezeigt ist.\
Wenn du einen zweiten Bildschirm hast, ändere die variable $monitor auf 2\
Speichere das script und führe es via Rechtsklick -> "Mit Powershell ausführen" aus.\



### ADVANCED CONFIGURATION
make sure to set up your searchwords in line 4 of the script\
it's using powershell's "-like" syntax\
basically put your search word in between asterisks (*)\
as an example i've set up the script with 3 searchwords already.

also you might need to configure on what screen it will be shown. by default it's on the first screen.\
you can fine-tune the position by additionally changing the $posX and $posY variables.\
the $boxHeight and $boxWidth of the alerts is adjustable too.\
the $flowDirection variable determines whether additional notifications will be shown below or above.\
the $throttle variable determines how long the script will sleep in between queries (no idea if they ban your ip if you query the server too often)\
you can change the $sound to your liking. disabling the sound entirely is not implemented, you'd need to delete line 148 for that.

### ADDITIONAL INFO
Any mousclick will dismiss the notification, but a click with the middle button will take you to the deal's homepage


[screenshot](https://imgur.com/a/XRINjZi)
![screenshot](https://i.imgur.com/FZrnjVW.png)
