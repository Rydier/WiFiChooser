"
I am a network one can connect to.
Before connecting, my SSID, an the interface through which I am available,  must be set.
If I require a password to connect to, that has to be set as well.

There are two main usages when connecting;, depending on whether SSID is hidden or not: 
1) Pick the network with desired SSID from the WiFiNetwork available list, and modify as necessary (adding passwords etc.), then connect.

2) Resolve the active interface (WiFiInterface available), and create a WiFiNetwork instace on that  with the correct using one of the instance creation methods to pass along the correct SSID/password.
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
