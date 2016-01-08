//
//  WrapMiddleware.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

public protocol WrapMiddleware: MiddlewareHandleable {
    func handle(ctx: ContextBox, @noescape yieldNext: () throws -> MiddlewareResult) throws -> MiddlewareResult
    func genHandler(inner: MiddlewareType) -> (ContextBox throws -> MiddlewareResult)
}

public extension WrapMiddleware {
    func genHandler(inner: MiddlewareType) -> (ContextBox throws -> MiddlewareResult) {
        return { ctx in
            if self.shouldHandle(ctx.request) == false {
                return try inner.handleIfNeeded(ctx)
            }
            return try self.handle(ctx, yieldNext: {
                return try inner.handleIfNeeded(ctx)
            })
        }
    }
    
    func handle(ctx: ContextBox,  @noescape yieldNext: () throws -> MiddlewareResult ) throws -> MiddlewareResult {
        return try yieldNext()
    }
}
