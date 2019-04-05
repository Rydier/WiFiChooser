# WiFiChooser
Code to control WiFi interface from Pharo/Squeak

To load:
```smalltalk
Metacello new
	baseline: 'SSDP';
	repository: 'github://rydier/SSDP/repository';
	load.
```

Implemented for Raspbian / OSX, using command line tools and OSProcess.
Currently borken on latest version of OSX; since High Sierra removed the command we were using...

Migrated from Monticello using https://github.com/peteruhnak/git-migration
