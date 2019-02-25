import Vapor
import FluentPostgreSQL
import Authentication
import Leaf

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // Configure the rest of your application here
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    services.register(NIOServerConfig.default(hostname: "0.0.0.0", port: 8080, maxBodySize: 20_000_000))
    
    let drtConfig = DirectoryConfig.detect()
    services.register(drtConfig)

    let db = Environment.get("POSTGRES_DB") ?? "test"
    let host = Environment.get("POSTGRES_HOST") ?? "localhost"
    let user = Environment.get("POSTGRES_USER") ?? "postgres"
    let pass = Environment.get("POSTGRES_PASSWORD")

    var port = 5432
    if let param = Environment.get("POSTGRES_PORT"), let newPort = Int(param) {
        port = newPort
    }

    let pgConfig = PostgreSQLDatabaseConfig(hostname: host, port: port, username: user, database: db, password: pass)
    let pgsql = PostgreSQLDatabase(config: pgConfig)

    var dbsConfig = DatabasesConfig()
    dbsConfig.add(database: pgsql, as: .psql)
    services.register(dbsConfig)
    
    var mgrConfig = MigrationConfig()
    mgrConfig.add(model: User.self, database: .psql)
    mgrConfig.add(model: Topic.self, database: .psql)
    mgrConfig.add(model: Reply.self, database: .psql)
    mgrConfig.add(model: UserTopicPivot.self, database: .psql)
    mgrConfig.add(model: UserReplyPivot.self, database: .psql)
    mgrConfig.add(model: BlockedTopic.self, database: .psql)
    mgrConfig.add(model: BlockedUser.self, database: .psql)
    mgrConfig.add(model: BlockedHost.self, database: .psql)
    mgrConfig.add(model: BlockedLink.self, database: .psql)
    mgrConfig.add(model: ReportedLink.self, database: .psql)
    mgrConfig.add(model: GlobalBlockedTopic.self, database: .psql)
    mgrConfig.add(model: GlobalBlockedUser.self, database: .psql)
    mgrConfig.add(model: GlobalBlockedHost.self, database: .psql)
    mgrConfig.add(model: GlobalBlockedLink.self, database: .psql)
    mgrConfig.add(model: GlobalWhiteUser.self, database: .psql)
    mgrConfig.add(model: GlobalWhiteHost.self, database: .psql)
    mgrConfig.add(model: GlobalWhiteLink.self, database: .psql)
    services.register(mgrConfig)
}
