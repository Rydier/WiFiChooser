"
I am the interface of methods used to find properties of WiFi interfaces and networks on a platform.

I am not meant for public use, but exist so WiFiInterface and WiFiNetwork can avoid having platform subclasses.

Even my subclasses should use those classes to do availablility queries, as they cache them, and avoid overhead associated with network scans compared to using self availableInterfaces/Networks.

If there are any other senders to those methods than refreshInterfaces/Networks, rewrite immediately.
"
Class {
	#name : #WiFiResolver,
	#superclass : #Object,
	#classVars : [
		'Current'
	],
	#category : #WiFiChooser
}

{ #category : #'queries - basic' }
WiFiResolver class >> availableInterfaces [
	^self subclassResponsibility
]

{ #category : #'queries - basic' }
WiFiResolver class >> availableNetworks [
	"Fetch the list of available wireless networks"

	^WiFiInterface available 
		inject: Set new 
		into: [:sub :interface |
			sub addAll: (self availableNetworksOn: interface); yourself].
]

{ #category : #'queries - interface' }
WiFiResolver class >> availableNetworksOn: anInterface [
	"Fetch the list of available wireless networks on the provided interface"
		^self subclassResponsibility
]

{ #category : #'queries - network' }
WiFiResolver class >> connect: aNetwork [
	^self subclassResponsibility
]

{ #category : #'platform dependent' }
WiFiResolver class >> current [
	^Current ifNil: [Current := 
		self subclasses 
			detect:[:one | one isCurrent ] 
			ifNone:[^self error: 'Unknown platform!']]
]

{ #category : #'queries - interface' }
WiFiResolver class >> currentNetworkOf: anInterface [
	"The network anInterface currently connects to"
	^self subclassResponsibility
]

{ #category : #'queries - network' }
WiFiResolver class >> disconnect: aNetwork [
	^self subclassResponsibility
]

{ #category : #private }
WiFiResolver class >> isCurrent [
	^self subclassResponsibility
]

{ #category : #'queries - interface' }
WiFiResolver class >> isPoweredOn: anInterface [
	"Is the interface currently on?"
	^self subclassResponsibility
]

{ #category : #'queries - interface' }
WiFiResolver class >> niceNameOf: anInterface [
	"A user-friendly descriptive name for anInterface"
	^self subclassResponsibility
]

{ #category : #'queries - interface' }
WiFiResolver class >> powerOff: anInterface [
	"Turn the interface off"
	^self subclassResponsibility
]

{ #category : #'queries - interface' }
WiFiResolver class >> powerOn: anInterface [
	"Turn the interface on"
	^self subclassResponsibility
]
