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
	^ (PipeableOSProcess
		command:
			'sudo iwlist ', anInterface name,  ' scan')
		output

]

{ #category : #'queries - basic' }
RaspbianWifiResolver class >> currentNetworkOf: anInterface [
	"The network anInterface currently connects to"
	|SSID MAC|	
	SSID := (PipeableOSProcess command:'sudo iwgetid ', anInterface name, ' --raw') output.
	MAC := (PipeableOSProcess command:'sudo iwgetid ', anInterface name, ' -a --raw') output.
	anInterface availableNetworks detect: [:one | one mac = MAC ] ifNone: nil
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

{ #category : #'queries - interface' }
RaspbianWifiResolver class >> powerOff: anInterface [
	"To truly turn the interface off, we need to both take down the interface, and turn wifi power off"
	^(PipeableOSProcess command:'sudo ifdown --force ', anInterface name) output isEmpty and: [(PipeableOSProcess command:'sudo iwconfig ', anInterface name, ' power off') output isEmpty]
]

{ #category : #'queries - interface' }
RaspbianWifiResolver class >> powerOn: anInterface [
	"Turn the interface on"
	^((PipeableOSProcess command:'sudo iwconfig ', anInterface name, ' power on') output isEmpty) and: [
	(PipeableOSProcess command:'sudo ifup --force ', anInterface name) output isEmpty]
]
