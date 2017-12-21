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

public enum OptionTrigger : Equatable, CustomDebugStringConvertible, Hashable {
    case short(Character)
    case long(String)
    case mixed(Character, String)
    
    public var debugDescription:String {
        get {
            switch self {
            case .short(let c):
                return "-\(c)"
            case .long(let str):
                return "--\(str)"
            case .mixed(let c, let str):
                return "[-\(c)|--\(str)]"
            }
        }
    }
    
    public var usageDescription:String {
        get {
            switch self {
            case .short(let c):
                return "[-\(c)]"
            case .long(let str):
                return "[--\(str)]"
            case .mixed(let c, let str):
                return "[-\(c)|--\(str)]"
            }
        }
    }
    
    public var hashValue:Int {
        get {
            return self.usageDescription.hashValue
        }
    }
}

/// Describes an option for the parser.
///
/// An Option consists of a trigger and a number of required parameters, which
/// defaults to zero. It also has includes a description, which is empty by default. The
/// description does not affect equality.
public struct Option : Equatable, CustomStringConvertible, CustomDebugStringConvertible, Hashable {
    let trigger:OptionTrigger
    let numberOfParameters:Int
    
    /// The description of how the option works. This description has no bearing on equality.
    let helpDescription:String
    
    /// The designated initializer
    ///
    /// Creates an option definition from a trigger and a required number of parameters.
    ///
    /// - parameter trigger:            the trigger that the parser will use to decide the option is
    ///                            being called.
    /// - parameter numberOfParameters: the number of required parameters. Defaults to 0.
    /// - parameter helpDescription:    the string that will be displayed when the -h flag is triggered.
    ///
    /// - returns:                  An OptionDefinition suitable for use by an OptionParser
    public init(trigger trig:OptionTrigger, numberOfParameters num:Int = 0, helpDescription desc:String = "") {
        self.trigger = trig
        self.numberOfParameters = num
        self.helpDescription = desc
    }
    
    /// Determines if the given string matches this trigger.
    ///
    /// - parameter str: the string.
    /// - returns: `true` if the string matches this option's trigger, `false` otherwise.
    func matches(_ str:String) -> Bool {
        switch self.trigger {
        case .short(let char):
            return str == "-" + String(char)
        case .long(let longKey):
            return str == "--" + longKey
        case .mixed(let char, let longKey):
            return (str == "--" + longKey) || str == "-" + String(char)
        }
    }
    
    static func isValidOptionString(_ str:String) -> Bool{
        let length = str.characters.count
        if length < 2 {
            return false
        }
        
        if length == 2 {
            if str[str.startIndex] != "-" {
                return false
            }
            
            return str[str.characters.index(str.startIndex, offsetBy: 1)] != "-"
        }

        /* Okay, count greater than 2. Full option! */
        return str[str.startIndex ... str.characters.index(str.startIndex, offsetBy: 1)] == "--"
    }

    public var description: String {
        get {
            return "\(self.trigger) requires \(self.numberOfParameters) parameters"
        }
    }
    
    public var debugDescription:String {
        get {
            return "{ Opt: \(self.trigger), \(self.numberOfParameters) }"
        }
    }
    
    public var hashValue:Int {
        get {
            return self.debugDescription.hashValue
        }
    }
}

private struct OptionData : Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    let option:Option
    let parameters:[String]
    
    fileprivate init(definition def:Option, parameters params:[String] = []) {
        self.option = def
        self.parameters = params
    }
    
    fileprivate var isValid:Bool {
        get {
            return parameters.count == option.numberOfParameters
        }
    }

    fileprivate var description: String {
        get {
            return "\(self.option), parameters \(parameters) are given"
        }
    }
    
    fileprivate var debugDescription:String {
        get {
            return "{ OptionData:\n    \(self.option.debugDescription)\n     \(self.parameters)}"
        }
    }
}

/// Represents the result of a successful parse.
///
/// The dictionary is a mapping of encountered options to their parameters, where no-parameter
/// options map to an empty array.. The array is the list of remaining parameters.
public typealias ParseData = ([Option:[String]], [String])

/// The option parser.
///
/// This is the workhorse of the library. It is initialized with a list of options and parses an
/// array of strings assumed to be the call paramerers.
public struct OptionParser {
    public let definitions:[Option]
    
    /// Initializes the parser.
    ///
    /// By default, each parser has an option triggered by `-h` and `--help`. It also provides
    /// a console-displayable string of the options via the `helpStringForCommandName` method.
    ///
    /// - parameter definitions: the option definitions to parse for.
    /// - returns: a parser
    public init(definitions defs:[Option] = []) {
        let helpOption = Option(trigger:.mixed("h", "help"), helpDescription: "Display command help.")
        if defs.contains(helpOption) {
            self.definitions = defs
        } else {
            self.definitions = defs + [helpOption]
        }
    }
    
