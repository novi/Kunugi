//
//  Composer.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

infix operator >>> { associativity left }


public func >>>(a: MiddlewareType, b: MiddlewareType) -> MiddlewareType {
    return compose(a, b)
}

public func compose(middewares: MiddlewareType...) -> MiddlewareType {
    return compose(middewares)
}

public func compose(middewares: [MiddlewareType]) -> MiddlewareType {
    return GenericMiddleware { ctx in
        for m in middewares {
            switch try m.handleIfNeeded(ctx) {
            case .Next:
                break
            case .Respond(let res):
                return .Respond(res)
            }
        }
        return .Next
    }
}