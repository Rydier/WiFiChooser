"
I am the interface of methods used to find properties of WiFi interfaces and networks on a platform.

My subclasses implement the interface, if one wants a list of available networks,  the correct invocation is therefore:
WiFiResolver current availableNetworks
"
Class {
	#name : #WiFiResolver,
	#superclass : #Object,
	#classVars : [
		'Current'
	],
	#category : #WiFiChooser
}

{ #category : #queries }
WiFiResolver class >> availableInterfaces [
	^self subclassResponsibility
]

{ #category : #queries }
WiFiResolver class >> availableNetworks [
	"WiFiResolver current availableNetworks"
	^self subclassResponsibility
]

{ #category : #'platform dependent' }
WiFiResolver class >> current [
	^Current ifNil: [Current := 
		self subclasses 
			detect:[:one | one isCurrent ] 
			ifNone:[^self error: 'Unknown platform!']]
]

{ #category : #private }
WiFiResolver class >> isCurrent [
	^self subclassResponsibility
]
