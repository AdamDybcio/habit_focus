/// Deployment environment the app was built for.
enum Flavor {
  /// Local development against a development backend.
  dev,

  /// Pre-production environment used for testing releases.
  staging,

  /// Production environment.
  prod,
}
