//
//  Result.swift
//  SemverKit
//
//  Created by Salazar, Alexandros on 9/15/14.
//  Copyright (c) 2014 nomothetis. All rights reserved.
//

import Foundation

/**
 A type representing a computation that has either failed or succeeded. Use `map` to chain pure
 computations or `flatMap` to chain failure-prone ones.
 */
public enum Result<T> : Printable {
    case Success(Box<T>)
    case Failure(String)
    
    public func flatMap<P>(f:T -> Result<P>) -> Result<P> {
        switch self {
        case .Success(let box):
            return f(box.value)
        case .Failure(let err):
            return .Failure(err)
        }
    }
    
    public func map<P>(f:T -> P) -> Result<P> {
        switch self {
        case .Success(let box):
            return .Success(Box(val:f(box.value)))
        case .Failure(let err):
            return .Failure(err)
        }
    }
    
    public var description:String {
        get {
            switch self {
            case .Success(let box):
                return "{ Success \(box.value) }"
            case .Failure(let err):
                return "{ Failure \"\(err)\" }"
            }
        }
    }
    
    public func forcedValue() -> T {
        switch self {
        case .Success(let box):
            return box.value
        case .Failure(let err):
            println("Cannot force value of error: \(err)")
            abort()
        }
    }
}

func success<T>(content:T) -> Result<T> {
    return Result.Success(Box(val: content))
}

/**
 Sad type that needs to exist because we can't have non-fixed layout enums yet…
 */
public class Box<T> {
    public let value:T
    public init(val:T) {
        self.value = val
    }
}