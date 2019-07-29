# WiFiChooser
Code to control WiFi interface from Pharo/Squeak

Implemented for Raspbian / OSX, using command line tools and OSProcess.

To load:
```smalltalk
Metacello new
	baseline: 'WiFiChooser';
	repository: 'github://rydier/WiFiChooser/repository';
	load.
```

To list available WiFi interfaces:
```smalltalk
WiFiInterface available.
```
To list discovered WiFi networks:
```smalltalk
"Networks discovered on all interfaces (cached)"
WiFiNetwork available.
"Networks discovered on all interfaces (refreshed)"
WiFiNetwork refreshAvailable.
```
To connect to a discovered network using tmp password:
```smalltalk
(WiFiNetwork named: 'MySSID') connectUsingPassword: 'MyPassword'.
```

For more details and example usages, see class comments.

Migrated from Monticello using https://github.com/peteruhnak/git-migration
