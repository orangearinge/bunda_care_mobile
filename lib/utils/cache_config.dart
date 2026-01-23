import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Cache configuration and policies for different data types
class CacheConfig {
  // Cache duration constants
  static const Duration _articles = Duration(hours: 3);
  static const Duration _foodDetails = Duration(hours: 1);
  static const Duration _dashboard = Duration(minutes: 15);
  static const Duration _userProfile = Duration(minutes: 30);
  static const Duration _recommendations = Duration(minutes: 20);

  /// Default cache options for articles
  /// Articles rarely change and are read-heavy
  static CacheOptions get articles => CacheOptions(
    store: null, // Will be set in ApiService
    policy: CachePolicy.request,
    maxStale: _articles,
    priority: CachePriority.high,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  );

  /// Cache options for food/menu details
  /// Nutrition data is static
  static CacheOptions get foodDetails => CacheOptions(
    store: null,
    policy: CachePolicy.request,
    maxStale: _foodDetails,
    priority: CachePriority.high,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  );

  /// Cache options for dashboard data
  /// Needs to be relatively fresh but not real-time
  static CacheOptions get dashboard => CacheOptions(
    store: null,
    policy: CachePolicy.request,
    maxStale: _dashboard,
    priority: CachePriority.normal,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  );

  /// Cache options for user profile
  /// Changes infrequently unless explicitly updated
  static CacheOptions get userProfile => CacheOptions(
    store: null,
    policy: CachePolicy.request,
    maxStale: _userProfile,
    priority: CachePriority.normal,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  );

  /// Cache options for AI recommendations
  /// Personalized but can be cached temporarily
  static CacheOptions get recommendations => CacheOptions(
    store: null,
    policy: CachePolicy.request,
    maxStale: _recommendations,
    priority: CachePriority.low,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  );

  /// Force refresh - bypass cache entirely
  static CacheOptions get forceRefresh => CacheOptions(
    store: null,
    policy: CachePolicy.refresh,
    priority: CachePriority.high,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  );

  /// No cache - for mutations and sensitive operations
  static CacheOptions get noCache => CacheOptions(
    store: null,
    policy: CachePolicy.noCache,
    priority: CachePriority.normal,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  );
}
