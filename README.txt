# mydealz-alerter
powershell script with custom notifications for mydealz keywords

### SCHNELLINSTALLATION
Öffne die .ps1 datei mit einem Texteditor.
Bearbeite die $searchwords (Suchbegriffe) sodass sie deinen Präferenzen entsprechen.
Die Suchbegriffe sollten von Sternchen (*) und Anführungszeichen (") umschlossen sein und durch kommas getrennt werden, also genau wie es dort schon beispielhaft gezeigt ist.
Wenn du einen zweiten Bildschirm hast, ändere die Variable $monitor auf 2
Speichere das Script und führe es via Rechtsklick -> "Mit Powershell ausführen" aus.
Wenn ein Deal gefunden wurde, kannst du die Benachrichtigung mit einem Linksklick schließen oder mit der mittleren Maustaste direkt auf die Seite des Deals gelangen.



### ADVANCED CONFIGURATION
make sure to set up your searchwords in line 4 of the script
it's using powershell's "-like" syntax
basically put your search word in between asterisks (*)
as an example i've set up the script with 4 searchwords already.

also you might need to configure on what $monitor it will be shown. by default it's on the first screen.
you can fine-tune the position by additionally changing the $posX and $posY variables.
the $boxHeight and $boxWidth of the alerts is adjustable too.
the $flowDirection variable determines whether additional notifications will be shown below or above.
the $throttle variable determines how long the script will sleep in between checking for new deals
you can change the $sound to your liking. disabling the sound entirely is not implemented, you'd need to delete line 195 which includes "(New-Object Media.SoundPlayer $sound).Play();" for that.
you can also search the vendorName or Description, change those variables to $true if you want this.

### ADDITIONAL INFO
Any mousclick will dismiss the notification, but a click with the middle button will take you to the deal's homepage


[screenshot] https://imgur.com/a/XRINjZi
