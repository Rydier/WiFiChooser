"
I am a  wireless network interface on the machine.
Query available interfaces using
WiFiInterace available .

I can turn myself on or off, and provide facilities to manipulate the currently connected network.
"
Class {
	#name : #WiFiInterface,
	#superclass : #Object,
	#instVars : [
		'name',
		'availableNetworks'
	],
	#classVars : [
		'Available'
	],
	#category : #WiFiChooser
}

{ #category : #accessing }
WiFiInterface class >> available [
	^Available ifNil: [ self refreshAvailable ]
]

{ #category : #accessing }
WiFiInterface class >> availableNetworks [
	^WiFiResolver current availableNetworksOn: self
]

{ #category : #'instance creation' }
WiFiInterface class >> named: interfaceIdentifier [
	^self new initializeNamed: interfaceIdentifier
]

{ #category : #accessing }
WiFiInterface class >> refreshAvailable [
	^Available := WiFiResolver current availableInterfaces
]

{ #category : #comparing }
WiFiInterface >> = anotherInterface [
	^ self species = anotherInterface species and: [ name = anotherInterface name ]
]

{ #category : #accessing }
WiFiInterface >> availableNetworks [
	^WiFiResolver current availableNetworksOn: self
]

{ #category : #accessing }
WiFiInterface >> currentNetwork [
	^WiFiResolver current currentNetworkOf: self
]

{ #category : #comparing }
WiFiInterface >> hash [
	^name hash
]

{ #category : #'initalize-release' }
WiFiInterface >> initializeNamed: interfaceIdentifier [
	name := interfaceIdentifier
]

{ #category : #actions }
WiFiInterface >> isPoweredOn [
	^WiFiResolver current isPoweredOn: self
]

{ #category : #accessing }
WiFiInterface >> name [
	^name
]

{ #category : #accessing }
WiFiInterface >> niceName [
	^WiFiResolver current niceNameOf: self
]

{ #category : #actions }
WiFiInterface >> powerOff [
	^WiFiResolver current powerOff: self
]

{ #category : #actions }
WiFiInterface >> powerOn [
	^WiFiResolver current powerOn: self
]

{ #category : #printing }
WiFiInterface >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; nextPutAll: name; nextPut: $)
]
