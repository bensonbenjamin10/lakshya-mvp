/// Base repository interface following Repository Pattern
/// 
/// Provides generic CRUD operations that all repositories can extend.
/// This follows SOLID principles - Single Responsibility and Dependency Inversion.
abstract class BaseRepository<T> {
  /// Get all entities
  Future<List<T>> getAll();

  /// Get entity by ID
  Future<T?> getById(String id);

  /// Create a new entity
  Future<T> create(T entity);

  /// Update an existing entity
  Future<T> update(T entity);

  /// Delete an entity by ID
  Future<void> delete(String id);
}
