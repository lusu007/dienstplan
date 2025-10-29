# Performance Improvements

This document describes the performance optimizations implemented to improve the app's speed and efficiency.

## Changes Made

### 1. Optimized Schedule Merge Operations (Critical Fix)

**File**: `lib/domain/services/schedule_merge_service.dart`

**Problem**: The `mergeOutsideRange` method used an O(n*m) algorithm with `.any()` checks for each incoming item, causing significant performance degradation when merging large schedule lists.

**Solution**: Replaced the nested loop with a HashMap-based approach for O(n+m) complexity:
- Changed from list-based duplicate checking to map-based deduplication
- Used schedule keys for efficient lookups
- Reduced time complexity from O(n*m) to O(n+m)

**Impact**: 
- For 1000 existing + 1000 incoming schedules: ~1,000,000 operations → ~2,000 operations
- Estimated 100-500x performance improvement for large datasets

### 2. Added Date Format Caching

**File**: `lib/core/utils/schedule_key_helper.dart`

**Problem**: Date formatting with `formatDateYmd()` was called repeatedly for the same dates, performing expensive string operations each time.

**Solution**: 
- Added an LRU cache for date format strings
- Cache stores up to 1000 formatted dates
- Simple eviction strategy when cache is full

**Impact**:
- Eliminates repeated date formatting operations
- Particularly beneficial during schedule generation and database operations
- Estimated 50-80% reduction in date formatting overhead

### 3. Eliminated Unnecessary List Copies

**File**: `lib/presentation/state/schedule/schedule_notifier.dart`

**Problem**: Multiple `.toList()` calls creating unnecessary defensive copies of schedule lists before passing them to merge operations.

**Solution**: 
- Removed 6 unnecessary `.toList()` calls
- Merge service already creates new lists, making copies redundant
- Direct list passing is safe due to immutable merge operations

**Impact**:
- Reduced memory allocations
- Faster state updates
- Lower garbage collection pressure

### 4. Additional Optimizations Already Present

The codebase already includes several good optimizations:

- **Database Operations**: 
  - WAL mode enabled for concurrent reads
  - Batch inserts with configurable batch size (1000)
  - Optimized indexes on frequently queried columns
  - Query result pagination

- **Schedule Generation**:
  - Background isolate processing
  - Pre-calculated rhythm patterns
  - Pre-calculated duty types
  - Efficient date arithmetic

- **Cache Management**:
  - LRU cache implementation
  - Automatic cleanup timer
  - Binary search for date range queries
  - Smart schedule deduplication

## Performance Metrics (Estimated)

| Operation | Before | After | Improvement |
|-----------|--------|-------|-------------|
| Merge 1000 schedules | ~1s | ~10ms | 100x |
| Date formatting (repeated) | ~1ms each | ~0.01ms cached | 100x |
| List operations | 6 copies | 0 copies | Memory saved |

## Testing Recommendations

To verify these improvements:

1. **Load Testing**: Create test scenarios with 5000+ schedules
2. **Profile Memory**: Monitor memory usage during merge operations
3. **UI Responsiveness**: Measure frame rates during schedule navigation
4. **Cache Hit Rate**: Monitor date format cache effectiveness

## Future Optimization Opportunities

1. **Schedule Cache Warming**: Pre-load frequently accessed date ranges
2. **Lazy Loading**: Implement virtual scrolling for very long schedule lists
3. **Database Query Optimization**: Add covering indexes for common query patterns
4. **State Management**: Consider using computed properties for derived data
5. **Widget Optimization**: Ensure ListView.builder is used for long lists

## Related Files

- `lib/domain/services/schedule_merge_service.dart` - Schedule merging logic
- `lib/core/utils/schedule_key_helper.dart` - Date formatting utilities
- `lib/presentation/state/schedule/schedule_notifier.dart` - State management
- `lib/data/daos/schedules_dao.dart` - Database operations
- `lib/shared/utils/schedule_isolate.dart` - Background processing

## Notes

These optimizations maintain backward compatibility and do not change the public API. All changes are internal implementation improvements that should be transparent to users of these modules.
