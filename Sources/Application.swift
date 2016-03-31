//
//  Application.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

public protocol AppType {
    var wrap: [WrapMiddleware] { get }
    var middleware: [MiddlewareType] { get }
    var handler: MiddlewareType { get }
}

public extension AppType {
    
    var handler: MiddlewareType {
        return GenericMiddleware { ctx in
            var current = compose(self.middleware)
            for m in self.wrap.reversed() {
                current = GenericMiddleware(handler: m.genHandler(current))
            }
            return try current.handleIfNeeded(ctx)
        }
    }
    
}