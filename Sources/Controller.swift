//
//  Controller.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//


public protocol ControllerMiddleware: MiddlewareType {
    func get(ctx: ContextBox) throws -> MiddlewareResult
    func post(ctx: ContextBox) throws -> MiddlewareResult
    func put(ctx: ContextBox) throws -> MiddlewareResult
    func delete(ctx: ContextBox) throws -> MiddlewareResult
}

public extension ControllerMiddleware {
    func handle(ctx: ContextBox) throws -> MiddlewareResult {
        switch ctx.request.method {
        case .GET:
            return try get(ctx)
        case .POST:
            return try post(ctx)
        case .PUT:
            return try put(ctx)
        case .DELETE:
            return try delete(ctx)
        default:
            return .Next
        }
    }
    func get(ctx: ContextBox) throws -> MiddlewareResult { return .Next }
    func post(ctx: ContextBox) throws -> MiddlewareResult { return .Next }
    func put(ctx: ContextBox) throws -> MiddlewareResult { return .Next }
    func delete(ctx: ContextBox) throws -> MiddlewareResult { return .Next }
}