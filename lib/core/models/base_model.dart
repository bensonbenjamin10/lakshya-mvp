/// Base model interface for all data models
/// 
/// Ensures consistent serialization across all models
abstract class BaseModel {
  /// Convert model to JSON map
  Map<String, dynamic> toJson();

  /// Create model from JSON map
  /// 
  /// Implementations should provide a factory constructor:
  /// ```dart
  /// factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(...);
  /// ```
}

