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
        rewriteBefore(ctx)
        return try inner.handleIfNeeded(ctx)
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
        print("\(path) > \(newPath)")
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
    func rewriteBefore(ctx: ContextBox) {
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