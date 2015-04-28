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
		'name'
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

{ #category : #'instance creation' }
WiFiInterface class >> named: interfaceIdentifier [
	^self new initializeNamed: interfaceIdentifier
]

{ #category : #accessing }
WiFiInterface class >> refreshAvailable [
	^Available := WiFiResolver current availableInterfaces
]

{ #category : #'initalize-release' }
WiFiInterface >> initializeNamed: interfaceIdentifier [
	name := interfaceIdentifier
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
WiFiInterface >> turnOff [
	^WiFiResolver current turnOff: self
]

{ #category : #actions }
WiFiInterface >> turnOn [
	^WiFiResolver current turnOn: self
]
