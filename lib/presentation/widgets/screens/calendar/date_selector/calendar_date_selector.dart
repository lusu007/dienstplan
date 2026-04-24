import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/animation_constants.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_picker_controls.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_year_picker_layout.dart';
import 'package:intl/intl.dart';

class CalendarDateSelector extends ConsumerStatefulWidget {
  final DateTime currentDate;
  final Function(DateTime) onDateSelected;
  final Locale locale;
  final DateTime? selectedDay; // Add selected day parameter

  const CalendarDateSelector({
    super.key,
    required this.currentDate,
    required this.onDateSelected,
    required this.locale,
    this.selectedDay, // Optional parameter
  });

  @override
  ConsumerState<CalendarDateSelector> createState() =>
      _CalendarDateSelectorState();
}

class _CalendarDateSelectorState extends ConsumerState<CalendarDateSelector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  PageController? _monthPageController;
  PageController? _yearPageController;
  bool _isYearView = false;
  late int _displayedYear;
  late int _selectedYear;
  late int _selectedMonth;
  late int _yearBlockStart;
  int _pageControllerKey = 0;
  late int _originalSelectedDay; // Store the originally selected day
  bool _needsMonthPageSync = false;
  bool _isMonthPageSyncScheduled = false;
  int get _minYear => CalendarConfig.firstDay.year;
  int get _maxYear => CalendarConfig.lastDay.year;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: kAnimDefault,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _selectedYear = widget.currentDate.year;
    _selectedMonth = widget.currentDate.month;
    _displayedYear = _selectedYear;
    _yearBlockStart = calendarYearBlockStartForYear(
      minYear: _minYear,
      maxYear: _maxYear,
      year: _selectedYear,
    );
    // Use the selected day if provided, otherwise use the current date day
    _originalSelectedDay = widget.selectedDay?.day ?? widget.currentDate.day;
  }

  @override
  void didUpdateWidget(CalendarDateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the original selected day if the selected day changes
    if (widget.selectedDay != oldWidget.selectedDay &&
        widget.selectedDay != null) {
      _originalSelectedDay = widget.selectedDay!.day;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _monthPageController?.dispose();
    _yearPageController?.dispose();
    super.dispose();
  }

  /// Total height of the 4×3 picker grid (matches [SliverGridDelegate] + grid padding in [_buildMonthGrid] / [_buildYearGrid]).
  double _pickerGridHeightForLayoutWidth(double width) {
    const int crossAxisCount = 4;
    const double crossAxisSpacing = 10;
    const double mainAxisSpacing = 10;
    const double childAspectRatio = 1.2;
    const double gridHorizontalPadding = 32; // 16 + 16 (LTRB in grid)
    const double gridVerticalPadding = 24; // 12 + 12
    final double innerWidth = (width - gridHorizontalPadding).clamp(
      0.0,
      double.infinity,
    );
    final double cellWidth =
        (innerWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
    final double cellHeight = cellWidth / childAspectRatio;
    return gridVerticalPadding + 3 * cellHeight + 2 * mainAxisSpacing;
  }

  void _showDateSwitcher() {
    // Reset to current year when opening the modal, but respect year limits
    final currentYear = widget.currentDate.year;
    final clampedYear = currentYear.clamp(_minYear, _maxYear);

    setState(() {
      _selectedYear = clampedYear; // Initialize selected year
      _displayedYear = clampedYear;
      _yearBlockStart = calendarYearBlockStartForYear(
        minYear: _minYear,
        maxYear: _maxYear,
        year: clampedYear,
      );
      _isYearView = false;
      _needsMonthPageSync = false;
      _isMonthPageSyncScheduled = false;
    });

    // Initialize page controllers to correct positions
    final monthPageIndex = calendarMonthPickerPageIndex(
      minYear: _minYear,
      maxYear: _maxYear,
      year: clampedYear,
    );
    final yearPageIndex = calendarYearPickerPageIndex(
      minYear: _minYear,
      maxYear: _maxYear,
      year: clampedYear,
    );

    // Initialize page controllers
    _monthPageController?.dispose();
    _yearPageController?.dispose();
    _monthPageController = PageController(initialPage: monthPageIndex);
    _yearPageController = PageController(initialPage: yearPageIndex);
    _pageControllerKey++; // Force rebuild of PageView

    _animationController.forward();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return _buildDateSwitcherModal(setModalState);
        },
      ),
    ).then((_) {
      _animationController.reverse();
      // Reset page controllers when modal is closed
      _monthPageController?.dispose();
      _yearPageController?.dispose();
      _monthPageController = null;
      _yearPageController = null;
      _needsMonthPageSync = false;
      _isMonthPageSyncScheduled = false;
    });
  }

  void _syncMonthPageToSelectedYear() {
    final PageController? monthPageController = _monthPageController;
    if (monthPageController == null || !monthPageController.hasClients) {
      _needsMonthPageSync = true;
      return;
    }
    _needsMonthPageSync = false;
    final int targetPage = calendarMonthPickerPageIndex(
      minYear: _minYear,
      maxYear: _maxYear,
      year: _selectedYear,
    );
    final int currentPage =
        monthPageController.page?.round() ?? monthPageController.initialPage;
    if (currentPage == targetPage) {
      return;
    }
    monthPageController.jumpToPage(targetPage);
  }

  Widget _buildDateSwitcherModal(StateSetter setModalState) {
    if (!_isYearView && _needsMonthPageSync && !_isMonthPageSyncScheduled) {
      _isMonthPageSyncScheduled = true;
      _needsMonthPageSync = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isMonthPageSyncScheduled = false;
        if (!mounted || _isYearView) {
          return;
        }
        _syncMonthPageToSelectedYear();
      });
    }
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double layoutWidth = constraints.maxWidth;
              final double gridHeight = _pickerGridHeightForLayoutWidth(
                layoutWidth,
              );
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: GlassDialogSurface(
                    borderRadius: const BorderRadius.all(Radius.circular(28)),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDragHandle(),
                          _isYearView
                              ? _buildYearHeader(setModalState)
                              : _buildMonthHeader(setModalState),
                          SizedBox(
                            height: gridHeight,
                            child: _isYearView
                                ? (_yearPageController != null
                                      ? PageView.builder(
                                          key: ValueKey(
                                            'year_$_pageControllerKey',
                                          ),
                                          controller: _yearPageController!,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          onPageChanged: (pageIndex) {
                                            setState(() {
                                              _yearBlockStart =
                                                  calendarYearBlockStartForYear(
                                                    minYear: _minYear,
                                                    maxYear: _maxYear,
                                                    year:
                                                        _minYear +
                                                        (pageIndex * 12),
                                                  );
                                            });
                                            setModalState(() {});
                                          },
                                          itemCount: calendarYearGridPageCount(
                                            minYear: _minYear,
                                            maxYear: _maxYear,
                                          ),
                                          itemBuilder: (context, index) {
                                            return _buildYearGrid(
                                              setModalState,
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: CircularProgressIndicator(),
                                        ))
                                : (_monthPageController != null
                                      ? PageView.builder(
                                          key: ValueKey(
                                            'month_$_pageControllerKey',
                                          ),
                                          controller: _monthPageController!,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          onPageChanged: (pageIndex) {
                                            final newYear =
                                                _minYear + pageIndex;
                                            setState(() {
                                              _displayedYear = newYear;
                                              _selectedYear = newYear;
                                            });
                                            setModalState(() {});
                                          },
                                          itemCount: _maxYear - _minYear + 1,
                                          itemBuilder: (context, index) {
                                            final int year = _minYear + index;
                                            return _buildMonthGrid(
                                              key: ValueKey(year),
                                              displayedYear: year,
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: CircularProgressIndicator(),
                                        )),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 14),
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.55),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMonthHeader(StateSetter setModalState) {
    final String yearText = _displayedYear.toString();
    return _buildPickerHeader(
      label: yearText,
      onLeft: _displayedYear > _minYear && _monthPageController != null
          ? () {
              _monthPageController!.previousPage(
                duration: kAnimDefault,
                curve: Curves.easeInOut,
              );
            }
          : null,
      onRight: _displayedYear < _maxYear && _monthPageController != null
          ? () {
              _monthPageController!.nextPage(
                duration: kAnimDefault,
                curve: Curves.easeInOut,
              );
            }
          : null,
      onCenterTap: () {
        setState(() {
          _isYearView = true;
          _displayedYear = _selectedYear;
          _yearBlockStart = calendarYearBlockStartForYear(
            minYear: _minYear,
            maxYear: _maxYear,
            year: _selectedYear,
          );
        });
        setModalState(() {});
      },
    );
  }

  Widget _buildYearHeader(StateSetter setModalState) {
    final String label = '$_yearBlockStart – ${_yearBlockStart + 11}';
    return _buildPickerHeader(
      label: label,
      onLeft: _yearBlockStart > _minYear && _yearPageController != null
          ? () {
              _yearPageController!.previousPage(
                duration: kAnimDefault,
                curve: Curves.easeInOut,
              );
            }
          : null,
      onRight: _yearBlockStart + 11 < _maxYear && _yearPageController != null
          ? () {
              _yearPageController!.nextPage(
                duration: kAnimDefault,
                curve: Curves.easeInOut,
              );
            }
          : null,
      onCenterTap: () {
        setState(() {
          _isYearView = false;
          _displayedYear = _selectedYear;
        });
        _syncMonthPageToSelectedYear();
        setModalState(() {});
      },
    );
  }

  Widget _buildPickerHeader({
    required String label,
    required VoidCallback? onLeft,
    required VoidCallback? onRight,
    required VoidCallback onCenterTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          GlassPickerIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onLeft,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: GlassPickerPillTrigger(label: label, onTap: onCenterTap),
              ),
            ),
          ),
          GlassPickerIconButton(
            icon: Icons.chevron_right_rounded,
            onPressed: onRight,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid({Key? key, int? displayedYear}) {
    final List<int> months = List<int>.generate(12, (index) => index + 1);
    final DateTime now = DateTime.now();
    return GridView.builder(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final int month = months[index];
        final int currentDisplayedYear = displayedYear ?? _selectedYear;
        final bool isCurrentMonth =
            month == now.month && currentDisplayedYear == now.year;
        final bool isFocusedMonth =
            month == widget.currentDate.month &&
            currentDisplayedYear == widget.currentDate.year;
        final String monthName = DateFormat(
          'MMM',
          widget.locale.languageCode,
        ).format(DateTime(currentDisplayedYear, month));
        return GlassPickerTile(
          label: monthName,
          isFocused: isFocusedMonth,
          isCurrent: isCurrentMonth,
          onTap: () {
            setState(() {
              _selectedMonth = month;
              _selectedYear = currentDisplayedYear;
            });
            _selectDate();
          },
        );
      },
    );
  }

  Widget _buildYearGrid(StateSetter setModalState) {
    final List<int> years = List<int>.generate(
      12,
      (index) => _yearBlockStart + index,
    );
    final DateTime now = DateTime.now();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final int year = years[index];
        final bool isCurrentYear = year == now.year;
        final bool isFocusedYear = year == widget.currentDate.year;
        final bool isValidYear = year >= _minYear && year <= _maxYear;

        return GlassPickerTile(
          label: year.toString(),
          isFocused: isFocusedYear && isValidYear,
          isCurrent: isCurrentYear && isValidYear,
          isEnabled: isValidYear,
          onTap: isValidYear
              ? () {
                  setState(() {
                    _displayedYear = year;
                    _selectedYear = year;
                    _isYearView = false;
                  });
                  _syncMonthPageToSelectedYear();
                  setModalState(() {});
                }
              : null,
        );
      },
    );
  }

  void _selectDate() {
    // Create a date with the selected year/month and the original day
    // This sets the focused day to the same day in the new month
    final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final validDay = _originalSelectedDay > lastDayOfMonth
        ? lastDayOfMonth
        : _originalSelectedDay;

    final focusedDate = DateTime(_selectedYear, _selectedMonth, validDay);

    // Only call onDateSelected if the month or year actually changed
    // This prevents unnecessary reloads when closing without changes
    final currentFocusedDay = widget.currentDate;
    final monthChanged =
        currentFocusedDay.year != focusedDate.year ||
        currentFocusedDay.month != focusedDate.month;

    if (monthChanged) {
      // Check if year has changed and load holidays for the new year
      final yearChanged = currentFocusedDay.year != focusedDate.year;
      if (yearChanged) {
        // Load holidays for the new year
        ref
            .read(schoolHolidaysProvider.notifier)
            .loadHolidaysForYear(focusedDate.year);
      }

      widget.onDateSelected(focusedDate);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String monthYearText = DateFormat(
      'MMMM yyyy',
      widget.locale.languageCode,
    ).format(widget.currentDate);
    return GlassPickerPillTrigger(
      label: monthYearText,
      onTap: _showDateSwitcher,
    );
  }
}
