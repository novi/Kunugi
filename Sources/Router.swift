//
//  Middeware2.swift.swift
//  todoapi
//
//  Created by ito on 1/2/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import HTTP
import Core

public protocol RouteWrap: MiddlewareType {
    var inner: MiddlewareType { get }
    func rewritePath(path: String) -> String
    func shouldHandle(req: Request, path: String) -> Bool
    func rewriteBefore(ctx: ContextBox)
}

public extension RouteWrap {
    func rewritePath(path: String) -> String {
        return path
    }
    func shouldHandle(req: Request) -> Bool {
        guard let path = req.uri.path else {
            return false
        }
        return shouldHandle(req, path: path)
    }
    func handle(ctx: ContextBox) throws -> MiddlewareResult {
        let orig = ctx.request
        rewriteBefore(ctx)
        let res = try inner.handleIfNeeded(ctx)
        switch res {
        case .Next:
            ctx.request = orig
        default: break
        }
        return res
    }
    func rewriteBefore(ctx: ContextBox) {
        let req = ctx.request
        let uri = req.uri
        guard let path = req.uri.path else {
            return
        }
        let newPath = rewritePath(path)
        if path == newPath {
            return
        }
        print("\(path) > \(newPath)(\(newPath.characters.count))")
        let newUri = URI(scheme: uri.scheme, userInfo: uri.userInfo, host: uri.host, port: uri.port, path: newPath, query: uri.query, fragment: uri.fragment)
        
        ctx.request = Request(method: req.method, uri: newUri, majorVersion: req.majorVersion, minorVersion: req.minorVersion, headers: req.headers, body: req.body)
        return
    }
}

public struct Route: RouteWrap {
    let regEx: Regex
    public let inner: MiddlewareType
    let paramKeys: [String]
    
    public func shouldHandle(req: Request, path: String) -> Bool {
        return regEx.matches(path)
    }
    public init(_ path: String, _ inner: MiddlewareType) {
        let paramRegExp = try! Regex(pattern: ":([[:alnum:]]+)")
        let pattern = paramRegExp.replace(path, withTemplate: "([[:alnum:]_-]+)")
        
        self.paramKeys = paramRegExp.groups(path)
        self.regEx = try! Regex(pattern: "^" + pattern + "$")
        self.inner = inner
    }
    public func rewriteBefore(ctx: ContextBox) {
        let values = self.regEx.groups(ctx.request.uri.path!)
        
        for (index, key) in paramKeys.enumerate() {
            ctx.request.parameters[key] = values[index]
        }
    }
}

public struct Mount: RouteWrap {
    let prefix: String
    public let inner: MiddlewareType
    
    public func shouldHandle(req: Request, path: String) -> Bool {
        if path.hasPrefix(prefix) {
            let newPath = rewritePath(path)
            // check that "/private" does not match "/privateeee"
            if newPath.characters.count == 0 ||
                (newPath.characters.count > 0 && newPath.characters.first == Character("/")) {
                    return true
            }
        }
        return false
    }
    public func rewritePath(path: String) -> String {
        var newPath = path
        newPath.replaceRange(prefix.startIndex..<prefix.startIndex.advancedBy(prefix.characters.count), with: "")
        return newPath
    }
    public init(_ prefix: String, _ inner: MiddlewareType) {
        self.prefix = prefix
        self.inner = inner
    }
}

public class Router: MiddlewareType {
    var outer: MiddlewareType = GenericMiddleware { ctx in .Next }
    var routes: [MiddlewareType] = []
    
    struct MethodMiddleware: MethodHandleable, MiddlewareType {
        let methods: Set<HTTP.Method>
        let handler: MiddlewareHandler
        func handle(ctx: ContextBox) throws -> MiddlewareResult {
            return try handler(ctx)
        }
    }
    
    
    public init() {
        
    }
    
    func handle(methods: Set<HTTP.Method>, path: String, handler: MiddlewareHandler) {
        routes.append(Route(path, MethodMiddleware(methods: methods, handler: handler)))
        self.outer = compose(routes)
    }
    
    public func all(path: String, _ handler: MiddlewareHandler) {
        handle(Set([
            .DELETE,
            .GET,
            .HEAD,
            .POST,
            .PUT,
            .OPTIONS
            ]), path: path, handler: handler)
    }
    
    public func get(path: String, _ handler: MiddlewareHandler) {
        handle(Set([.GET]), path: path, handler: handler)
    }
    
    public func post(path: String, _ handler: MiddlewareHandler) {
        handle(Set([.POST]), path: path, handler: handler)
    }
    
    public func put(path: String, _ handler: MiddlewareHandler) {
        handle(Set([.PUT]), path: path, handler: handler)
    }
    
    public func delete(path: String, _ handler: MiddlewareHandler) {
        handle(Set([.DELETE]), path: path, handler: handler)
    }
    
    public func shouldHandle(req: Request) -> Bool {
        return outer.shouldHandle(req)
    }
    public func handle(ctx: ContextBox) throws -> MiddlewareResult {
        return try outer.handle(ctx)
    }
}



