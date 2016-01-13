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
    func before(ctx: ContextBox) throws -> MiddlewareResult
    func after(ctx: ContextBox, result: MiddlewareResult) throws -> MiddlewareResult
}

public extension ControllerMiddleware {
    func before(ctx: ContextBox) throws -> MiddlewareResult {
        return .Next
    }
    func after(ctx: ContextBox, result: MiddlewareResult) throws -> MiddlewareResult {
        return result
    }
    func handle(ctx: ContextBox) throws -> MiddlewareResult {
        switch try before(ctx) {
        case .Next:
            let result: MiddlewareResult
            switch ctx.method {
            case .GET:
                result = try get(ctx)
            case .POST:
                result = try post(ctx)
            case .PUT:
                result = try put(ctx)
            case .DELETE:
                result = try delete(ctx)
            default:
                result = .Next
            }
            return try after(ctx, result: result)
            
        case .Respond(let res):
            return .Respond(res)
        }
    }
    func get(ctx: ContextBox) throws -> MiddlewareResult { return .Next }
    func post(ctx: ContextBox) throws -> MiddlewareResult { return .Next }
    func put(ctx: ContextBox) throws -> MiddlewareResult { return .Next }
    func delete(ctx: ContextBox) throws -> MiddlewareResult { return .Next }
}