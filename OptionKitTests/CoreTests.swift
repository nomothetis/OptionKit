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
        parser.parse(["--hello"]).map {opts in
            XCTFail("Empty parser should process no options; instead processed: \(opts)")
        }
        
        parser.parse(["-h"]).map {opts in
            XCTFail("Empty parser should process no options; instead processed: \(opts)")
        }
    }
    
    func testParserWithNoParameterShortOption() {
        let optionDescription = OptionDefinition(trigger:.Short("h"))
        let parser = OptionParser(flags:[optionDescription])
        let expectedOption = Option(definition:optionDescription)
        
        var params = ["h"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(0, opts.value.count, "Nothing should have been parsed.")
        case .Failure(let opts):
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(opts)")
        }
        
        params = ["-h"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Nothing should have been parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["-i"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["-h", "--bad-option"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["-h", "-n"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        // Check that order doesn't matter.
        params = ["-h", "lastIsBest"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should not have failed to parse \(params) with error: \(err)")
        }
        
        params = ["firstRules", "-h"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["sandwiches", "-h", "rock"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
    }
    
    func testInvalidCallsOfNoParamterShortOption() {
        let optionDescription = OptionDefinition(trigger:.Short("h"))
        let parser = OptionParser(flags:[optionDescription])
        let expectedOption = Option(definition:optionDescription)
        
        var params = ["--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options: \(params)")
        case .Failure(let err):
            XCTAssert(true, "WAT?")
        }
    }
    
    
    func testParserWithNoParameterLongOption() {
        let optionDescription = OptionDefinition(trigger:.Long("hello"))
        let parser = OptionParser(flags:[optionDescription])
        let expectedOption = Option(definition:optionDescription)
        
        var params = ["hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(0, opts.value.count, "Nothing should have been parsed.")
        case .Failure(let opts):
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(opts)")
        }
        
        params = ["--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Nothing should have been parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["-i"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["--hello", "--bad-option"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["--hello", "-n"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        // Check that order doesn't matter.
        params = ["--hello", "lastIsBest"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["firstRules", "--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["sandwiches", "--hello", "rock"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
    }
    
    func testInvalidCallsOfNoParamterLongOption() {
        let optionDescription = OptionDefinition(trigger:.Long("hello"), numberOfParameters:0)
        let parser = OptionParser(flags:[optionDescription])
        let expectedOption = Option(definition:optionDescription)
        
        var params = ["-h"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options: \(params)")
        case .Failure(let err):
            XCTAssert(true, "WAT?")
        }
    }
    
    func testParserWithNoParameterMixedOption() {
        let optionDescription = OptionDefinition(trigger:.Mixed("h", "hello"))
        let parser = OptionParser(flags:[optionDescription])
        let expectedOption = Option(definition:optionDescription)
        
        var params = ["h"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(0, opts.value.count, "Nothing should have been parsed.")
        case .Failure(let opts):
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(opts)")
        }
        
        params = ["-h"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Nothing should have been parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["-i"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["-h", "--bad-option"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["-h", "-n"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        // Check that order doesn't matter.
        params = ["-h", "lastIsBest"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should not have failed to parse \(params) with error: \(err)")
        }
        
        params = ["firstRules", "-h"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["sandwiches", "-h", "rock"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        // Check that the long option also works.
        
        params = ["--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Nothing should have been parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parsing should have succeeded for parser: \(parser), options: \(params)")
        }
        
        params = ["--hello", "--bad-option"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        params = ["--hello", "-n"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parsing should not have succeeded for parser: \(parser), options:\(params)")
        case .Failure(let err):
            XCTAssert(true, "Success!")
        }
        
        // Check that order doesn't matter.
        params = ["--hello", "lastIsBest"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["firstRules", "--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["sandwiches", "--hello", "rock"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
    }
    
    func testOptionWithParameters() {
        // One parameter.
        var optionDescription = OptionDefinition(trigger:.Mixed("h", "hello"), numberOfParameters:1)
        var parser = OptionParser(flags:[optionDescription])
        var expectedOption = Option(definition:optionDescription, parameters:["world"])
        
        var params = ["-h", "world"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello", "world"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params); instead generated \(opts)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
        
        params = ["--hello", "--world"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params); instead generated \(opts)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
        
        params = ["--hello", "-w"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params); instead generated \(opts)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
        
        
        optionDescription = OptionDefinition(trigger:.Mixed("h", "hello"), numberOfParameters:3)
        parser = OptionParser(flags:[optionDescription])
        expectedOption = Option(definition:optionDescription, parameters:["world", "of", "coke"])
        
        params = ["-h", "world", "of", "coke"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello", "world", "of", "coke"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params); instead generated \(opts)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
        
        params = ["--hello", "world"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params); instead generated \(opts)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
        
        params = ["--hello", "world", "of"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params); instead generated \(opts)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
    }
    
    
    func testMixOfParametersAndNoParameters() {
        var optionDescription = OptionDefinition(trigger:.Mixed("h", "hello"), numberOfParameters:1)
        var optionDescription2 = OptionDefinition(trigger:.Mixed("p", "pom"))
        var optionDescription3 = OptionDefinition(trigger:.Mixed("n", "nom"), numberOfParameters:2)
        var parser = OptionParser(flags:[optionDescription, optionDescription2, optionDescription3])
        var expectedOption1 = Option(definition:optionDescription, parameters:["world"])
        var expectedOption2 = Option(definition: optionDescription2)
        var expectedOption3 = Option(definition: optionDescription3, parameters:["boo", "hoo"])
        
        var params = ["--hello", "world", "of"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption1, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello", "world"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(1, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value.last!, expectedOption1, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello", "world", "-p"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(2, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value[0], expectedOption1, "Incorrect option parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption2, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello", "world", "-p"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(2, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value[0], expectedOption1, "Incorrect option parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption2, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello", "world", "-p", "-n", "boo", "hoo"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(3, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value[0], expectedOption1, "Incorrect option parsed.")
            XCTAssertEqual(opts.value[1], expectedOption2, "Incorrect option parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption3, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        params = ["--hello", "world", "-p", "-n", "boo", "hoo", "rest"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(3, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value[0], expectedOption1, "Incorrect option parsed.")
            XCTAssertEqual(opts.value[1], expectedOption2, "Incorrect option parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption3, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        // Tests that options can be passed at any time
        params = ["-p", "-n", "boo", "hoo", "rest", "--hello", "world"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTAssertEqual(3, opts.value.count, "Parser \(parser) should have parsed \(params)")
            XCTAssertEqual(opts.value[0], expectedOption2, "Incorrect option parsed.")
            XCTAssertEqual(opts.value[1], expectedOption3, "Incorrect option parsed.")
            XCTAssertEqual(opts.value.last!, expectedOption1, "Incorrect option parsed.")
        case .Failure(let err):
            XCTFail("Parser \(parser) should have properly parsed \(params)")
        }
        
        
        // Now test the failure states: times when all the parameters aren't passed.
        params = ["-p", "-n", "boo", "--hello", "world"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
        
        params = ["-p", "-n", "boo", "--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
        
        params = ["-n", "boo", "hoo", "--hello"]
        switch parser.parse(params) {
        case .Success(let opts):
            XCTFail("Parser \(parser) should have generated an error with parameters \(params)")
        case .Failure(let err):
            XCTAssert(true, "WTF?")
        }
        
    }
    
}