    /// Returns a default help string based on the passed command name and the existing options.
    ///
    /// The string is suitable to be displayed on the command line and consists of multiple lines,
    /// all under 80 characters.
    ///
    /// - parameter commandName: the name of the command.
    /// - returns: an English-language string suitable for command-line display.
    public func helpStringForCommandName(_ commandName:String) -> String {
        let maximumLineWidth = 80
        
        // The leading string, to properly indent.
        var leadingString = "       "
        for _ in 0..<commandName.characters.count {
            leadingString += " "
        }
        leadingString += " "
        
        // Now compute the string!
        return self.definitions.reduce(["usage: \(commandName)"]) { lines, optDef in
            let nextDescription = optDef.trigger.usageDescription
            let additionalCharacters = nextDescription.characters.count + 1 // +1 for the space
            if (lines.last!).characters.count < maximumLineWidth - additionalCharacters {
                return lines[0..<lines.count - 1] + [lines.last! + " " + nextDescription]
            }
            
            return lines + [leadingString + nextDescription]
        }.reduce("") { message, line in
            return message + line + "\n"
        }
    }
    
    /// Parses an array of strings for options.
    ///
    /// This method is concerned with finding all defined options and all their associated
    /// parameters. It assumes:
    ///   - Option syntax ("-a", "--some-option") is reserved for options.
    ///   - The parameters of an option follow the option.
    ///
    /// - parameter parameters: the parameters passed to the command line utility.
    ///
    /// - returns: A ParseData tuple
    /// - throws: OptionKitError
    @discardableResult public func parse(_ parameters:[String]) throws -> ParseData {
        let normalizedParams = OptionParser.normalizeParameters(parameters)
        let firstCall = ([OptionData](), [String]())

        let (parsedOptions, args) = try normalizedParams.reduce(firstCall) { tuple, next in

            let (optArray, args) = tuple
            /* First check if we are in the process of parsing an option with parameters. */
            if let lastOpt = optArray.last {

                /* Since we have parsed an option already, let's check if it needs more parameters. */
                if lastOpt.option.numberOfParameters > lastOpt.parameters.count {

                    /* The option expects parameters; parameters cannot look like option triggers. */
                    if (Option.isValidOptionString(next)) {
                        throw OptionKitError.invalidOption(description: "Option \(lastOpt) before option \(next) was declared")
                    }

                    /* Sanity prevails, the next element is not an option trigger. */
                    let shortOptArray = optArray[0 ..< optArray.count - 1]
                    let newOption = OptionData(definition: lastOpt.option, parameters: lastOpt.parameters + [next])
                    return (shortOptArray + [newOption], args)
                }

                /* No need for more parameters; parse the next option. */
                return try self.parseNewFlag(tuple, flagCandidate: next)
            }

            /* This is the first option. Parse it! */
            return try self.parseNewFlag(tuple, flagCandidate: next)
        }

        // We need to carry out one last check. Because of the way the above reduce works, it's
        // possible the very last option is in fact not valid. There are ways around that, but 
        // that's actually slower than just checking the last element at the end.
        if let lastOpt = parsedOptions.last, !lastOpt.isValid {
            throw OptionKitError.invalidOption(description: "Option \(lastOpt)")
        }

        var dict = [Option:[String]]()
        for opt in parsedOptions {
            dict[opt.option] = opt.parameters
        }
        return (dict, args)
    }

    fileprivate func parseNewFlag(_ current: ([OptionData], [String]), flagCandidate:String) throws -> ([OptionData], [String]) {
        /* Does the next element want to be a flag? */
        if Option.isValidOptionString(flagCandidate) {
            for flag in self.definitions {
                if flag.matches(flagCandidate) {
                    let newOption = OptionData(definition: flag, parameters: [])
                    return (current.0 + [newOption], current.1)
                }
            }
            
            throw OptionKitError.invalidOption(description: "Invalid option: \(flagCandidate)")
        }
        
        return (current.0, current.1 + [flagCandidate])
    }
    
    static func normalizeParameters(_ parameters:[String]) -> [String] {
        return parameters.reduce([String]()) { memo, next in
            let index = next.characters.index(next.startIndex, offsetBy: 0)
            if next[index] != "-" {
                return memo + [next]
            }
            
            let secondIndex = next.characters.index(index, offsetBy: 1)
            if next[secondIndex] == "-" {
                /* Assume everything that follows is valid. */
                return memo + [next]
            }
            
            /* Okay, we have one or more single-character flags. */
            var params = [String]()
            for char in next[secondIndex..<next.characters.index(next.startIndex, offsetBy: 2)].characters {
                params += ["-\(char)"]
            }
            
            return memo + params
        }
        
    }
}

/// MARK: - Equatable
public func ==(lhs:OptionTrigger, rhs:OptionTrigger) -> Bool {
    switch (lhs, rhs) {
    case (.short(let x), .short(let y)):
            return x == y
    case (.long(let x), .long(let y)):
        return x == y
    case (.mixed(let x1, let x2), .mixed(let y1, let y2)):
        return (x1 == y1) && (x2 == y2)
    default:
        return false
    }
}

public func ==(lhs:Option, rhs:Option) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

private func ==(lhs:OptionData, rhs:OptionData) -> Bool {
    return (lhs.option == rhs.option) && (lhs.parameters == rhs.parameters)
}

/// MARK: - Error types

public enum OptionKitError: Error {
  case invalidOption(description: String)
}

