"
I am a network one can connect to.
Before connecting, my SSID, an the interface through which I am available,  must be set.
If I require a password to connect to, that has to be set as well.

There are two main usages when connecting;, depending on whether SSID is hidden or not: 
1) Connect to a network with public SSID that is in the discovered list
	a) Pick the network with desired SSID from the WiFiNetwork available list, 
		modify as necessary, then connect.
	(WiFiNetwork availableNetworks detect: [ :one | one ssid = 'MyNetwork' ]) 
		password: 'MyPass'; 
		connect.
	b) Use the shorthand, and connect with a temporarily set password.
	(WiFiNetwork named: 'MyNetwork') connectUsingPassword: 'MyPass'.
2) Connect to a network with private SSID that is *not* in the discovered list
	- Resolve the interface to use, and create a WiFiNetwork instance on that interface with the correct using one of the instance creation methods to pass along the correct SSID/password.
	 (WiFiNetwork 
		interface: WiFiInterface available first
		ssid: 'MyNetwork') connectUsingPassword: 'MyPass'
"
Class {
	#name : #WiFiNetwork,
	#superclass : #Object,
	#instVars : [
		'interface',
		'ssid',
		'mac',
		'security',
		'password'
	],
	#classVars : [
		'AvailableNetworks'
	],
	#category : #WiFiChooser
}

{ #category : #accessing }
WiFiNetwork class >> available [
	^AvailableNetworks ifNil: [self refreshAvailable]
]

{ #category : #accessing }
WiFiNetwork class >> availableNoRefresh [
	^AvailableNetworks ifNil: [OrderedCollection new]
]

{ #category : #'instance creation' }
WiFiNetwork class >> interface: anInterface ssid: anSSID [ 
	^self interface: anInterface ssid: anSSID mac: nil security: nil password: nil
]

{ #category : #'instance creation' }
WiFiNetwork class >> interface: anInterface ssid: anSSID mac: aMAC [
	^self interface: anInterface ssid: anSSID mac: aMAC security: nil password: nil
]

{ #category : #'instance creation' }
WiFiNetwork class >> interface: anInterface ssid: anSSID mac: aMacAddress security: securityIdentifier [
	^self interface: anInterface ssid: anSSID mac:aMacAddress security: securityIdentifier password: nil
]

{ #category : #'instance creation' }
WiFiNetwork class >> interface: anInterface ssid: anSSID mac: aMacAddress security: securityIdentifier password: aPassword [
	^ self new
		initializeInterface: anInterface
		ssid: anSSID
		mac: aMacAddress
		security: securityIdentifier
		password: aPassword
]

{ #category : #'instance creation' }
WiFiNetwork class >> interface: anInterface ssid: anSSID password: aPassword [
	^self interface: anInterface ssid: anSSID mac: nil security: nil password: aPassword
]

{ #category : #'instance creation' }
WiFiNetwork class >> interface: anInterface ssid: anSSID security: securityIdentifier [
	^self interface: anInterface ssid: anSSID mac: nil security: securityIdentifier password: nil
]

{ #category : #'instance creation' }
WiFiNetwork class >> interface: anInterface ssid: anSSID security: securityIdentifier password: aPassword [
	^self interface:anInterface ssid: anSSID mac: nil security: securityIdentifier password: aPassword
]

{ #category : #'instance creation' }
WiFiNetwork class >> named: anSSID [
	"Return a network with the given SSID, if available" 
	^self available detect: [ :one | one ssid = anSSID ] ifNone: [ nil ]
]

{ #category : #accessing }
WiFiNetwork class >> refreshAvailable [
	^AvailableNetworks := WiFiResolver current availableNetworks
]

{ #category : #comparing }
WiFiNetwork >> = anotherNetwork [
	^self species = anotherNetwork species and:
		[self ssid = anotherNetwork ssid]
]

{ #category : #actions }
WiFiNetwork >> connect [
	ssid ifNil: [ ^self error: 'Cannot connect a network without SSID' ].
	interface ifNil:[^self error: 'Network interface to use must be resolved before connecting'].
	^WiFiResolver current connect: self
]

{ #category : #actions }
WiFiNetwork >> connectUsingPassword: aPassword [
	|storedPassword|
	ssid ifNil: [ ^self error: 'Cannot connect a network without SSID' ].
	interface ifNil:[^self error: 'Network interface to use must be resolved before connecting'].
	storedPassword := password.	
	[password := aPassword. 	
	WiFiResolver current connect: self] 
		ensure: [ password := storedPassword ]
]

{ #category : #actions }
WiFiNetwork >> disconnect [
	ssid ifNil: [ ^nil "Cannot disconnect a network without SSID" ].
	interface ifNil:[^nil "Must know which interface this network should no longer be connected through..."].
	^WiFiResolver current disconnect: self
]

{ #category : #comparing }
WiFiNetwork >> hash [
	^self ssid hash
]

{ #category : #'initialize - release' }
WiFiNetwork >> initializeInterface: anInterface ssid: anSSID mac: aMacAddress security: aSecurityDescriptor password: aPassword [
	interface := anInterface.
	ssid := anSSID.
	mac := aMacAddress.
	security := aSecurityDescriptor.
	password := aPassword
]

{ #category : #accessing }
WiFiNetwork >> interface [
	^interface
]

{ #category : #accessing }
WiFiNetwork >> mac [
	^mac
]

{ #category : #accessing }
WiFiNetwork >> password [
	^password
]

{ #category : #accessing }
WiFiNetwork >> password: aPassword [
	password := aPassword
]

{ #category : #printing }
WiFiNetwork >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '(', (ssid convertToEncoding: #utf8) ,')'
]

{ #category : #accessing }
WiFiNetwork >> security [
	^security
]

{ #category : #accessing }
WiFiNetwork >> ssid [
	^ssid
]
