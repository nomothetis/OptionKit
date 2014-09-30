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

enum OptionType {
    case Short(Character)
    case Long(String)
    case Mixed(Character, String)
    
}

struct OptionDefinition {
    let type:OptionType
    let numberOfParameters:Int = 0
    
    func matches(str:String) -> Bool {
        switch self.type {
        case .Short(let char):
            return str == "-" + String(char)
        case .Long(let longKey):
            return str == longKey
        case .Mixed(let char, let longKey):
            return (str == longKey) || str == "-" + String(char)
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
}

struct Option {
    let definition:OptionDefinition
    let parameters:[String]
}

struct OptionParser {
    let flags:[OptionDefinition]
    
    init(flags:[OptionDefinition]) {
        self.flags = flags
    }
    
    func parserWithAdditionalFlag(opt:OptionDefinition) -> OptionParser {
        return OptionParser(flags: self.flags + [opt])
    }
    
    func parse(parameters:[String]) -> Result<[Option]> {
        let normalizedParams = OptionParser.normalizeParameters(parameters)
        return normalizedParams.reduce(Result.Success(Box(val:[Option]()))) { result, next in
            return result.flatMap {optArray in
                if let lastOpt = optArray.last {
                    if lastOpt.definition.numberOfParameters < lastOpt.parameters.count {
                        let shortOptArray = optArray[0 ..< optArray.count - 1]
                        let newOption = Option(definition: lastOpt.definition, parameters: lastOpt.parameters + [next])
                        return .Success(Box(val: shortOptArray + [newOption]))
                    } else {
                        /* Does the next element want to be a flag? */
                        if OptionDefinition.isValidOptionString(next) {
                            for flag in self.flags {
                                if flag.matches(next) {
                                    let newOption = Option(definition: flag, parameters: [])
                                    return .Success(Box(val: optArray + [newOption]))
                                }
                            }
                            
                            return .Failure("Invalid option: \(next)")
                        }
                        
                        return result
                    }
                } else {
                    /* Does the next element want to be a flag? */
                    if OptionDefinition.isValidOptionString(next) {
                        for flag in self.flags {
                            if flag.matches(next) {
                                let newOption = Option(definition: flag, parameters: [])
                                return .Success(Box(val: optArray + [newOption]))
                            }
                        }
                        
                        return .Failure("Invalid option: \(next)")
                    }
                    
                    return result
                }
            }
        }
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
            for char in next[next.startIndex..<advance(next.startIndex, 2)] {
                params += ["-\(char)"]
            }
            
            return memo + params
        }
        
    }
}
