//
//  Context.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import HTTP

public protocol ContextBox: class {
    var request: Request { get set }
    func get<T: ContextType>() throws -> T
    func set(ctx: ContextType) throws
}

public protocol ContextType {
    
}

class Context: ContextBox, CustomStringConvertible {
    var ctxs: [ContextType] = []
    var request: Request
    init(_ request: Request) {
        self.request = request
    }
    func get<T: ContextType>() throws -> T {
        for c in ctxs {
            if let cc = c as? T {
                return cc
            }
        }
        throw MiddewareError.NoContextType("\(T.self)")
    }
    func set(ctx: ContextType) throws {
        for c in ctxs {
            if c.dynamicType == ctx.dynamicType {
                throw MiddewareError.AlreadyHasContextType("\(c.dynamicType)")
            }
        }
        ctxs.insert(ctx, atIndex: 0)
    }
    var description: String {
        return "\(ctxs.map({ return $0.dynamicType.self }))"
    }
    
}
