// Constants related to scheduling behavior and performance tuning

// Number of months to prefetch (current month + next N months)
// Tuned down to reduce background work per navigation
const int kMonthsPrefetchRadius = 1;

// Number of months around "now" to ensure initially (previous, current, next)
const int kInitialEnsureMonthsRadius = 1;

// Number of months to keep in memory to prevent accumulation (past months)
const int kMonthsToKeepInMemory = 4;

// Expected number of schedules per day (used for coverage heuristic)
const int kExpectedSchedulesPerDay = 5;

// Fraction of expected schedules that indicates sufficient coverage
const double kCoverageThreshold = 0.8;

// Cache configuration
const Duration kCacheValidityDuration = Duration(minutes: 10);
const int kMaxCacheEntries = 25;

// UI optimization
const Duration kBatchDelay = Duration(milliseconds: 16); // ~60fps

// Schedule data cache configuration
const Duration kScheduleDataCacheValidityDuration = Duration(minutes: 5);
