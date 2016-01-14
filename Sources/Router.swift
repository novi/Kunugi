//
//  Middeware2.swift.swift
//  todoapi
//
//  Created by ito on 1/2/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import Foundation

public protocol RouteWrap: MiddlewareType {
    var inner: MiddlewareType { get }
    func rewritePath(path: String) -> String
    func shouldHandle(ctx: ContextBox, path: String) -> Bool
    func rewriteBefore(ctx: ContextBox)
}

public extension RouteWrap {
    func rewritePath(path: String) -> String {
        return path
    }
    func shouldHandle(ctx: ContextBox) -> Bool {
        return shouldHandle(ctx, path: ctx.path)
    }
    func handle(ctx: ContextBox) throws -> MiddlewareResult {
        let orig = ctx.path
        rewriteBefore(ctx)
        let res = try inner.handleIfNeeded(ctx)
        switch res {
        case .Next:
            ctx.path = orig
        default: break
        }
        return res
    }
    func rewriteBefore(ctx: ContextBox) {
        let newPath = rewritePath(ctx.path)
        if ctx.path == newPath {
            return
        }
        print("\(ctx.path) > \(newPath)(\(newPath.characters.count))")
        ctx.path = newPath
        return
    }
}

public struct Route: RouteWrap {
    
    struct PathMatch {
        let patts: [String] // /:id/sub/:val -> :id, sub, :val
        let paramKeys: [String?] // -> "id", nil, "val"
        init?(_ pattern: String) {
            if pattern.characters.contains(":") == false {
                return nil
            }
            self.patts = pattern.characters.split("/").map(String.init)
            for p in patts {
                if p.characters.count == 0 {
                    print("invalid path pattern \(pattern)")
                    return nil
                }
            }
            let keys:[String?] = patts.map{ $0.characters.count > 0 && $0.characters.first == Character(":") ? $0 : nil }
            self.paramKeys = keys.map({ $0.flatMap({ $0[$0.startIndex.advancedBy(1)..<$0.endIndex] }) }) // trim first ":" each key
            //print(patts, paramKeys)
        }
        func match(path: String) -> [String: String] {
            let pathSlice = path.characters.split("/").map(String.init)
            if pathSlice.count != patts.count {
                return [:]
            }
            var params:[String:String] = [:]
            for i in 0..<pathSlice.count {
                if let key = paramKeys[i] {
                    params[key] = pathSlice[i]
                } else {
                    if pathSlice[i] != patts[i] {
                        return [:]
                    }
                }
            }
            return params
        }
        func match(path: String) -> Bool {
            return (match(path) as [String: String]).count > 0
        }
    }
    
    enum Pattern {
        case Match(PathMatch)
        case Path(String)
    }
    let pattern: Pattern
    
    public let inner: MiddlewareType
    public func shouldHandle(ctx: ContextBox, path: String) -> Bool {
        switch pattern {
        case .Path(let pat):
            return pat == path
        case .Match(let match):
            return match.match(path)
        }
    }
    
    public init(_ path: String, _ inner: MiddlewareType) {
        self.inner = inner
        if let match = PathMatch(path) {
            self.pattern = .Match(match)
        } else {
            self.pattern = .Path(path)
        }
    }
    public func rewriteBefore(ctx: ContextBox) {
        let path = ctx.path
        guard path.characters.count > 0 else {
            return
        }
        switch pattern {
        case .Match(let match):
            for (k, v) in match.match(path) {
                ctx.parameters[k] = v
            }
        default: break
        }
    }
}

public struct Mount: RouteWrap {
    let prefix: String
    public let inner: MiddlewareType
    
    public func shouldHandle(ctx: ContextBox, path: String) -> Bool {
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
        let methods: Set<Method>
        let handler: MiddlewareHandler
        func handle(ctx: ContextBox) throws -> MiddlewareResult {
            return try handler(ctx)
        }
    }
    
    
    public init() {
        
    }
    
    func handle(methods: Set<Method>, path: String, handler: MiddlewareHandler) {
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
    
    public func shouldHandle(ctx: ContextBox) -> Bool {
        return outer.shouldHandle(ctx)
    }
    public func handle(ctx: ContextBox) throws -> MiddlewareResult {
        return try outer.handle(ctx)
    }
}



