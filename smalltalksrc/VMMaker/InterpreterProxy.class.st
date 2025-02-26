"
This class should provide the definition of what interpreter support plugins need and can have access to. Note that the proxy related files platforms - Cross - vm - sqVirtualMachine.[ch] are kept under the git tree at http://www.github.com/opensmalltalk/vm.
The main use of the class is to support the vm simulator and the RSqueak VM, which implements as many primitives as possible in Smalltalk.
"
Class {
	#name : #InterpreterProxy,
	#superclass : #Object,
	#instVars : [
		'primFailCode',
		'remapBuffer',
		'stack',
		'method',
		'argumentCount',
		'bb',
		'thisSessionID',
		'osErrorCode',
		'exceptionPC'
	],
	#pools : [
		'VMBasicConstants'
	],
	#category : #'VMMaker-InterpreterSimulation'
}

{ #category : #translation }
InterpreterProxy class >> implicitReturnTypeFor: aSelector [
	"Answer the return type for methods that don't have an explicit return."
	^#sqInt
]

{ #category : #private }
InterpreterProxy class >> validateProxyImplementation: anInterpreter [ 
	"InterpreterProxy validateProxyImplementation: Interpreter"

	| proxyClass catList |
	proxyClass := InterpreterProxy.
	catList := proxyClass organization categories copy asOrderedCollection.
	catList remove: 'initialize' ifAbsent:[].
	catList remove: 'private' ifAbsent:[].
	catList do:[:categ|
		(proxyClass organization listAtCategoryNamed: categ) do:[:selector|
			(anInterpreter canUnderstand: selector) 
				ifFalse:
					[self notifyWithLabel: selector, ' is not implemented in ', anInterpreter name]]]
]

{ #category : #'object access' }
InterpreterProxy >> argumentCountOf: methodPointer [
	^methodPointer numArgs
]

{ #category : #'object access' }
InterpreterProxy >> arrayValueOf: oop [
	<returnTypeC: 'void *'>
	self success: (self isWordsOrBytes: oop).
	^CArrayAccessor on: oop.
]

{ #category : #other }
InterpreterProxy >> become: array1 with: array2 [
	<returnTypeC: #sqInt>
	array1 elementsExchangeIdentityWith: array2
]

{ #category : #converting }
InterpreterProxy >> booleanValueOf: obj [
	obj == true ifTrue:[^true].
	obj == false ifTrue:[^false].
	self primitiveFail.
	^nil
]

{ #category : #private }
InterpreterProxy >> byteAt: accessor [
	^accessor byteAt: 0
]

{ #category : #private }
InterpreterProxy >> byteAt: accessor put: value [
	^accessor byteAt: 0 put: value
]

{ #category : #private }
InterpreterProxy >> byteAtPointer: accessor [
	^ self byteAt: accessor
]

{ #category : #'object access' }
InterpreterProxy >> byteSizeOf: oop [
	"Return the size of the receiver in bytes"
	^oop class isBits
		ifTrue: [oop basicSize * oop class elementSize]
		ifFalse: [(self slotSizeOf: oop) * Smalltalk wordSize]
]

{ #category : #other }
InterpreterProxy >> byteSwapped32IfBigEndian: anInteger [
	"Note: for simulation only.
	This message is not generated in C but replaced with a macro"
	<doNotGenerate>
	self vmEndianness = 1 ifTrue: [^anInteger byteSwap32].
	^anInteger
]

{ #category : #other }
InterpreterProxy >> byteSwapped64IfBigEndian: anInteger [
	"Note: for simulation only.
	This message is not generated in C but replaced with a macro"
	<doNotGenerate>
	self vmEndianness = 1 ifTrue: [^anInteger byteSwap64].
	^anInteger
]

{ #category : #testing }
InterpreterProxy >> cStringOrNullFor: oop [
	"Answer either a malloced string with the null-terminated contents of oop if oop is a string,
	 or the null pointer if oop is nil, or fail.  It is the client's responsibility to free the string later."
	<returnTypeC: #'char *'>
	oop isString ifTrue: [^oop] ifFalse: [self primitiveFail. ^0]
]

{ #category : #'callback support' }
InterpreterProxy >> callbackLeave: cbID [
	"Leave from a previous callback"
	^self notYetImplementedError
]

{ #category : #'object access' }
InterpreterProxy >> characterObjectOf: characterCode [
	<option: #(atLeastVMProxyMajor:minor: 1 13)>
	^StackInterpreter objectMemoryClass characterObjectOf: characterCode
]

{ #category : #'object access' }
InterpreterProxy >> characterValueOf: aCharacter [
	<option: #(atLeastVMProxyMajor:minor: 1 13)>
	^aCharacter asInteger
]

{ #category : #converting }
InterpreterProxy >> checkedIntegerValueOf: intOop [
	(self isIntegerObject: intOop)
		ifTrue:[^self integerValueOf: intOop]
		ifFalse:[self primitiveFail. ^0].
]

{ #category : #'special classes' }
InterpreterProxy >> classArray [
	^Array
]

{ #category : #'special classes' }
InterpreterProxy >> classBitmap [
	^Bitmap
]

{ #category : #'special classes' }
InterpreterProxy >> classByteArray [
	^ByteArray
]

{ #category : #'special classes' }
InterpreterProxy >> classCharacter [
	^Character
]

{ #category : #'FFI support' }
InterpreterProxy >> classExternalAddress [
	^Smalltalk at: #ExternalAddress ifAbsent:[nil]
]

{ #category : #'special classes' }
InterpreterProxy >> classFloat [
	^Float
]

{ #category : #'special classes' }
InterpreterProxy >> classLargeNegativeInteger [
	^LargeNegativeInteger
]

{ #category : #'special classes' }
InterpreterProxy >> classLargePositiveInteger [
	^LargePositiveInteger
]

{ #category : #'special classes' }
InterpreterProxy >> classPoint [
	^Point
]

{ #category : #'special classes' }
InterpreterProxy >> classSemaphore [
	^Semaphore
]

{ #category : #'special classes' }
InterpreterProxy >> classSmallInteger [
	^SmallInteger
]

{ #category : #'special classes' }
InterpreterProxy >> classString [
	^ByteString
]

{ #category : #'instance creation' }
InterpreterProxy >> clone: oop [
	^oop shallowCopy
]

{ #category : #'BitBlt support' }
InterpreterProxy >> copyBits [
	<returnTypeC: #sqInt>
	bb copyBits
]

{ #category : #'BitBlt support' }
InterpreterProxy >> copyBitsFrom: leftX to: rightX at: yValue [
	<returnTypeC: #sqInt>
	bb copyBitsFrom: leftX to: rightX at: yValue.
]

{ #category : #'special objects' }
InterpreterProxy >> displayObject [
	^Display
]

{ #category : #other }
InterpreterProxy >> failed [

	^primFailCode ~= 0
]

{ #category : #'special objects' }
InterpreterProxy >> falseObject [
	^false
]

{ #category : #'object access' }
InterpreterProxy >> fetchArray: fieldIndex ofObject: objectPointer [
	"Fetch the instance variable at the given index of the given object. Return the address of first indexable field of resulting array object, or fail if the instance variable does not contain an indexable bytes or words object."
	"Note: May be called by translated primitive code."

	| arrayOop |
	<returnTypeC: 'void *'>
	arrayOop := self fetchPointer: fieldIndex ofObject: objectPointer.
	^ self arrayValueOf: arrayOop

]

{ #category : #'object access' }
InterpreterProxy >> fetchClassOf: oop [
	^oop class
]

{ #category : #'object access' }
InterpreterProxy >> fetchFloat: fieldIndex ofObject: objectPointer [
	"Fetch the instance variable at the given index of the given object. Return the C double precision floating point value of that instance variable, or fail if it is not a Float."
	"Note: May be called by translated primitive code."

	| floatOop |
	<returnTypeC: 'double'>
	floatOop := self fetchPointer: fieldIndex ofObject: objectPointer.
	^ self floatValueOf: floatOop
]

{ #category : #'object access' }
InterpreterProxy >> fetchInteger: fieldIndex ofObject: objectPointer [
	"Note: May be called by translated primitive code."

	| intOop |
	<inline: false>
	intOop := self fetchPointer: fieldIndex ofObject: objectPointer.
	^self checkedIntegerValueOf: intOop
]

{ #category : #private }
InterpreterProxy >> fetchIntegerOrTruncFloat: fieldIndex ofObject: objectPointer [
	"Support for BitBlt simulation only"
	| intOrFloat |
	intOrFloat := self fetchPointer: fieldIndex ofObject: objectPointer.
	(self isIntegerObject: intOrFloat) ifTrue: [^ self integerValueOf: intOrFloat].
	intOrFloat isFloat ifTrue:[^intOrFloat truncated].
	^self primitiveFail.
]

{ #category : #'object access' }
InterpreterProxy >> fetchLong32: fieldIndex ofObject: oop [
"fetchWord:ofObject: is rescinded as of VMMaker 3.8 64bit VM. This is the same code as used therein and may need revision for 64 bit cleanliness"
	^oop instVarAt: fieldIndex+1
]

{ #category : #'object access' }
InterpreterProxy >> fetchPointer: index ofObject: oop [
	^oop instVarAt: index+1
]

{ #category : #'object access' }
InterpreterProxy >> firstFixedField: oop [
	<returnTypeC:'void *'>
	^CObjectAccessor on: oop
]

{ #category : #'object access' }
InterpreterProxy >> firstIndexableField: oop [
	<returnTypeC:'void *'>
	^CArrayAccessor on: oop
]

{ #category : #'stack access' }
InterpreterProxy >> floatArg: offset [
	"Like #stackFloatValue: but access method arguments left-to-right"
	"Obsolete; was never used; replaced with methodReturnString: in the VirtualMachine struct."
	| oop |
	<returnTypeC: #double>
	self deprecated.
	oop := self methodArg: offset.
	(self isFloatObject: oop) ifFalse: [self primitiveFail. ^0.0].
	^oop
]

{ #category : #converting }
InterpreterProxy >> floatObjectOf: aFloat [
	<returnTypeC: #sqInt> "...because answering the float argument causes the type inferencer to say this answers a float."
	<var: #aFloat type: #double>
	aFloat isFloat ifFalse: [self error:'Not a float object'].
	^aFloat
]

{ #category : #converting }
InterpreterProxy >> floatValueOf: oop [
	<returnTypeC:'double'>
	oop isFloat
		ifTrue:[^oop]
		ifFalse:[self primitiveFail. ^0.0].
]

{ #category : #other }
InterpreterProxy >> fullGC [
	<returnTypeC: #sqInt>
	Smalltalk garbageCollect
]

{ #category : #'special objects' }
InterpreterProxy >> getDeferDisplayUpdates [
	^false
]

{ #category : #other }
InterpreterProxy >> getStackPointer [
	<returnTypeC: #'sqInt *'>
	^self notYetImplementedError
]

{ #category : #other }
InterpreterProxy >> getThisSessionID [
	"Answer a session identifier which represents the current instance of Squeak.
	The identifier is expected to be unique among all instances of Squeak on a
	network at any point in time."

	[thisSessionID = 0]
		whileTrue:
			[thisSessionID := (Random new next * (SmallInteger maxVal min: 16rFFFFFFFF)) asInteger].
	^ thisSessionID
]

{ #category : #testing }
InterpreterProxy >> includesBehavior: aClass ThatOf: aSuperclass [
	^aClass includesBehavior: aSuperclass
]

{ #category : #initialize }
InterpreterProxy >> initialize [
	primFailCode := 0.
	remapBuffer := OrderedCollection new.
	stack := OrderedCollection new.
]

{ #category : #'object access' }
InterpreterProxy >> instanceSizeOf: classObj [
	^classObj instSize
]

{ #category : #'instance creation' }
InterpreterProxy >> instantiateClass: classPointer indexableSize: size [
	^size = 0 
		ifTrue:[classPointer basicNew]
		ifFalse:[classPointer basicNew: size]
]

{ #category : #'stack access' }
InterpreterProxy >> integerArg: offset [
	"Like #stackIntegerValue: but access method arguments left-to-right"
	"Obsolete; was never used; replaced with methodReturnInteger: in the VirtualMachine struct."
	| oop |
	self deprecated.
	oop := self methodArg: offset.
	(self isIntegerObject: oop) ifFalse: [self primitiveFail. ^0].
	^oop
]

{ #category : #converting }
InterpreterProxy >> integerObjectOf: value [
	value class == SmallInteger ifFalse:[self error:'Not a SmallInteger object'].
	^value
]

{ #category : #converting }
InterpreterProxy >> integerValueOf: oop [
	oop class == SmallInteger ifFalse:[self error:'Not a SmallInteger'].
	^oop
]

{ #category : #converting }
InterpreterProxy >> ioFilename: aCharBuffer fromString: aFilenameString ofLength: filenameLength resolveAliases: aBoolean [
	<var: #aCharBuffer type: #'char *'>
	<var: #aFilenameString type: #'char *'>
	"the vm has to convert aFilenameString via any canonicalization and char-mapping and put the result in aCharBuffer. This doesn't translate well in Smalltalk since we know how long strings are rather than considering them terminated by a 0 char. Do the best we can.
Note the resolveAliases flag - this is an awful artefact of OSX and Apples demented alias handling. When opening a file, the flag must be  true, when closing or renaming it must be false. Sigh."
	aCharBuffer replaceFrom:1 to: filenameLength with: aFilenameString
]

{ #category : #'FFI support' }
InterpreterProxy >> ioLoadFunction: functionName From: moduleName [
	<returnTypeC: #'void *'>
	<var: #functionName type: #'char *'>
	<var: #moduleName type: #'char *'>
	"Dummy - provided by support code"
	^0
]

{ #category : #'FFI support' }
InterpreterProxy >> ioLoadFunction: functionName From: moduleName AccessorDepthInto: accessorDepthPtr [
	<returnTypeC: #'void *'>
	<var: #functionName type: #'char *'>
	<var: #moduleName type: #'char *'>
	<var: #accessorDepthPtr type: #'sqInt *'>
	"Dummy - provided by support code"
	^0
]

{ #category : #'FFI support' }
InterpreterProxy >> ioLoadModule: moduleNameIndex OfLength: moduleLength [
	<returnTypeC: #'void *'>
	"Dummy - provided by support code"
	^0
]

{ #category : #'FFI support' }
InterpreterProxy >> ioLoadSymbol: functionNameIndex OfLength: functionLength FromModule: moduleHandle [
	<returnTypeC: #'void *'>
	"Dummy - provided by support code"
	^0
]

{ #category : #other }
InterpreterProxy >> ioMicroMSecs [
	^Time millisecondClockValue
]

{ #category : #testing }
InterpreterProxy >> is: oop KindOf: aString [
	"InterpreterProxy new is: 42 KindOf: 'Number'"
	<var: #aString type: 'char *'>
	<returnTypeC: #sqInt>
	(Smalltalk at: aString asSymbol ifAbsent:[nil])
		ifNil:[false]
		ifNotNil: [:theClass| oop isKindOf: theClass]
]

{ #category : #testing }
InterpreterProxy >> is: oop KindOfClass: aClass [
	"InterpreterProxy new is: 42 KindOfClass: Number"
	^oop isKindOf: aClass
]

{ #category : #testing }
InterpreterProxy >> is: oop MemberOf: aString [
	"InterpreterProxy new is: 42 MemberOf:'SmallInteger'"
	| theClass |
	<var: #aString type:'char *'>
	theClass := Smalltalk at: aString asSymbol ifAbsent:[nil].
	^theClass isNil
		ifTrue:[false]
		ifFalse:[^oop isMemberOf: theClass]
]

{ #category : #testing }
InterpreterProxy >> isArray: oop [
	^(self isNonImmediate: oop) and: [oop class instSpec = 2]
]

{ #category : #testing }
InterpreterProxy >> isBooleanObject: oop [
	<option: #(atLeastVMProxyMajor:minor: 1 15)>
	^oop == true or: [oop == false]
]

{ #category : #testing }
InterpreterProxy >> isBytes: oop [
	^oop class isBytes
]

{ #category : #testing }
InterpreterProxy >> isCharacterObject: oop [
	<option: #(atLeastVMProxyMajor:minor: 1 13)>
	^oop isCharacter
]

{ #category : #testing }
InterpreterProxy >> isCharacterValue: anInteger [
	<option: #(atLeastVMProxyMajor:minor: 1 13)>
	^(self isIntegerValue: anInteger) and: [anInteger >= 0]
]

{ #category : #testing }
InterpreterProxy >> isFloatObject: oop [
	^oop isFloat
]

{ #category : #testing }
InterpreterProxy >> isImmediate: anObject [
	<option: #(atLeastVMProxyMajor:minor: 1 13)>
	^StackInterpreter objectMemoryClass isImmediate: anObject
]

{ #category : #'FFI support' }
InterpreterProxy >> isInMemory: address [
	"Return true if the given address is in ST object memory"
	^true
]

{ #category : #testing }
InterpreterProxy >> isIndexable: oop [
	^oop class isVariable
]

{ #category : #testing }
InterpreterProxy >> isIntegerObject: objectPointer [
	^objectPointer class == SmallInteger
]

{ #category : #testing }
InterpreterProxy >> isIntegerValue: intValue [
	^intValue class == SmallInteger
]

{ #category : #private }
InterpreterProxy >> isInterpreterProxy [
	"Return true since I am not a real Interpreter simulation"
	^true
]

{ #category : #testing }
InterpreterProxy >> isKindOfInteger: objectOrientedPointer [
	^objectOrientedPointer isInteger
]

{ #category : #testing }
InterpreterProxy >> isLargeIntegerObject: objectOrientedPointer [
	^objectOrientedPointer isKindOf: LargePositiveInteger
]

{ #category : #testing }
InterpreterProxy >> isLargeNegativeIntegerObject: objectOrientedPointer [
	^objectOrientedPointer isMemberOf: LargeNegativeInteger
]

{ #category : #testing }
InterpreterProxy >> isLargePositiveIntegerObject: objectOrientedPointer [
	^objectOrientedPointer isMemberOf: LargePositiveInteger
]

{ #category : #testing }
InterpreterProxy >> isNonImmediate: anObject [

	^ (self isImmediate: anObject) not
]

{ #category : #'object access' }
InterpreterProxy >> isOopImmutable: oop [
	<option: #IMMUTABILITY>
	^StackInterpreter objectMemoryClass isOopImmutable: oop
]

{ #category : #testing }
InterpreterProxy >> isOopMutable: anOop [
	<api>
	^self notYetImplementedError
]

{ #category : #testing }
InterpreterProxy >> isPinned: anObject [
	<option: #(atLeastVMProxyMajor:minor: 1 13)>
	^self shouldBeImplemented
]

{ #category : #testing }
InterpreterProxy >> isPointers: oop [
	^oop class isPointers
]

{ #category : #testing }
InterpreterProxy >> isPositiveMachineIntegerObject: oop [
	<option: #(atLeastVMProxyMajor:minor: 1 15)>
	^oop isInteger and: [oop >= 0 and: [oop digitLength <= Smalltalk wordSize]]
]

{ #category : #testing }
InterpreterProxy >> isWeak: oop [
	^oop class isWeak
]

{ #category : #testing }
InterpreterProxy >> isWords: oop [
	^oop class isPointers not and:[oop class isBytes not]
]

{ #category : #testing }
InterpreterProxy >> isWordsOrBytes: oop [
	^(self isBytes: oop) or:[self isWords: oop]
]

{ #category : #'FFI support' }
InterpreterProxy >> isYoung: anOop [
	^self notYetImplementedError
]

{ #category : #'object access' }
InterpreterProxy >> literal: offset ofMethod: methodPointer [
	^methodPointer literalAt: offset+1
]

{ #category : #'object access' }
InterpreterProxy >> literalCountOf: methodPointer [
	^methodPointer numLiterals
]

{ #category : #'BitBlt support' }
InterpreterProxy >> loadBitBltFrom: bbOop [
	<returnTypeC: #sqInt>
	bb := bbOop
]

{ #category : #initialize }
InterpreterProxy >> loadStackFrom: aContext [
	self push: aContext receiver.
	method := aContext method.
	argumentCount := method numArgs.
	1 to: argumentCount do:[:i| self push: (aContext at: i) ].
]

{ #category : #private }
InterpreterProxy >> long32At: arrayOffset [

	^ arrayOffset long32At: 0

]

{ #category : #private }
InterpreterProxy >> longAt: accessor [
	^accessor longAt: 0
]

{ #category : #private }
InterpreterProxy >> longAt: accessor put: value [
	^accessor longAt: 0 put: value
]

{ #category : #other }
InterpreterProxy >> majorVersion [
	^ 1
]

{ #category : #'instance creation' }
InterpreterProxy >> makePointwithxValue: xValue yValue: yValue [
	(xValue class == SmallInteger and:[yValue class == SmallInteger]) 
		ifFalse:[self error:'Not SmallInteger objects'].
	^xValue@yValue
]

{ #category : #'stack access' }
InterpreterProxy >> methodArg: offset [
	"Like #stackValue: but access method arguments left-to-right"
	"Obsolete; was never used; replaced with methodReturnBool: in the VirtualMachine struct."
	self deprecated.
	offset > argumentCount + 1 ifTrue:[^self primitiveFail].
	^self stackValue: argumentCount - offset
]

{ #category : #'object access' }
InterpreterProxy >> methodArgumentCount [
	^argumentCount
]

{ #category : #'object access' }
InterpreterProxy >> methodPrimitiveIndex [
	^method primitive
]

{ #category : #'stack access' }
InterpreterProxy >> methodReturnBool: boolean [
	"Sets the return value for a method"
	self pop: argumentCount+1 thenPushBool: boolean.
	^0
]

{ #category : #'stack access' }
InterpreterProxy >> methodReturnFloat: aFloat [
	"Sets the return value for a method"
	<var: 'aFloat' type: #double>
	self pop: argumentCount+1 thenPushFloat: aFloat.
	^0
]

{ #category : #'stack access' }
InterpreterProxy >> methodReturnInteger: integer [
	"Sets the return value for a method"
	self pop: argumentCount+1 thenPushInteger: integer.
	^0
]

{ #category : #'stack access' }
InterpreterProxy >> methodReturnReceiver [
	"Sets the return value for a method"
	self pop: argumentCount.
	^0
]

{ #category : #'stack access' }
InterpreterProxy >> methodReturnString: aCString [
	"Sets the return value for a method."
	"THIS IS DUBIOUS!  CONSIDER REMOVING IT!  RIGHT NOW IT IS NOT SENT."
	<var: 'aCString' type: #'char *'>
	(self stringForCString: aCString)
		ifNil: [primFailCode := PrimErrNoMemory]
		ifNotNil: [:result| self pop: argumentCount+1 thenPush: result].
	^0
]

{ #category : #'stack access' }
InterpreterProxy >> methodReturnValue: oop [
	"Sets the return value for a method"
	self pop: argumentCount+1 thenPush: oop.
	^0
]

{ #category : #other }
InterpreterProxy >> minorVersion [
	^ 8
]

{ #category : #'special objects' }
InterpreterProxy >> nilObject [
	^nil
]

{ #category : #private }
InterpreterProxy >> notYetImplementedError [
	^self error: 'not yet implemented in Smalltalk'
]

{ #category : #'stack access' }
InterpreterProxy >> objectArg: offset [
	"Like #stackObjectValue: but access method arguments left-to-right"
	"Obsolete; was never used; replaced with methodReturnFloat: in the VirtualMachine struct."
	| oop |
	self deprecated.
	oop := self methodArg: offset.
	(self isImmediate: oop) ifTrue: [self primitiveFail. ^ nil].
	^oop
]

{ #category : #'object access' }
InterpreterProxy >> obsoleteDontUseThisFetchWord: fieldIndex ofObject: oop [
"fetchWord:ofObject: is rescinded as of VMMaker 3.8 64bit VM. This is a placeholder to sit in the sqVirtualMachine structure to support older plugins for a while"
	self halt: 'deprecated method'
]

{ #category : #'FFI support' }
InterpreterProxy >> ownVM: flags [
	^self notYetImplementedError
]

{ #category : #'object access' }
InterpreterProxy >> pinObject: anObject [
	<option: #(atLeastVMProxyMajor:minor: 1 13)>
	^self shouldBeImplemented
]

{ #category : #'stack access' }
InterpreterProxy >> pop: nItems [
	<returnTypeC: #sqInt>
	1 to: nItems do:[:i| stack removeLast].
]

{ #category : #'stack access' }
InterpreterProxy >> pop: nItems thenPush: oop [
	<returnTypeC: #void>
	self pop: nItems.
	self push: oop
]

{ #category : #private }
InterpreterProxy >> pop: nItems thenPushBool: boolean [
	<returnTypeC: #sqInt>
	self pop: nItems.
	self push: (boolean ifTrue: [self trueObject] ifFalse: [self falseObject])
]

{ #category : #private }
InterpreterProxy >> pop: nItems thenPushFloat: float [
	<var: #float type: #double>
	<returnTypeC: #sqInt>
	self pop: nItems.
	self push: (self floatObjectOf: float)
]

{ #category : #private }
InterpreterProxy >> pop: nItems thenPushInteger: integer [
	<returnTypeC: #sqInt>
	self pop: nItems.
	self push: (self integerObjectOf: integer)
]

{ #category : #'instance creation' }
InterpreterProxy >> popRemappableOop [
	^remapBuffer removeLast
]

{ #category : #converting }
InterpreterProxy >> positive32BitIntegerFor: integerValue [
	<returnTypeC: #sqInt>
	<var: 'integerValue' type: #'unsigned int'>
	integerValue isInteger ifFalse:[self error:'Not an Integer object'].
	^integerValue > 0
		ifTrue:[integerValue]
		ifFalse:[ (1 bitShift: 32) + integerValue]
]

{ #category : #converting }
InterpreterProxy >> positive32BitValueOf: oop [
	<returnTypeC: #'unsigned int'>
	oop isInteger ifFalse:[self error:'Not an integer object'].
	oop < 0 
		ifTrue:[self primitiveFail. ^0]
		ifFalse:[^oop]
]

{ #category : #converting }
InterpreterProxy >> positive64BitIntegerFor: integerValue [
	<api>
	<returnTypeC: #sqInt> "...because answering the 64-bit argument causes the type inferencer to say this answers 64-bits."
	<var: 'integerValue' type: #usqLong>
	integerValue isInteger ifFalse:[self error:'Not an Integer object'].
	^integerValue > 0
		ifTrue:[integerValue]
		ifFalse:[ (1 bitShift: 64) + integerValue]
]

{ #category : #converting }
InterpreterProxy >> positive64BitValueOf: oop [
	<returnTypeC: #usqLong>
	oop isInteger ifFalse:[self error:'Not an integer object'].
	oop < 0 
		ifTrue:[self primitiveFail. ^0]
		ifFalse:[^oop]
]

{ #category : #converting }
InterpreterProxy >> positiveMachineIntegerValueOf: oop [
	<returnTypeC: #'usqIntptr_t'>
	oop isInteger ifFalse:[self error: 'Not an integer object'].
	^oop < 0 
		ifTrue: [self primitiveFail. 0]
		ifFalse: [oop]
]

{ #category : #'special objects' }
InterpreterProxy >> primitiveErrorTable [
	^Smalltalk primitiveErrorTable
]

{ #category : #other }
InterpreterProxy >> primitiveFail [
	<returnTypeC: #sqInt>
	"Set general (unspecified) primitive failure."
	self primitiveFailFor: 1
]

{ #category : #other }
InterpreterProxy >> primitiveFailFor: reasonCode [
	"Set specific primitive failure.
	N.B. primitiveFailFor: PrimNoErr is expected to clear the primFailCode.
	Primitive 255 is called to indicate that we are currently simulating a primitive that should fail and the VM should handle that case appropriately (if supported by the VM)."
	<primitive: 255>
	^ primFailCode := reasonCode
]

{ #category : #other }
InterpreterProxy >> primitiveFailForFFIException: exceptionCode at: pc [
	<var: 'exceptionCode' type: #usqLong>
	<var: 'pc' type: #usqInt>
	<option: #(atLeastVMProxyMajor:minor: 1 14)>
	"Set PrimErrFFIException primitive failure and associated exceptionCode (a.k.a. 
	 osErrorCode) and exceptionPC."
	<primitive: 255>
	osErrorCode := exceptionCode.
	exceptionPC := pc.
	^primFailCode := PrimErrFFIException
]

{ #category : #other }
InterpreterProxy >> primitiveFailForOSError: osError [
	<var: 'osError' type: #sqLong>
	<option: #(atLeastVMProxyMajor:minor: 1 14)>
	"Set PrimErrOSError primitive failure and associated osErrorCode.
	 Primitive 255 is called to indicate that we are currently simulating a primitive that should fail and the VM should handle that case appropriately (if supported by the VM)."
	<primitive: 255>
	osErrorCode := osError.
	^primFailCode := PrimErrOSError
]

{ #category : #other }
InterpreterProxy >> primitiveFailureCode [
	^primFailCode
]

{ #category : #'object access' }
InterpreterProxy >> primitiveIndexOf: methodPointer [
	^methodPointer primitive
]

{ #category : #'object access' }
InterpreterProxy >> primitiveMethod [
	"Return the method an external primitive was defined in"
	^method
]

{ #category : #'stack access' }
InterpreterProxy >> push: object [
	<returnTypeC: #sqInt>
	stack addLast: object
]

{ #category : #'stack access' }
InterpreterProxy >> pushBool: trueOrFalse [
	<returnTypeC: #sqInt>
	(trueOrFalse == true or:[trueOrFalse == false]) ifFalse:[self error:'Not a Boolean'].
	self push: trueOrFalse
]

{ #category : #'stack access' }
InterpreterProxy >> pushFloat: f [
	<returnTypeC: #sqInt>
	<var: #f type: 'double '>
	f isFloat ifFalse:[^self error:'Not a Float'].
	self push: f.
]

{ #category : #'stack access' }
InterpreterProxy >> pushInteger: integerValue [
	<returnTypeC: #sqInt>
	self push: (self integerObjectOf: integerValue).
]

{ #category : #'instance creation' }
InterpreterProxy >> pushRemappableOop: oop [
	<returnTypeC: #void>
	remapBuffer addLast: oop
]

{ #category : #'callback support' }
InterpreterProxy >> reestablishContextPriorToCallback: callbackContext [
	"callbackContext is an activation of invokeCallback:stack:registers:jmpbuf:.  Its sender
	is the interpreter's state prior to the callback.  Reestablish that state."
	<returnTypeC: #sqInt>
	self notYetImplemented
]

{ #category : #'callback support' }
InterpreterProxy >> returnAs: returnTypeOop ThroughCallback: vmCallbackContext Context: callbackMethodContext [
	<returnTypeC: #sqInt>
	<var: #vmCallbackContext type: #'VMCallbackContext *'>
	"callbackMethodContext is an activation of invokeCallback:[stack:registers:jmpbuf:].
	 Its sender is the VM's state prior to the callback.  Reestablish that state (via longjmp),
	 and mark callbackMethodContext as dead."
	self notYetImplemented
]

{ #category : #'callback support' }
InterpreterProxy >> sendInvokeCallback: thunkPtr Stack: stackPtr Registers: regsPtr Jmpbuf: jmpBufPtr [
	"Send the 4 argument callback message invokeCallback:stack:registers:jmpbuf:
	 to Alien class with the supplied args.  The arguments are raw C addresses
	 and are converted to integer objects on the way."
	<returnTypeC: #sqInt>
	self notYetImplemented
]

{ #category : #'callback support' }
InterpreterProxy >> sendInvokeCallbackContext: vmCallbackContext [
	<var: #vmCallbackContext type: #'VMCallbackContext *'>
	"Send the calllback message to Alien class with the supplied arg(s).  Use either the
	 1 arg invokeCallbackContext: or the 4 arg invokeCallback:stack:registers:jmpbuf:
	 message, depending on what selector is installed in the specialObjectsArray.
	 Note that if invoking the legacy invokeCallback:stack:registers:jmpbuf: we pass the
	 vmCallbackContext as the jmpbuf argument (see reestablishContextPriorToCallback:).
	 The arguments are raw C addresses and are converted to integer objects on the way."
	<returnTypeC: #sqInt>
	self notYetImplemented
]

{ #category : #other }
InterpreterProxy >> showDisplayBits: aForm Left: l Top: t Right: r Bottom: b [
	aForm == Display ifTrue:[
		Display class isDeferringUpdates ifTrue: [^ nil].
		Display forceToScreen: (Rectangle left: l right: r top: t bottom: b)].
]

{ #category : #'callback support' }
InterpreterProxy >> signalNoResume: aSemaphore [
	^self notYetImplementedError
]

{ #category : #other }
InterpreterProxy >> signalSemaphoreWithIndex: semaIndex [
	<returnTypeC: #sqInt>
	((Smalltalk externalObjects) at: semaIndex) signal
]

{ #category : #converting }
InterpreterProxy >> signed32BitIntegerFor: integerValue [
	integerValue isInteger ifFalse:[self error:'Not an Integer object'].
	^integerValue
]

{ #category : #converting }
InterpreterProxy >> signed32BitValueOf: oop [
	<returnTypeC: #int>
	oop isInteger ifFalse:[self error:'Not an integer object'].
	^oop
]

{ #category : #converting }
InterpreterProxy >> signed64BitIntegerFor: integerValue [
	<returnTypeC: #sqInt> "...because answering the 64-bit argument causes the type inferencer to say this answers 64-bits."
	<var: 'integerValue' type: #sqLong>
	integerValue isInteger ifFalse:[self error:'Not an Integer object'].
	^integerValue
]

{ #category : #converting }
InterpreterProxy >> signed64BitValueOf: oop [
	<returnTypeC: #sqLong>
	oop isInteger ifFalse:[self error:'Not an integer object'].
	^oop
]

{ #category : #converting }
InterpreterProxy >> signedMachineIntegerValueOf: oop [
	<returnTypeC: #'sqIntptr_t'>
	oop isInteger ifFalse:[self error:'Not an integer object'].
	^oop
]

{ #category : #'object access' }
InterpreterProxy >> sizeOfSTArrayFromCPrimitive: cPtr [
	"Note: Only called by translated primitive code."
	<var: #cPtr type: 'void *'>
	^self shouldNotImplement
]

{ #category : #'object access' }
InterpreterProxy >> slotSizeOf: oop [
	"Returns the number of slots in the receiver.
	If the receiver is a byte object, return the number of bytes.
	Otherwise return the number of words."
	^(oop basicSize) + (oop class instSize)
]

{ #category : #'object access' }
InterpreterProxy >> stObject: array at: index [
	^array at: index
]

{ #category : #'object access' }
InterpreterProxy >> stObject: array at: index put: value [
	^array at: index put: value
]

{ #category : #'object access' }
InterpreterProxy >> stSizeOf: oop [
	"Return the number of indexable fields in the receiver"
	^oop basicSize
]

{ #category : #'stack access' }
InterpreterProxy >> stackFloatValue: offset [
	| oop |
	<returnTypeC: 'double'>
	oop := self stackValue: offset.
	(self isFloatObject: oop) ifFalse: [self primitiveFail. ^0.0].
	^oop
]

{ #category : #'stack access' }
InterpreterProxy >> stackIntegerValue: offset [
	| oop |
	oop := self stackValue: offset.
	(self isIntegerObject: oop) ifFalse: [self primitiveFail. ^0].
	^oop
]

{ #category : #'stack access' }
InterpreterProxy >> stackObjectValue: offset [
	| oop |
	oop := self stackValue: offset.
	(self isImmediate: oop) ifTrue: [self primitiveFail. ^ nil].
	^oop
]

{ #category : #'stack access' }
InterpreterProxy >> stackPositiveMachineIntegerValue: offset [
	<returnTypeC: #'usqIntptr_t'>
	^self positiveMachineIntegerValueOf: (self stackValue: offset)
]

{ #category : #'stack access' }
InterpreterProxy >> stackSignedMachineIntegerValue: offset [
	<returnTypeC: #'sqIntptr_t'>
	^self signedMachineIntegerValueOf: (self stackValue: offset)
]

{ #category : #'stack access' }
InterpreterProxy >> stackValue: offset [
	^stack at: stack size - offset.
]

{ #category : #other }
InterpreterProxy >> statNumGCs [
	<option: #(atLeastVMProxyMajor:minor: 1 14)>
	^(Smalltalk vmParameterAt: 7 "statFullGCs") + (Smalltalk vmParameterAt: 9 "statScavenges/statIncrGCs")
]

{ #category : #'object access' }
InterpreterProxy >> storeInteger: index ofObject: oop withValue: integer [
	(self isIntegerValue: integer) 
		ifTrue:[^self storePointer: index ofObject: oop withValue: integer]
		ifFalse:[^self primitiveFail]
]

{ #category : #'object access' }
InterpreterProxy >> storePointer: index ofObject: oop withValue: valuePointer [
	^oop instVarAt: index+1 put: valuePointer
]

{ #category : #testing }
InterpreterProxy >> stringForCString: aCString [
	"Answer a ByteString object containing the bytes (possibly UTF-8?) in the null-terminated C string aCString."
	<option: #(atLeastVMProxyMajor:minor: 1 14)>
	<returnTypeC: #sqInt>
	<var: #aCString type: #'char *'>
	self notYetImplemented
]

{ #category : #other }
InterpreterProxy >> success: aBoolean [
	<returnTypeC: #sqInt>
	aBoolean ifTrue: [^self].
	primFailCode = 0 ifTrue: [self primitiveFailFor: 1]
]

{ #category : #other }
InterpreterProxy >> superclassOf: classPointer [
	^classPointer superclass
]

{ #category : #initialize }
InterpreterProxy >> synthesizeStackFor: receiver with: args [
	<doNotGenerate>
	self push: receiver.
	argumentCount := args size.
	1 to: argumentCount do: [:i | self push: (args at: i)].
]

{ #category : #other }
InterpreterProxy >> tenuringIncrementalGC [
	<returnTypeC: #void>
	Smalltalk forceTenuring; garbageCollectMost
]

{ #category : #'instance creation' }
InterpreterProxy >> topRemappableOop [
	"Returns the top of the remappable oop. Useful when writing loops."
	^remapBuffer last
]

{ #category : #'special objects' }
InterpreterProxy >> trueObject [
	^true
]

{ #category : #'object access' }
InterpreterProxy >> unpinObject: anObject [
	<option: #(atLeastVMProxyMajor:minor: 1 13)>
	^self shouldBeImplemented
]

{ #category : #other }
InterpreterProxy >> vmEndianness [
	"return 0 for little endian, 1 for big endian"
	^SmalltalkImage current endianness =#big ifTrue:[1] ifFalse:[0]
]
