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

## Examples

A simple, full example called `test.swift` might be:

```swift
#!/usr/bin/env xcrun swift -F /Library/Frameworks

import OptionKit

let opt1 = OptionDescription(.Mixed("e", "echo"))
let parser = OptionParser(optionDescriptions:[opt1])

let result = parser.parse(Process.arguments)

switch result {
case .Success(let options):
    if options[opt1] != nil {
        println("\(Process.arguments[2..<arguments.count])")
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
~: ./test.swift -e hello world
[hello world]
~: ./test.swift -e
~: ./test.swift -r
Invalid option: -r
```

