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

public protocol AppType {
    var wrap: [WrapMiddleware] { get }
    var middleware: [MiddlewareType] { get }
    var responder: ResponderType { get }
    func createContext(request: Request) throws -> ContextBox
}


public extension AppType {
    
    var responder: ResponderType {
        return Responder{ request in
            let ms = self.wrap.reverse()
            var current = compose(self.middleware)
            for m in ms {
                print("context created \(m)")
                current = GenericMiddleware(handler: m.genHandler(current))
            }
            
            switch try current.handleIfNeeded(try self.createContext(request)) {
            case .Next:
                return Response(status: .NotFound)
            case .Respond(let res):
                return res
            }
        }
    }
    
    func createContext(request: Request) throws -> ContextBox {
        return Context(request)
    }
    
}