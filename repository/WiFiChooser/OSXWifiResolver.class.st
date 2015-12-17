"
Do wireless network manipulation on OSX. 
Currently implemented as a shim around command line programs, so changes between OSX version due to changes in command output must be expected.
"
Class {
	#name : #OSXWifiResolver,
	#superclass : #WiFiResolver,
	#category : #WiFiChooser
}

{ #category : #'queries - basic' }
OSXWifiResolver class >> availableInterfaces [
	"Fetch the list of available wireless networks"

	|  possibleInterfaces availableInterfaces |
	possibleInterfaces := Set new.
	(PipeableOSProcess command: 'ifconfig') output
		linesDo: [ :each | 
			| ix "all interfaces have their names first on a line, followed by :.
Do early discard of lines that have spaces before :, so we can strip the rest using beginsWith:" |
			((ix := each indexOf: $:) > 0 and: [ (each indexOf: Character space) > ix ])
				ifTrue: [ possibleInterfaces add: (each first: ix - 1) trimBoth ] ].
	availableInterfaces := possibleInterfaces
		select: [ :each | 
			"Error message: <each> is not a Wi-Fi interface.
Correct message: Wi-Fi Power (<each>): On"
			((PipeableOSProcess command: 'networksetup -getairportpower ' , each) output beginsWith: each) not ].
	^ availableInterfaces collect: [ :networkName | WiFiInterface named: networkName ]
]

{ #category : #'queries - basic' }
OSXWifiResolver class >> availableNetworks [
	"Fetch the list of available wireless networks"

	| list availableNetworks offsets header |
		availableNetworks := Set new.
	WiFiInterface available do:[:interface |

	list := ((PipeableOSProcess
		command: '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport ', interface name, ' -s') output) lines asOrderedCollection.
	list ifNotEmpty: [  
		header := list removeFirst]
		ifEmpty: [^self error: 'No available networks.  Is WIFI on?' ].

	offsets := self parseOffsets:header .
	list do: [ :each | (self netFromInfo: each offsets: offsets on: interface) ifNotNil:[:network | availableNetworks add: network] ]].
	^ availableNetworks 
]

{ #category : #'queries - network' }
OSXWifiResolver class >> connect: aNetwork [
	^ (PipeableOSProcess
		command:
			'networksetup -setairportnetwork ' , aNetwork interface name , ' ' , aNetwork ssid , ' ' , aNetwork password )
		output
]

{ #category : #'queries - interface' }
OSXWifiResolver class >> currentNetworkOf: anInterface [
| tokens ssid |
tokens :=  (PipeableOSProcess
		command:
			'networksetup -getairportnetwork ' , anInterface name)
		output findTokens: Character space.
		ssid := tokens last trimBoth.
		^WiFiNetwork available detect: [:one | one ssid = ssid and: [ one interface = anInterface ] ] ifNone: nil
		 
]

{ #category : #private }
OSXWifiResolver class >> isCurrent [
	^Smalltalk platform isMacOSX
]

{ #category : #'queries - interface' }
OSXWifiResolver class >> isPoweredOn: anInterface [
	^(PipeableOSProcess command: 'networksetup -getairportpower ' , anInterface name) output endsWith: 'ON'
]

{ #category : #'queries - private' }
OSXWifiResolver class >> netFromInfo: anInfoLine offsets: fieldOffsets on: anInterface [
	|  ssid mac security |
	"SSID BSSID RSSI CHANNEL HT CC SECURITY"
	ssid := (anInfoLine copyFrom: (fieldOffsets at:1) to: (fieldOffsets at:2) -1) trimBoth.
	mac := (anInfoLine copyFrom: (fieldOffsets at:2) to: (fieldOffsets at:3) -1) trimBoth.
	mac := ByteArray readHexFrom: (mac select: [:each | each ~= $: ]).
	security := (anInfoLine copyFrom: (fieldOffsets at:7) to: anInfoLine size) trimBoth.

	^WiFiNetwork interface: anInterface ssid: ssid mac: mac security: security
]

{ #category : #'queries - private' }
OSXWifiResolver class >> netFromInfo: anInfoLine on: anInterface [
	| tokens |
	"SSID BSSID             RSSI CHANNEL HT CC SECURITY (auth/unicast/group)"
	tokens := anInfoLine trimBoth findTokens: Character space.
	"Ugh, header"
	^tokens first = 'SSID' ifFalse:[|mac|
		mac := ByteArray readHexFrom: (tokens second select: [:each | each ~= $: ]).
			
		WiFiNetwork interface: anInterface ssid: tokens first mac: mac security: tokens last]
]

{ #category : #'queries - interface' }
OSXWifiResolver class >> niceNameOf: anInterface [
	| allInfoReversed ix start |
	allInfoReversed := (PipeableOSProcess command:'networksetup -listallhardwareports') output reversed. ix := allInfoReversed indexOfSubCollection: anInterface name reversed startingAt:1.
	ix := allInfoReversed indexOf: $:startingAt: ix.
	start := allInfoReversed indexOfAnyOf: CharacterSet crlf startingAt: ix.
	ix := allInfoReversed indexOf: $:startingAt: ix +1.
	^(allInfoReversed copyFrom: start +1 to: ix-1) reversed trimBoth
]

{ #category : #'queries - private' }
OSXWifiResolver class >> parseOffsets: aHeaderLine [
	"Fields are aligned with header:
SSID BSSID RSSI CHANNEL HT CC SECURITY
Return offsets for each"

	| offsets pastFirstItem inItem |
	offsets := OrderedCollection with: 1.
	pastFirstItem := false.
	inItem := false.
	aHeaderLine
		withIndexDo: [ :char :index | 
			(char ~= Character space and: [ inItem not ])
				ifTrue: [ 
					pastFirstItem
						ifTrue: [ offsets add: index ]
						ifFalse: [ pastFirstItem := true ].
					inItem := true ].
				(inItem and:[char = Character space]) ifTrue: [ inItem := false ] ].
	^offsets
]

{ #category : #'queries - interface' }
OSXWifiResolver class >> powerOff: anInterface [
	^(PipeableOSProcess command:'networksetup -setairportpower ', anInterface name , ' off') output
]

{ #category : #'queries - interface' }
OSXWifiResolver class >> powerOn: anInterface [
	^(PipeableOSProcess command:'networksetup -setairportpower ', anInterface name , ' on') output
]
