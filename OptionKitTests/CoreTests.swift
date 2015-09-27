//
//  OptionKitTests.swift
//  OptionKitTests
//
//  Created by Salazar, Alexandros on 9/24/14.
//  Copyright (c) 2014 nomothetis. All rights reserved.
//

import Cocoa
import XCTest
import OptionKit

class OptionKitTests: XCTestCase {
    
    func testParserWithNoOption() {
        let parser = OptionParser()

        do {
            let opts = try parser.parse(["--hello"])
            XCTFail("Empty parser should process no options other than -h|--help; instead processed: \(opts)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: --hello", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }

        do {
            let opts = try parser.parse(["-v"])
            XCTFail("Empty parser should process no options other than -h|--help; instead processed: \(opts)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -v", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
    }
    
    func testParserWithNoParameterShortOption() {
        let optionDescription = Option(trigger:.Short("h"))
        let parser = OptionParser(definitions:[optionDescription])
        
        var params = ["h"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["h"], "Incorrect non-option parameters")
            XCTAssertEqual(0, options.count, "Nothing should have been parsed.")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(error)")
        }
        
        params = ["-h"]
        do {
            let (options, _) = try parser.parse(params)
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Incorrect option parsed.")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(error)")
        }
        
        params = ["-i"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -i", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["-h", "--bad-option"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: --bad-option", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["-h", "-n"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -n", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        // Check that order doesn't matter.
        params = ["-h", "lastIsBest"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["lastIsBest"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parser \(parser) should not have failed to parse \(params) with error: \(error)")
        }

        params = ["firstRules", "-h"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["firstRules"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parser \(parser) should not have failed to parse \(params) with error: \(error)")
        }
        
        params = ["sandwiches", "-h", "rock"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["sandwiches", "rock"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parser \(parser) should not have failed to parse \(params) with error: \(error)")
        }
    }

    func testInvalidCallsOfNoParameterShortOption() {
        let optionDescription = Option(trigger:.Short("h"))
        let parser = OptionParser(definitions:[optionDescription])
        
        let params = ["--hello"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options: \(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: --hello", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
    }
    

    func testParserWithNoParameterLongOption() {
        let optionDescription = Option(trigger:.Long("hello"))
        let parser = OptionParser(definitions:[optionDescription])
        
        var params = ["hello"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["hello"], "Incorrect non-option parameters")
            XCTAssertEqual(0, options.count, "Nothing should have been parsed.")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["--hello"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["-i"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -i", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }

        params = ["--hello", "--bad-option"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: --bad-option", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["--hello", "-n"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -n", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }

        // Check that order doesn't matter.
        params = ["--hello", "lastIsBest"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["lastIsBest"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["firstRules", "--hello"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["firstRules"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["sandwiches", "--hello", "rock"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["sandwiches", "rock"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
    }

    func testInvalidCallsOfNoParamterLongOption() {
        let optionDescription = Option(trigger:.Long("vroom"), numberOfParameters:0)
        let parser = OptionParser(definitions:[optionDescription])
        
        let params = ["-v"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -v", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
    }
    
    func testParserWithNoParameterMixedOption() {
        let optionDescription = Option(trigger:.Mixed("h", "hello"))
        let parser = OptionParser(definitions:[optionDescription])
        
        var params = ["h"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["h"], "Incorrect non-option parameters")
            XCTAssertEqual(0, options.count, "No options should have been parsed.")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["-h"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["-i"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -i", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["-h", "--bad-option"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: --bad-option", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["-h", "-n"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -n", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        // Check that order doesn't matter.
        params = ["-h", "lastIsBest"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["lastIsBest"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["firstRules", "-h"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["firstRules"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["sandwiches", "-h", "rock"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["sandwiches", "rock"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        // Check that the long option also works.
        
        params = ["--hello"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["--hello", "--bad-option"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: --bad-option", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["--hello", "-n"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Invalid option: -n", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        // Check that order doesn't matter.
        params = ["--hello", "lastIsBest"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["lastIsBest"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["firstRules", "--hello"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["firstRules"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["sandwiches", "--hello", "rock"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["sandwiches", "rock"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
    }

    func testOptionWithParameters() {
        // One parameter.
        var optionDescription = Option(trigger:.Mixed("h", "hello"), numberOfParameters:1)
        var parser = OptionParser(definitions:[optionDescription])
        
        var params = ["-h", "world"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["--hello", "world"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["--hello"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-h|--hello] requires 1 parameters, parameters [] are given", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["--hello", "--world"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-h|--hello] requires 1 parameters, parameters [] are given before option --world was declared", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["--hello", "-w"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-h|--hello] requires 1 parameters, parameters [] are given before option -w was declared", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        
        optionDescription = Option(trigger:.Mixed("h", "hello"), numberOfParameters:3)
        parser = OptionParser(definitions:[optionDescription])
        
        params = ["-h", "world", "of", "coke"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["--hello", "world", "of", "coke"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Incorrect number of options parsed.")
            XCTAssertNotNil(options[optionDescription], "Parser \(parser) should have parsed \(params)")
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["--hello"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-h|--hello] requires 3 parameters, parameters [] are given", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }

        params = ["--hello", "world"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-h|--hello] requires 3 parameters, parameters [\"world\"] are given", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["--hello", "world", "of"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-h|--hello] requires 3 parameters, parameters [\"world\", \"of\"] are given", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
    }
    
    
    func testMixOfParametersAndNoParameters() {
        let optionDescription = Option(trigger:.Mixed("h", "hello"), numberOfParameters:1)
        let optionDescription2 = Option(trigger:.Mixed("p", "pom"))
        let optionDescription3 = Option(trigger:.Mixed("n", "nom"), numberOfParameters:2)
        let parser = OptionParser(definitions:[optionDescription, optionDescription2, optionDescription3])
        let expectedParameters1 = ["world"]
        let expectedParameters2 = []
        let expectedParameters3 = ["boo", "hoo"]
        
        var params = ["--hello", "world", "of"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["of"], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Parser \(parser) should have parsed \(params)")
            if let optParams = options[optionDescription] {
                XCTAssertEqual(optParams, expectedParameters1, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription)")
            }
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["--hello", "world"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(1, options.count, "Parser \(parser) should have parsed \(params)")
            if let optParams = options[optionDescription] {
                XCTAssertEqual(optParams, expectedParameters1, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription)")
            }
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["--hello", "world", "-p"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(2, options.count, "Parser \(parser) should have parsed \(params)")
            if let optParams = options[optionDescription] {
                XCTAssertEqual(optParams, expectedParameters1, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription)")
            }

            if let optParams2 = options[optionDescription2] {
                XCTAssertEqual(optParams2, expectedParameters2, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription2)")
            }
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["--hello", "world", "-p"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(2, options.count, "Parser \(parser) should have parsed \(params)")
            if let optParams = options[optionDescription] {
                XCTAssertEqual(optParams, expectedParameters1, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription)")
            }

            if let optParams2 = options[optionDescription2] {
                XCTAssertEqual(optParams2, expectedParameters2, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription2)")
            }
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["--hello", "world", "-p", "-n", "boo", "hoo"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, [], "Incorrect non-option parameters")
            XCTAssertEqual(3, options.count, "Parser \(parser) should have parsed \(params)")
            if let optParams = options[optionDescription] {
                XCTAssertEqual(optParams, expectedParameters1, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription)")
            }

            if let optParams2 = options[optionDescription2] {
                XCTAssertEqual(optParams2, expectedParameters2, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription2)")
            }

            if let optParams3 = options[optionDescription3] {
                XCTAssertEqual(optParams3, expectedParameters3, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription3)")
            }
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }

        params = ["--hello", "world", "-p", "-n", "boo", "hoo", "rest"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["rest"], "Incorrect non-option parameters")
            XCTAssertEqual(3, options.count, "Parser \(parser) should have parsed \(params)")
            if let optParams = options[optionDescription] {
                XCTAssertEqual(optParams, expectedParameters1, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription)")
            }

            if let optParams2 = options[optionDescription2] {
                XCTAssertEqual(optParams2, expectedParameters2, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription2)")
            }

            if let optParams3 = options[optionDescription3] {
                XCTAssertEqual(optParams3, expectedParameters3, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription3)")
            }
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        // Tests that options can be passed at any time
        params = ["-p", "-n", "boo", "hoo", "rest", "--hello", "world"]
        do {
            let (options, rest) = try parser.parse(params)
            XCTAssertEqual(rest, ["rest"], "Incorrect non-option parameters")
            XCTAssertEqual(3, options.count, "Parser \(parser) should have parsed \(params)")
            if let optParams = options[optionDescription] {
                XCTAssertEqual(optParams, expectedParameters1, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription)")
            }

            if let optParams2 = options[optionDescription2] {
                XCTAssertEqual(optParams2, expectedParameters2, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription2)")
            }

            if let optParams3 = options[optionDescription3] {
                XCTAssertEqual(optParams3, expectedParameters3, "Incorrect parameters for \(optionDescription)")
            } else {
                XCTFail("No parameters for option \(optionDescription3)")
            }
        } catch {
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }


        // Now test the failure states: times when all the parameters aren't passed.
        params = ["-p", "-n", "boo", "--hello", "world"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-n|--nom] requires 2 parameters, parameters [\"boo\"] are given before option --hello was declared", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["-p", "-n", "boo", "--hello"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-n|--nom] requires 2 parameters, parameters [\"boo\"] are given before option --hello was declared", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
        
        params = ["-n", "boo", "hoo", "--hello"]
        do {
            try parser.parse(params)
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        } catch let OptionKitError.InvalidOption(description: description) {
            XCTAssertEqual(description, "Option [-h|--hello] requires 1 parameters, parameters [] are given", "Incorrect error description")
        } catch {
            XCTFail("Parsing failed with unexpected error: \(error)")
        }
    }

}
