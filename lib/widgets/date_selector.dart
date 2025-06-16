import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../styles/colors.dart';

class DateSelector extends StatefulWidget {
  final ValueChanged<int>? onDateSelected;
  final int initialIndex;
  final int Function(DateTime)? getMissionCount;

  const DateSelector({
    Key? key,
    this.onDateSelected,
    this.initialIndex = 2,
    this.getMissionCount,
  }) : super(key: key);

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late List<DateTime> _dates;
  late int _selectedIndex;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('fr_FR');
    if (mounted) {
      setState(() {
        _generateDates();
        _isInitialized = true;
      });
    }
  }

  void _generateDates() {
    final today = DateTime.now();
    _dates = List.generate(7, (index) {
      return today.add(Duration(days: index - 2));
    });
  }

  double _calculateSize(BuildContext context, double percentage) {
    final smallerDimension = MediaQuery.of(context).size.shortestSide;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (isTablet) {
      return smallerDimension * percentage * 0.7;
    } else {
      return smallerDimension * percentage;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    final baseSize = _calculateSize(context, 0.04);
    final containerPadding = _calculateSize(context, 0.02);
    final containerMargin = _calculateSize(context, 0.01);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_dates.length, (index) {
          final date = _dates[index];
          final isSelected = _selectedIndex == index;
          final isToday = index == 2;
          final isTomorrow = index == 3;
          final isDayAfterTomorrow = index == 4;
          final isFutureDay = index > 4;

          String dayLabel = DateFormat('E', 'fr_FR').format(date);
          if (isToday) {
            dayLabel = 'Aujourd\'hui';
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              if (widget.onDateSelected != null) {
                widget.onDateSelected!(index);
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: containerMargin),
              padding: EdgeInsets.symmetric(
                  horizontal: containerPadding * 1.2,
                  vertical: containerPadding * 0.8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : (isToday ? Colors.blue[50] : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : (isToday ? AppColors.primaryColor : Colors.grey[300]!),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Text(
                        dayLabel,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isToday
                                  ? AppColors.primaryColor
                                  : Colors.grey[600]),
                          fontWeight: FontWeight.bold,
                          fontSize: isToday ? baseSize * 0.9 : baseSize,
                        ),
                      ),
                      Text(
                        DateFormat('d', 'fr_FR').format(date),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isToday
                                  ? AppColors.primaryColor
                                  : Colors.grey[600]),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: baseSize,
                        ),
                      ),
                    ],
                  ),
                  if (widget.getMissionCount != null &&
                      index > 2 &&
                      widget.getMissionCount!(date) > 0)
                    Positioned(
                      top: -containerPadding,
                      right: -containerPadding,
                      child: Text(
                        '${widget.getMissionCount!(date)}',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: baseSize * 0.8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
