import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/models/day_schedule.dart';

class OpeningHoursSection extends StatelessWidget {
  final String? openingHours;

  const OpeningHoursSection({super.key, this.openingHours});

  @override
  Widget build(BuildContext context) {
    if (openingHours == null || openingHours!.isEmpty) {
      return const SizedBox.shrink();
    }

    final isOpen = _isRestaurantOpenNow(openingHours!);
    final hours = _parseOpeningHours(openingHours!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isOpen
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOpen ? Icons.check_circle : Icons.cancel,
                color: isOpen ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isOpen ? 'Ouvert maintenant' : 'Fermé maintenant',
                style: TextStyle(
                  color: isOpen ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Horaires d\'ouverture',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...hours.map((day) => _buildDaySchedule(day)).toList(),
      ],
    );
  }

  Widget _buildDaySchedule(DaySchedule day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day.dayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
                day.timeSlots.isEmpty ? 'Fermé' : day.timeSlots.join(', ')),
          ),
        ],
      ),
    );
  }

  bool _isRestaurantOpenNow(String openingHours) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = TimeOfDay.fromDateTime(now);

    final schedules = _parseOpeningHours(openingHours);
    final todaySchedule = schedules.firstWhere(
      (schedule) => schedule.dayName == _getFrenchDayName(currentDay),
      orElse: () => DaySchedule('', []),
    );

    if (todaySchedule.timeSlots.isEmpty) return false;

    for (final slot in todaySchedule.timeSlots) {
      final times = slot.split('-');
      if (times.length != 2) continue;

      final startTime = _parseTime(times[0]);
      final endTime = _parseTime(times[1]);

      if (startTime == null || endTime == null) continue;

      if (_isTimeBetween(currentTime, startTime, endTime)) {
        return true;
      }
    }

    return false;
  }

  String _getFrenchDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
      default:
        return '';
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  bool _isTimeBetween(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final nowMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  List<DaySchedule> _parseOpeningHours(String openingHours) {
    final List<DaySchedule> schedules = [];
    final dayGroups = openingHours.split('; ');

    const dayNames = {
      'Mo': 'Lundi',
      'Tu': 'Mardi',
      'We': 'Mercredi',
      'Th': 'Jeudi',
      'Fr': 'Vendredi',
      'Sa': 'Samedi',
      'Su': 'Dimanche',
    };

    for (final group in dayGroups) {
      final parts = group.split(' ');
      if (parts.length < 2) continue;

      final dayRange = parts[0];
      final times = parts[1];

      if (dayRange.contains('-')) {
        final rangeParts = dayRange.split('-');
        if (rangeParts.length != 2) continue;

        final startDay = rangeParts[0];
        final endDay = rangeParts[1];

        final dayKeys = dayNames.keys.toList();
        final startIndex = dayKeys.indexOf(startDay);
        final endIndex = dayKeys.indexOf(endDay);

        if (startIndex != -1 && endIndex != -1) {
          for (int i = startIndex; i <= endIndex; i++) {
            final dayKey = dayKeys[i];
            schedules.add(DaySchedule(dayNames[dayKey]!, [times]));
          }
        }
      } else {
        schedules.add(DaySchedule(dayNames[dayRange]!, [times]));
      }
    }

    if (schedules.length < 7) {
      final existingDays = schedules.map((e) => e.dayName).toSet();
      for (final dayName in dayNames.values) {
        if (!existingDays.contains(dayName)) {
          schedules.add(DaySchedule(dayName, []));
        }
      }
    }

    schedules.sort((a, b) {
      final daysOrder = dayNames.values.toList();
      return daysOrder
          .indexOf(a.dayName)
          .compareTo(daysOrder.indexOf(b.dayName));
    });

    return schedules;
  }
}