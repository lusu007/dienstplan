// Constants related to scheduling behavior and performance tuning

// Number of months to prefetch (current month + next N months)
// Reduced from 3 to 2 to improve performance and reduce memory usage
const int kMonthsPrefetchRadius = 2;

// Number of months around "now" to ensure initially (previous, current, next)
const int kInitialEnsureMonthsRadius = 1;

// Number of months to keep in memory to prevent accumulation (past months)
const int kMonthsToKeepInMemory = 6;

// Expected number of schedules per day (used for coverage heuristic)
const int kExpectedSchedulesPerDay = 5;

// Fraction of expected schedules that indicates sufficient coverage
const double kCoverageThreshold = 0.8;

// Cache configuration
const Duration kCacheValidityDuration = Duration(minutes: 10);
const int kMaxCacheEntries = 25;

// UI optimization
const Duration kBatchDelay = Duration(milliseconds: 16); // ~60fps
