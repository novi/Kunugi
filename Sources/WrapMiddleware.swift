//
//  WrapMiddleware.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

public protocol WrapMiddleware: MiddlewareHandleable {
    func handle(ctx: ContextBox, @noescape yieldNext: () throws -> Void) throws
    func genHandler(inner: MiddlewareType) -> (ContextBox throws -> MiddlewareResult)
}

public extension WrapMiddleware {
    func genHandler(inner: MiddlewareType) -> (ContextBox throws -> MiddlewareResult) {
        return { ctx in
            if self.shouldHandle(ctx.request) == false {
                return try inner.handleIfNeeded(ctx)
            }
            var res: MiddlewareResult?
            try self.handle(ctx, yieldNext: {
                res = try inner.handleIfNeeded(ctx)
            })
            return res!
        }
    }
    
    func handle(ctx: ContextBox,  @noescape yieldNext: () throws -> Void ) throws {
        try yieldNext()
    }
}
