//
//  Context.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import HTTP

public protocol ContextBox: class, CustomStringConvertible, CustomDebugStringConvertible {
    var context: [ContextType] { get set }
    var request: Request { get set }
    func get<T: ContextType>() throws -> T
    func set(ctx: ContextType) throws
}

public protocol ContextType { }

public extension ContextBox {
    func get<T: ContextType>() throws -> T {
        if let box = self as? T {
            return box
        }
        for c in context {
            if let cc = c as? T {
                return cc
            }
        }
        throw MiddlewareError.NoContextType("\(T.self)")
    }
    func set(ctx: ContextType) throws {
        for c in context {
            if c.dynamicType == ctx.dynamicType {
                throw MiddlewareError.AlreadyHasContextType("\(c.dynamicType)")
            }
        }
        context.insert(ctx, atIndex: 0)
    }
}

public extension ContextBox {
    var description: String {
        return "\(context.map({ return $0.dynamicType.self }))"
    }
    var debugDescription: String {
        return "\(context)"
    }
}
