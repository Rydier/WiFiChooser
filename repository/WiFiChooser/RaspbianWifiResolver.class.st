"
Do wireless network manipulation on Raspbian. 
Probably also works on some other *nix's, but not tested.

Currently implemented as a shim around command line programs, so changes between OSX version due to changes in command output must be expected.

"
Class {
	#name : #RaspbianWifiResolver,
	#superclass : #WiFiResolver,
	#category : #WiFiChooser
}

{ #category : #'queries - basic' }
RaspbianWifiResolver class >> availableInterfaces [
	"Fetch the list of available wireless networks"
	| interfaces|
	interfaces := OrderedCollection new.
	(PipeableOSProcess command: 'sudo ifconfig ') output
	linesDo: [ :each | |possibleWirelessName|
		possibleWirelessName := each copyUpTo: Character space.
		possibleWirelessName isEmpty ifFalse: [|powerInfo|
			powerInfo := (PipeableOSProcess command: 'sudo iwlist ', possibleWirelessName, ' power') output.
			powerInfo isEmpty
				ifFalse: [interfaces add: (WiFiInterface named: possibleWirelessName)]
			]].
	^interfaces
]

{ #category : #'queries - basic' }
RaspbianWifiResolver class >> availableNetworksOn: anInterface [
	"Fetch the list of available wireless networks on the provided interface"
	|output retries success|
	retries := 10.
	success := false.
	[output := (PipeableOSProcess
		command:
			'sudo iwlist ', anInterface name,  ' scan | grep ''Address\|Quality\|SSID\|Encryption\|WPA\|Authentication\|Device ''')
		output.
	 retries > 0 and: [(success := (output indexOfSubCollection: 'Device or resource busy') = 0) not]] whileTrue: [0.5 seconds wait.
	retries := retries - 1].
	success ifFalse: [^self error: 'Interface unavailable'].
	
	^ self parseNetworks: output on: anInterface

]

{ #category : #'queries - network' }
RaspbianWifiResolver class >> connect: aNetwork [
	aNetwork security ifNotNil: [:sec | 
		(sec indexOfSubCollection: 'WPA') > 0 
			ifTrue: [(sec indexOfSubCollection: '802.1x') > 0
				ifTrue:[^UnsupportedEncryption new 
						messageText: 'Does not know how to connect to Enterprise WPA networks'; 
						signal]]].
	^self connectWPA: aNetwork
		"ifFalse: [self connectBasic: aNetwork] "
]

{ #category : #'queries - private' }
RaspbianWifiResolver class >> connectWPA: aNetwork [
	"On the Pi, WPA networks are handled using wpa_supplicant.
	Assume all our wifi interfaces are set to be configurable using wpa_cli.
	
	The general flow:
	1) Check if aNetwork is in list of managed networks, if not, add it.
	2) Select network
	3) Wait untill aNetwork is current, report success."
	| connectID credentializedNetworks currentNetwork parsedNetworks setPWD enableConnect |
	credentializedNetworks := (PipeableOSProcess command:'wpa_cli -i ', aNetwork interface name, ' list_networks') output.
	"Don't include header"
	parsedNetworks := credentializedNetworks lines allButFirst collect: [:each | each splitBy: Character tab asString].
	currentNetwork := parsedNetworks detect: [:one | one last = '[CURRENT]'] ifNone: [nil].
	"Part 1"
	(credentializedNetworks indexOfSubCollection: aNetwork ssid) = 0 ifTrue: [ | setSSID |
		"add network as new, fetch new id (without terminating newline)"
		connectID := (PipeableOSProcess command:'wpa_cli -i ', aNetwork interface name, ' add_network') output allButLast.
		"Yes, that is the proper quoting around ssid and psk, ref 
		https://www.raspberrypi.org/forums/viewtopic.php?f=36&t=95084"
		setSSID := (PipeableOSProcess 
			command:'wpa_cli -i ', aNetwork interface name, ' set_network ', connectID , ' ssid ''"', aNetwork ssid , '"''')
			output.
		] ifFalse: [connectID := (parsedNetworks detect: [:one | one second = aNetwork ssid]) first ].
	setPWD := (PipeableOSProcess command: 'wpa_cli -i ', aNetwork interface name, ' set_network ', connectID , ' psk ''"', aNetwork password, '"''') output.

	"Part 2"
	enableConnect := (PipeableOSProcess command: 'wpa_cli -i ', aNetwork interface name, ' select_network ', connectID) output.
	enableConnect := (PipeableOSProcess command: 'wpa_cli -i ', aNetwork interface name, ' disable_network ', connectID) output.
	enableConnect := (PipeableOSProcess command: 'wpa_cli -i ', aNetwork interface name, ' enable_network ', connectID) output.

	"Part 3"
	"Need to detect when selection fails, lookup reason, etc."
	"Cheat for now"
	^self connectedTo: aNetwork within: 5 seconds.
	
	
]

{ #category : #'queries - private' }
RaspbianWifiResolver class >> connectedTo: aNetwork within: aTimeLimit [
	|timeout success seenStatuses answered connected |
	success := false.
	seenStatuses := OrderedCollection new.
	timeout  := DateAndTime now + aTimeLimit.

	[
	50 milliSeconds wait.
	connected := (PipeableOSProcess command:'wpa_cli -i ', aNetwork interface name, ' status') output.
	
	success := (connected indexOfSubCollection: aNetwork ssid) > 0 
		    and: [(connected indexOfSubCollection: 'wpa_state=COMPLETED') > 0].
	success not and: [DateAndTime now < timeout ]] whileTrue: [
	seenStatuses add: connected].
	answered := DateAndTime now.
success ifFalse: ["If we at least tried to connect, credentials were probably wrong"
	(seenStatuses includes: [: one | 
		(one indexOfSubCollection: 'wpa_state=4WAY_HANDSHAKE') > 0])
			ifTrue: [IncorrectCredentials new signal]
			ifFalse: [NetworkUnavailable new signal]].
	^success
]

{ #category : #'queries - basic' }
RaspbianWifiResolver class >> currentNetworkOf: anInterface [
	"The network anInterface currently connects to"
	|SSID|	
	SSID := (PipeableOSProcess command:'sudo iwgetid ', anInterface name, ' --raw') output trim.
	^SSID isEmpty ifFalse: [ |MAC|
		MAC := (PipeableOSProcess command:'sudo iwgetid ', anInterface name, ' -a --raw') output.
		MAC := ByteArray readHexFrom: (MAC trim select: [:each | each ~= $: ]).
		WiFiNetwork interface: anInterface ssid: SSID mac: MAC]
]

{ #category : #private }
RaspbianWifiResolver class >> isCurrent [
	"This is the platform name currently returned by Squeak on Raspbian"
	^Smalltalk os platformName = 'unix'
	
]

{ #category : #'queries - interface' }
RaspbianWifiResolver class >> isPoweredOn: anInterface [
	"To be considered on, both the interface must be up, and power must be on"
	^(PipeableOSProcess command: 'sudo ifquery --state ' , anInterface name) output 
		isEmpty not and: 
	[(PipeableOSProcess command: 'sudo iwlist ' , anInterface name, ' power') output 
		endsWith: 'on', String lf, String lf]
]

{ #category : #'queries - interface' }
RaspbianWifiResolver class >> niceNameOf: anInterface [
	"A user-friendly descriptive name for anInterface"
	^self subclassResponsibility
]

{ #category : #'queries - private' }
RaspbianWifiResolver class >> parseNetwork: stream on: anInterface [
	"Parse the next structure of form:
	Cell 04 - Address: D4:D9:19:10:97:D6
                    Quality=70/70  Signal level=-25 dBm  
                    Encryption key:on
                    ESSID:""veloxpro3p1""
                    IE: IEEE 802.11i/WPA2 Version 1
                        Authentication Suites (1) : PSK"
	"It ain't pretty, but it gets the job done"
	|line ix pos ssid mac encryptionOn securityIdentifier|
	securityIdentifier := ''.
	pos := stream position.
	"Make sure we align with the start of a new entry"
	[stream atEnd ifTrue: [^nil].
	line := stream nextLine.
	ix := line indexOfSubCollection: 'Address: ' .
	ix = 0 and: [stream atEnd not]] whileTrue.
	
	"MAC is expected as byteArray"
	mac := ByteArray readHexFrom: ((line copyFrom: ix + 9 to: line size) select: [:each | each ~= $:]). 
	"Read remaining properties, then reset"
	[pos := stream position.
	line := stream nextLine.
	line notNil and: [ix := line indexOfSubCollection: 'Address: ' .
	ix = 0 ]] whileTrue: [
		(ix := line indexOfSubCollection: 'ESSID:') > 0 
			ifTrue: ["Without enclosing quotes"
				ssid := line copyFrom: ix + 7 to: line size - 1].
		"Format on Mac: 'WPA(PSK/TKIP, AES/TKIP) WPA2(PSK/TKIP,AES/TKIP)
		Should restructure to generate identical array of supported types, but for now we just need the
		authentication method"
		(ix := line indexOfSubCollection: 'Encryption key:') > 0 
			ifTrue:	 [encryptionOn := line endsWith: 'on' ].
		(ix := line indexOfSubCollection: 'IE: IEEE 802.11i/WPA2') > 0 
			ifTrue: [securityIdentifier :=  securityIdentifier, 'WPA2' ].	
		(ix := line indexOfSubCollection: 'IE: WPA Version 1') > 0 
			ifTrue:	 [securityIdentifier := securityIdentifier,  'WPA' ].	
		(ix := line indexOfSubCollection: 'Authentication Suites') > 0 
			ifTrue: [securityIdentifier := securityIdentifier, '(',(line copyFrom: (line lastIndexOf: Character space) + 1  to: line size), ') '].	
		].
	encryptionOn 
		ifTrue: [securityIdentifier isEmpty ifTrue: [securityIdentifier := 'WEP']]
		ifFalse: [securityIdentifier := 'NONE'].
	
	(stream atEnd) ifFalse: [
		stream position: pos].
		
	^WiFiNetwork interface: anInterface ssid: ssid mac: mac security: securityIdentifier
	
	
]

{ #category : #'queries - private' }
RaspbianWifiResolver class >> parseNetworks: aString [
|currentNetwork networks stream |
	networks := OrderedCollection new.
	currentNetwork := nil.
	stream := aString readStream.
	[((self parseNetwork: stream) ifNotNil: [:network | networks add: network]) notNil ] whileTrue.
	^networks

]

{ #category : #'queries - private' }
RaspbianWifiResolver class >> parseNetworks: aString on: anInterface [
|currentNetwork networks stream |
	networks := OrderedCollection new.

	currentNetwork := nil.
	stream := aString readStream.
	[((self parseNetwork: stream on: anInterface) ifNotNil: [:network | networks add: network]) notNil ] whileTrue.
	^networks

]

{ #category : #'queries - interface' }
RaspbianWifiResolver class >> powerOff: anInterface [
	"To truly turn the interface off, we need to both take down the interface, and turn wifi power off"
	^(PipeableOSProcess command:'sudo ifdown --force ', anInterface name) output isEmpty and: [(PipeableOSProcess command:'sudo iwconfig ', anInterface name, ' power off') output isEmpty]
]

{ #category : #'queries - interface' }
RaspbianWifiResolver class >> powerOn: anInterface [
	"Turn the interface on"
	^((PipeableOSProcess command:'sudo iwconfig ', anInterface name, ' power on') output isEmpty) "and: [
	(PipeableOSProcess command:'sudo ifup --force ', anInterface name) output isEmpty]"
]

{ #category : #'queries - private' }
RaspbianWifiResolver class >> update: aNetwork with: aLine [
	| network |
.
	network := aNetwork 
		ifNil: []
		ifNotNil: [].
		
	^network
]
