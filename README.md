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

A simple, full example might be:

```swift
#!/usr/bin/env xcrun swift -F /Library/Frameworks

import OptionKit

let opt1 = OptionDescription("-r", "--reprint")
let parser = OptionParser(optionDescriptions:[opt1])

let result = parser.parse(Process.arguments)

println(result)
```

The command line interaction will be like so:
