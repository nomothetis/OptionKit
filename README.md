**NOTE**: OPTIONKIT IS NOT YET READY FOR USE

OptionKit - Option Parsing in Swift
=========

OptionKit is an OS X framework to parse basic command-line options in pure Swift. It
does not currently support sub-parsers, or any more advanced features.

## Overview

OptionKit currently supports three types of options:

* Short options, triggered by flags of the type `-f` or `fab` (which triggers three flags)
* Long options, triggered by flags of the type `--long-option`
* Mixed options, triggered by either type, such as `-v` or `--version`

An option (of any type) can have zero or more required parameters. Parameters are restricted
in that they cannot being with `-` or `--`, as they would be confused with triggers.

Unlike Ruby's OptionParse, OptionKit does not provide for callbacks to be triggered when an
option is processed; instead, it returns a dictionary of options to parameters, wrapped in
a Result object. Consumers can do with it as they please.

## Examples

A simple, full example called `test.swift` might be:

```swift
#!/usr/bin/env xcrun swift -F /Library/Frameworks

import Foundation
import OptionKit

let opt1 = OptionDefinition(trigger:.Mixed("e", "echo"))
let parser = OptionParser(flags:[opt1])
 
let result = parser.parse(Process.arguments)

switch result {
case .Success(let box):
  let options = box.value
  if options[opt1] != nil {
    println("\(Process.arguments[2..<Process.arguments.count])")
  }
case .Failure(let err):
  println(err)
}
```

The output would be:

```
~: ./test.swift -e hello
[hello]
~: ./test.swift hello
~: ./test.swift --echo hello world
[hello world]
~: ./test.swift -e
~: ./test.swift -r
Invalid option: -r
```

## To Do

* Depend on LlamaKit's Result, rather than on a custom Result object.
* Have a simple way to access the non-option parameters after parsing. Right now there is no way to do that, and it's the main reason the library isn't ready for general usage.
* Add support for sub-parsers.
* Add support for descriptions of options.
