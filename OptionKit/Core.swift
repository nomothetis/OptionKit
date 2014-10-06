//
//  Core.swift
//  OptionKit
//
//  Created by Salazar, Alexandros on 9/24/14.
//  Copyright (c) 2014 nomothetis. All rights reserved.
//

import Foundation

/**
 Eventually intends to be a getopt-compatible option parser.
 */

public enum OptionTrigger : Equatable, DebugPrintable {
    case Short(Character)
    case Long(String)
    case Mixed(Character, String)
    
    public var debugDescription:String {
        get {
            switch self {
            case .Short(let c):
                return "-\(c)"
            case .Long(let str):
                return "--\(str)"
            case .Mixed(let c, let str):
                return "(-\(c), --\(str))"
            }
        }
    }
}

public struct OptionDefinition : Equatable, DebugPrintable {
    let trigger:OptionTrigger
    let numberOfParameters:Int 
    
    public init(trigger trig:OptionTrigger, numberOfParameters num:Int = 0) {
        self.trigger = trig
        self.numberOfParameters = num
    }
    
    func matches(str:String) -> Bool {
        switch self.trigger {
        case .Short(let char):
            return str == "-" + String(char)
        case .Long(let longKey):
            return str == "--" + longKey
        case .Mixed(let char, let longKey):
            return (str == "--" + longKey) || str == "-" + String(char)
        }
    }
    
    static func isValidOptionString(str:String) -> Bool{
        let count = countElements(str)
        if count < 2 {
            return false
        }
        
        if count == 2 {
            if str[str.startIndex] != "-" {
                return false
            }
            
            return str[advance(str.startIndex, 1)] != "-"
        }

        /* Okay, count greater than 2. Full option! */
        return str[str.startIndex ... advance(str.startIndex, 1)] == "--"
        
    }
    
    public var debugDescription:String {
        get {
            return "{ OptionDescription: \(self.trigger), \(self.numberOfParameters) }"
        }
    }
}

public struct Option : Equatable, DebugPrintable {
    let definition:OptionDefinition
    let parameters:[String]
    
    public init(definition def:OptionDefinition, parameters params:[String] = []) {
        self.definition = def
        self.parameters = params
    }
    
    public var isValid:Bool {
        get {
            return parameters.count == definition.numberOfParameters
        }
    }
    
    public var debugDescription:String {
        get {
            return "{ Option:\n    \(self.definition)\n     \(self.parameters)}"
        }
    }
}

public struct OptionParser {
    let flags:[OptionDefinition]
    
    public init(flags:[OptionDefinition] = []) {
        self.flags = flags
    }
    
    func parserWithAdditionalFlag(opt:OptionDefinition) -> OptionParser {
        return OptionParser(flags: self.flags + [opt])
    }
    
    /// Parses an array of strings for options.
    ///
    /// This method is concerned with finding all defined options and all their associated
    /// parameters. It assumes:
    ///   - Option syntax ("-a", "--some-option") is reserved for options.
    ///   - The parameters of an option follow the option.
    ///
    /// :param: parameters the parameters passed to the command line utility.
    ///
    /// :returns: A result containing either the parsed option or any error encountered.
    public func parse(parameters:[String]) -> Result<[Option]> {
        let normalizedParams = OptionParser.normalizeParameters(parameters)
        return normalizedParams.reduce(Result.Success(Box(val:[Option]()))) { result, next in
            
            return result.flatMap {optArray in
                
                /* First check if we are in the process of parsing an option with parameters. */
                if let lastOpt = optArray.last {
                    
                    /* Since we have parsed an option already, let's check if it needs more parameters. */
                    if lastOpt.definition.numberOfParameters > lastOpt.parameters.count {
                        
                        /* The option expects parameters; parameters cannot look like option triggers. */
                        if (OptionDefinition.isValidOptionString(next)) {
                            return .Failure("Option \(lastOpt) was not passed the required number of parameters before option \(next) was declared")
                        }
                        
                        /* Sanity prevails, the next element is not an option trigger. */
                        let shortOptArray = optArray[0 ..< optArray.count - 1]
                        let newOption = Option(definition: lastOpt.definition, parameters: lastOpt.parameters + [next])
                        return .Success(Box(val: shortOptArray + [newOption]))
                    }
                    
                    /* No need for more parameters; parse the next option. */
                    return self.parseNewFlagIntoResult(result, flagCandidate: next)
                }
                
                /* This is the first option. Parse it! */
                return self.parseNewFlagIntoResult(result, flagCandidate: next)
            }
        }.flatMap { parsedOptions in
            
            // We need to carry out one last check. Because of the way the above reduce works, it's
            // possible the very last option is in fact not valid. There are ways around that, like
            // having an array of results and then coalescing it into a single Result array if all
            // are successes, but that's actually slower than just checking the last element at the
            // end.
            if let lastOpt = parsedOptions.last {
                if lastOpt.isValid {
                    return .Success(Box(val:parsedOptions))
                } else {
                    return .Failure("Option \(lastOpt) is invalid")
                }
            }
            
            return .Success(Box(val:parsedOptions))
        }
    }
    
    func parseNewFlagIntoResult(current:Result<[Option]>, flagCandidate:String) -> Result<[Option]> {
            /* Does the next element want to be a flag? */
            if OptionDefinition.isValidOptionString(flagCandidate) {
                for flag in self.flags {
                    if flag.matches(flagCandidate) {
                        let newOption = Option(definition: flag, parameters: [])
                        return current.map { val in
                            return val + [newOption]
                        }
                    }
                }
                
                return .Failure("Invalid option: \(flagCandidate)")
            }
            
            return current
    }
    
    static func normalizeParameters(parameters:[String]) -> [String] {
        return parameters.reduce([String]()) { memo, next in
            let index = advance(next.startIndex, 0)
            if next[index] != "-" {
                return memo + [next]
            }
            
            let secondIndex = advance(index, 1)
            if next[secondIndex] == "-" {
                /* Assume everything that follows is valid. */
                return memo + [next]
            }
            
            /* Okay, we have one or more single-character flags. */
            var params = [String]()
            for char in next[secondIndex..<advance(next.startIndex, 2)] {
                params += ["-\(char)"]
            }
            
            return memo + params
        }
        
    }
}

/// MARK: - Equatable
public func ==(lhs:OptionTrigger, rhs:OptionTrigger) -> Bool {
    switch (lhs, rhs) {
    case (.Short(let x), .Short(let y)):
            return x == y
    case (.Long(let x), .Long(let y)):
        return x == y
    case (.Mixed(let x1, let x2), .Mixed(let y1, let y2)):
        return (x1 == y1) && (x2 == y2)
    default:
        return false
    }
}

public func ==(lhs:OptionDefinition, rhs:OptionDefinition) -> Bool {
    return (lhs.trigger == rhs.trigger) && (lhs.numberOfParameters == rhs.numberOfParameters)
}

public func ==(lhs:Option, rhs:Option) -> Bool {
    return (lhs.definition == rhs.definition) && (lhs.parameters == rhs.parameters)
}


