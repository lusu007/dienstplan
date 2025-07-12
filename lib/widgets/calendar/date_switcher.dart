import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSwitcher extends StatefulWidget {
  final DateTime currentDate;
  final Function(DateTime) onDateSelected;
  final Locale locale;

  const DateSwitcher({
    super.key,
    required this.currentDate,
    required this.onDateSelected,
    required this.locale,
  });

  @override
  State<DateSwitcher> createState() => _DateSwitcherState();
}

class _DateSwitcherState extends State<DateSwitcher>
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _selectedYear = widget.currentDate.year;
    _selectedMonth = widget.currentDate.month;
    _displayedYear = _selectedYear;
    _yearBlockStart = _selectedYear - (_selectedYear % 12);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _monthPageController?.dispose();
    _yearPageController?.dispose();
    super.dispose();
  }

  int _calculateYearBlockStart(int year) {
    // Ensure year block starts at 2018 or later
    final baseBlockStart = year - (year % 12);
    return baseBlockStart < 2018 ? 2018 : baseBlockStart;
  }

  void _showDateSwitcher() {
    // Reset to current year when opening the modal, but respect year limits
    final currentYear = widget.currentDate.year;
    final clampedYear = currentYear.clamp(2018, 2100);

    setState(() {
      _selectedYear = clampedYear; // Initialize selected year
      _displayedYear = clampedYear;
      _yearBlockStart = _calculateYearBlockStart(clampedYear);
      _isYearView = false;
    });

    // Initialize page controllers to correct positions
    final monthPageIndex = clampedYear - 2018;
    final yearPageIndex = ((clampedYear - 2018) / 12).floor();

    // Initialize page controllers
    _monthPageController?.dispose();
    _yearPageController?.dispose();
    _monthPageController = PageController(initialPage: monthPageIndex);
    _yearPageController = PageController(initialPage: yearPageIndex);
    _pageControllerKey++; // Force rebuild of PageView

    _animationController.forward();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
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
    });
  }

  Widget _buildDateSwitcherModal(StateSetter setModalState) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildDragHandle(),
                  Builder(
                    builder: (context) {
                      return _isYearView
                          ? _buildYearHeader(setModalState)
                          : _buildMonthHeader(setModalState);
                    },
                  ),
                  Expanded(
                    child: _isYearView
                        ? (_yearPageController != null
                            ? PageView.builder(
                                key: ValueKey('year_$_pageControllerKey'),
                                controller: _yearPageController!,
                                physics: const ClampingScrollPhysics(),
                                onPageChanged: (pageIndex) {
                                  setState(() {
                                    _yearBlockStart = _calculateYearBlockStart(
                                        2018 + (pageIndex * 12));
                                  });
                                  setModalState(() {});
                                },
                                itemCount: ((2100 - 2018) / 12).ceil() + 1,
                                itemBuilder: (context, index) {
                                  return _buildYearGrid(setModalState);
                                },
                              )
                            : const Center(child: CircularProgressIndicator()))
                        : (_monthPageController != null
                            ? PageView.builder(
                                key: ValueKey('month_$_pageControllerKey'),
                                controller: _monthPageController!,
                                physics: const ClampingScrollPhysics(),
                                onPageChanged: (pageIndex) {
                                  final newYear = 2018 + pageIndex;
                                  setState(() {
                                    _displayedYear = newYear;
                                    _selectedYear =
                                        newYear; // Keep selected year in sync
                                  });
                                  setModalState(() {});
                                },
                                itemCount: 2100 - 2018 + 1,
                                itemBuilder: (context, index) {
                                  final year = 2018 + index;
                                  return _buildMonthGrid(
                                      key: ValueKey(year),
                                      displayedYear: _selectedYear);
                                },
                              )
                            : const Center(child: CircularProgressIndicator())),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMonthHeader(StateSetter setModalState) {
    final yearText = _displayedYear.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _displayedYear > 2018 && _monthPageController != null
                ? () {
                    _monthPageController!.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isYearView = true;
                    // Preserve selected year when switching to year view
                    _displayedYear = _selectedYear;
                    _yearBlockStart = _calculateYearBlockStart(_selectedYear);
                  });
                  setModalState(() {});
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    yearText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _displayedYear < 2100 && _monthPageController != null
                ? () {
                    _monthPageController!.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildYearHeader(StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _yearBlockStart > 2018 && _yearPageController != null
                ? () {
                    _yearPageController!.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isYearView = false;
                    // Preserve selected year when switching to month view
                    _displayedYear = _selectedYear;
                  });
                  setModalState(() {});
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_yearBlockStart – ${_yearBlockStart + 11}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                _yearBlockStart + 11 < 2100 && _yearPageController != null
                    ? () {
                        _yearPageController!.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid({Key? key, int? displayedYear}) {
    final months = List.generate(12, (index) => index + 1);
    final now = DateTime.now();
    return GridView.builder(
      key: key,
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = months[index];
        final currentDisplayedYear = displayedYear ??
            _selectedYear; // Use selected year instead of displayed year
        final isCurrentMonth =
            month == now.month && currentDisplayedYear == now.year;
        final isFocusedMonth = month == widget.currentDate.month &&
            currentDisplayedYear == widget.currentDate.year;
        final monthName = DateFormat('MMM', widget.locale.languageCode)
            .format(DateTime(2024, month));
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMonth = month;
              _selectedYear = currentDisplayedYear; // Use the displayed year
            });
            _selectDate();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isFocusedMonth
                  ? Theme.of(context).colorScheme.primary
                  : (isCurrentMonth
                      ? Theme.of(context).colorScheme.primary.withAlpha(128)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                monthName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: (isFocusedMonth || isCurrentMonth)
                          ? Colors.white
                          : null,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearGrid(StateSetter setModalState) {
    final years = List.generate(12, (index) => _yearBlockStart + index);
    final now = DateTime.now();
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final year = years[index];
        final isCurrentYear = year == now.year;
        final isFocusedYear = year == widget.currentDate.year;
        final isValidYear = year >= 2018 && year <= 2100;

        return GestureDetector(
          onTap: isValidYear
              ? () {
                  setState(() {
                    _displayedYear = year;
                    _selectedYear =
                        year; // Set selected year when year is chosen
                    _isYearView = false;
                  });
                  setModalState(() {});
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: isValidYear
                  ? (isFocusedYear
                      ? Theme.of(context).colorScheme.primary
                      : (isCurrentYear
                          ? Theme.of(context).colorScheme.primary.withAlpha(128)
                          : Colors.transparent))
                  : Colors.grey.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                year.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isValidYear
                          ? ((isFocusedYear || isCurrentYear)
                              ? Colors.white
                              : null)
                          : Colors.grey,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectDate() {
    final selectedDate = DateTime(
      _selectedYear,
      _selectedMonth,
      widget.currentDate.day,
    );
    widget.onDateSelected(selectedDate);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final monthText = DateFormat('MMMM', widget.locale.languageCode)
        .format(widget.currentDate);
    return GestureDetector(
      onTap: _showDateSwitcher,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              monthText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
