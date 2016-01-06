//
//  Application.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import HTTP

struct Responder: ResponderType {
    let respond: (request: Request) throws -> Response
    func respond(request: Request) throws -> Response {
        return try respond(request: request)
    }
}

public protocol AppType: MiddlewareType, AnyRequestHandleable {
    var wrap: [WrapMiddleware] { get }
    var middleware: [MiddlewareType] { get }
    var responder: ResponderType { get }
    func createContext(request: Request) throws -> ContextBox
    func catchError(e: ErrorType)
}


public extension AppType {
    
    var handler: MiddlewareType {
        return GenericMiddleware { ctx in
            var current = compose(self.middleware)
            for m in self.wrap.reverse() {
                current = GenericMiddleware(handler: m.genHandler(current))
            }
            return try current.handleIfNeeded(ctx)
        }
    }
    
    func handle(ctx: ContextBox) throws -> MiddlewareResult {
        return try handler.handleIfNeeded(ctx)
    }
    
    var responder: ResponderType {
        let handler = self.handler
        return Responder{ request in
            do {
                switch try handler.handleIfNeeded(try self.createContext(request)) {
                case .Next:
                    return Response(status: .NotFound)
                case .Respond(let res):
                    return res
                }
            } catch(let e) {
                self.catchError(e)
                throw e
            }
        }
    }
    
    func catchError(e: ErrorType) {
        
    }
}