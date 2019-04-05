Class {
	#name : #BaselineOfWiFiChooser,
	#superclass : #BaselineOf,
	#category : #BaselineOfWiFiChooser
}

{ #category : #baseline }
BaselineOfWiFiChooser >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 	spec project: 'OSProcess' with: [
				spec
					className: #ConfigurationOfOSProcess;
					versionString: #'stable';
					repository: 'http://squeaksource.com/OSProcess' ]..
			spec package: 'WiFiChooser' with: [ spec requires: 'OSProcess' ].
			spec group: 'default' with: #('WiFiChooser') ]
]
