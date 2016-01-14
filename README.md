# Kunugi

Kunugi(椚) is minimal web framework and middleware systems for Swift. This is inpired by Node.js' [Koa](http://koajs.com).

Kunugi doesn't provide http server its self. It works with [Epoch](https://github.com/Zewo/Epoch).

See [example project](https://github.com/novi/todoapi-example/tree/experimental/todoapi/todoapi) until documents is done.

_Note:_ This is in early development project.

# Usage

Define your context and app.

```swift
import Kunugi

class Context: ContextBox {
    var context: [ContextType] = []
    var request: Request
    
    var method: Method
    var path: String
    var parameters: [String: String] = [:]
    
    init(request: Request) {
    	self.request = request
    	self.path = request.path
    	self.method = Method(request.method)
    }
}

class App: AppType {

    var wrap: [WrapMiddleware] = []
    var middleware: [MiddlewareType] = []
    
    func use(m: WrapMiddleware) {
        wrap.append(m)
    }
    
    func use(m: MiddlewareType) {
        middleware.append(m)
    }
    
    func createContext(request: Request) throws -> ContextBox {
        return Context(request: request)
    }
    
    ...
}

```

Create your request handler.

```swift
// Closure style handler with routes
let router = Router()
router.get("/hello") { ctx in
    return .Respond(Response(status: .OK, body: "world"))
}

// Controller style handler
struct HelloController: ControllerMiddleware, AnyRequestHandleable {
    func post(ctx: ContextBox) throws -> MiddlewareResult {
        return .Respond(Response(status: .OK, body: "hello world"))
    }
}

```

Stack your middleware to the app.

```swift
let app = App()

app.use(Logger())
app.use(BodyParser())

app.use(router)
app.use( Route("/helloworld", HelloController()) )

Server(port: 3000, responder: app.responder).start()
```

# Requirements

* Swift 2.1 or Later (includes Linux support)
* OS X 10.10 or Later


# License

MIT
