// Constants related to scheduling behavior and performance tuning

// Number of months to prefetch (current month + next N months)
const int kMonthsPrefetchRadius = 3;

// Number of months around "now" to ensure initially (previous, current, next)
const int kInitialEnsureMonthsRadius = 1;

// Expected number of schedules per day (used for coverage heuristic)
const int kExpectedSchedulesPerDay = 5;

// Fraction of expected schedules that indicates sufficient coverage
const double kCoverageThreshold = 0.8;
