//
//  Middleware1.swift
//  todoapi
//
//  Created by ito on 1/2/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import HTTP
import Core

public enum MiddlewareResult {
    case Next
    case Respond(Response)
}

public protocol MiddlewareType: MiddlewareHandleable {
    
    func handle(ctx: ContextBox) throws -> MiddlewareResult
    func handleIfNeeded(ctx: ContextBox) throws -> MiddlewareResult
}

public extension MiddlewareType {
    
    public func handleIfNeeded(ctx: ContextBox) throws -> MiddlewareResult {
        guard shouldHandle(ctx.request) else {
            return .Next
        }
        return try handle(ctx)
    }
}


public protocol MiddlewareHandleable {
    func shouldHandle(req: Request) -> Bool
}



public protocol MethodHandleType: MiddlewareHandleable {
    var methods: Set<HTTP.Method> { get }
}

public extension MethodHandleType {
    var methods: Set<HTTP.Method> {
        return Set([
            .DELETE,
            .GET,
            .HEAD,
            .POST,
            .PUT,
            .OPTIONS
            ])
    }
    func shouldHandle(req: Request) -> Bool {
        return methods.contains(req.method)
    }
}

/*protocol PathHandleType: MiddewareHandlable {
var path: String { get }

}

extension PathHandleType {
var path: String {
return "*"
}
func shouldHandle(req: Request) -> Bool {
return (path == "*" || (req.uri.path ?? "") == path)
}
}*/

public protocol AnyRequestHandlable: MiddlewareHandleable {
}

public extension AnyRequestHandlable {
    public func shouldHandle(req: Request) -> Bool {
        return true
    }
}


struct GenericMiddleware: MiddlewareType, AnyRequestHandlable {
    let handler: ContextBox throws -> MiddlewareResult
    func handle(ctx: ContextBox) throws -> MiddlewareResult {
        return try handler(ctx)
    }
}


