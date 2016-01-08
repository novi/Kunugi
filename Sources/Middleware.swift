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



public protocol MethodHandleable: MiddlewareHandleable {
    var methods: Set<HTTP.Method> { get }
}

public extension MethodHandleable {
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

public protocol AnyRequestHandleable: MiddlewareHandleable {
}

public extension AnyRequestHandleable {
    public func shouldHandle(req: Request) -> Bool {
        return true
    }
}

public typealias MiddlewareHandler = ContextBox throws -> MiddlewareResult

struct GenericMiddleware: MiddlewareType, AnyRequestHandleable {
    let handler: MiddlewareHandler
    func handle(ctx: ContextBox) throws -> MiddlewareResult {
        return try handler(ctx)
    }
}


