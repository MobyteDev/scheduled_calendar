import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../calendar_state/calendar_state.dart';
import '../utils/date_utils.dart';
import '../utils/enums.dart';
import '../utils/styles.dart';
import '../utils/typedefs.dart';

class DayView extends StatefulWidget {
  final DateTime day;
  final void Function(DateTime, Offset)? onPressed;
  final bool isCalendarMode;
  final DateBuilder? dayFooterBuilder;

  /// Is the day the calendar holiday
  final bool isDayOff;

  /// Is the day the performer work day
  final bool isPerformerWorkDay;

  final ScheduledCalendarDayStyle style;
  final CalendarInteraction interaction;
  final bool isHorizontalCalendar;
  final bool displayWeekdays;
  final double dayFooterPadding;
  final double weekdayPadding;
  const DayView(
    this.day, {
    super.key,
    required this.onPressed,
    this.isCalendarMode = false,
    this.isDayOff = false,
    this.isPerformerWorkDay = false,
    this.style = const ScheduledCalendarDayStyle(),
    required this.interaction,
    required this.dayFooterBuilder,
    required this.isHorizontalCalendar,
    required this.displayWeekdays,
    required this.dayFooterPadding,
    required this.weekdayPadding,
  });

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  TapUpDetails? tapUpDetails;

  @override
  Widget build(BuildContext context) {
    final locale = widget.style.weekdayLocale ?? Localizations.localeOf(context).toString();
    final state = context.read<CalendarState>();
    final selectedInSelectionMode =
        state.dateInSelectedList(widget.day) != null;
    final focused =
        state.focusedDate != null && state.focusedDate!.isSameDay(widget.day);
    final isToday = widget.day.isSameDay(DateTime.now());
    BoxDecoration? highlightedDayDecoration;
    BoxDecoration? horizontalHighlightedDayDecoration;
    TextStyle? textStyle;
    if (widget.isHorizontalCalendar) {
      highlightedDayDecoration = const BoxDecoration();
      if (focused) {
        horizontalHighlightedDayDecoration =
            widget.style.horizontalFocusedDayDecoration;
        textStyle = widget.style.focusedDayTextStyle;
      }
    } else {
      if (widget.interaction == CalendarInteraction.selection) {
        highlightedDayDecoration = selectedInSelectionMode
            ? widget.style.selectionModeActiveDecoration
            : widget.style.selectionModeInactiveDecoration;
        if (selectedInSelectionMode) {
          textStyle = widget.style.selectionModeActiveTextStyle;
        } else {
          textStyle = widget.style.selectionModeInactiveTextStyle ??
              (widget.isDayOff
                  ? widget.style.dayOffTextStyle
                  : widget.style.workDayTextStyle);
        }
      } else if (focused) {
        highlightedDayDecoration = widget.isPerformerWorkDay
            ? widget.style.performerWorkDayDecoration
            : widget.style.focusedDayDecoration;
        textStyle = widget.style.focusedDayTextStyle;
      } else if (isToday) {
        textStyle = widget.style.currentDayTextStyle ??
            (widget.isDayOff
                ? widget.style.dayOffTextStyle
                : widget.style.workDayTextStyle);
      }
    }
    var weekdayName = widget.style.weekdayCustomNames[widget.day.weekday] ??
        DateFormat('E', locale).format(widget.day);
    return GestureDetector(
      onTapUp: (details) {
        tapUpDetails = details;
      },
      onTap: () => widget.onPressed?.call(widget.day, tapUpDetails!.globalPosition),
      child: Container(
        padding: widget.isHorizontalCalendar
            ? EdgeInsets.only(top: widget.weekdayPadding)
            : null,
        decoration: widget.isHorizontalCalendar
            ? horizontalHighlightedDayDecoration
            : null,
        child: Column(
          children: [
            if (widget.displayWeekdays)
              Text(
                weekdayName,
                style: !widget.isHorizontalCalendar
                    ? widget.style.weekdayTextStyle
                    : focused
                        ? widget.style.horizontalFocusedWeekdayTextStyle
                        : widget.style.weekdayTextStyle,
              ),
            Container(
              padding: widget.style.padding,
              decoration: highlightedDayDecoration ??
                  (widget.isPerformerWorkDay
                      ? widget.style.performerWorkDayDecoration
                      : widget.style.defaultWorkDayDecoration),
              child: Center(
                child: Text(
                  widget.day.day.toString(),
                  style: textStyle ??
                      (widget.isDayOff
                          ? widget.style.dayOffTextStyle
                          : widget.style.workDayTextStyle),
                ),
              ),
            ),
            if (widget.dayFooterBuilder != null) ...[
              SizedBox(height: widget.dayFooterPadding),
              widget.dayFooterBuilder!(context, widget.day),
            ],
          ],
        ),
      ),
    );
  }
}
