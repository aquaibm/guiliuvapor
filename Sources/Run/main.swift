import App
import Service
import Vapor
import Foundation

// The contents of main are wrapped in a do/catch block because any errors that get raised to the top level will crash Xcode
do {
    if
        let param = ProcessInfo.processInfo.environment["SLEEP_LENGTH"],
        let duration = UInt32(param), duration > 0
    {
        sleep(duration)
    }

    var config = Config.default()
    var env = try Environment.detect()
    var services = Services.default()
    
    try App.configure(&config, &env, &services)
    
    let app = try Application(
        config: config,
        environment: env,
        services: services
    )
    
    try App.boot(app)
    
    try app.run()
} catch {
    print(error)
    exit(1)
}
