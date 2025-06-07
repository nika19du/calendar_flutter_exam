import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/event_model.dart';

class EventFormScreen extends StatefulWidget {
  final String userUid;
  final EventModel? eventToEdit;

  const EventFormScreen({
    super.key,
    required this.userUid,
    this.eventToEdit,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Color selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();

    if (widget.eventToEdit != null) {
      final event = widget.eventToEdit!;
      titleController.text = event.title;
      descriptionController.text = event.description ?? '';
      selectedDate = event.startTime;
      startTime = TimeOfDay.fromDateTime(event.startTime);
      endTime = TimeOfDay.fromDateTime(event.endTime);
      if (event.color != null) {
        selectedColor = Color(int.parse(event.color!.replaceFirst('#', '0xff')));
      }    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => endTime = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _saveEvent() async {
    final title = titleController.text.trim();

    if (title.isEmpty || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Моля, въведи заглавие и начално/крайно време.')),
      );
      return;
    }

    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Крайната дата/час не може да е преди началната.')),
      );
      return;
    }

    final event = EventModel(
      id: widget.eventToEdit?.id,
      title: title,
      description: descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      createdBy: widget.userUid,
      color: '#${selectedColor.value.toRadixString(16)}',
      createdAt: widget.eventToEdit?.createdAt ?? DateTime.now(),
    );

    if (widget.eventToEdit != null) {
      await DBHelper.updateEvent(event);
    } else {
      await DBHelper.insertEvent(event);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Редактирай събитие' : 'Създай събитие')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Заглавие'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Описание (по избор)'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Дата: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                TextButton(onPressed: _pickDate, child: const Text('Избери')),
              ],
            ),
            Row(
              children: [
                Text('Начало: ${startTime?.format(context) ?? '---'}'),
                TextButton(onPressed: _pickStartTime, child: const Text('Избери')),
              ],
            ),
            Row(
              children: [
                Text('Край: ${endTime?.format(context) ?? '---'}'),
                TextButton(onPressed: _pickEndTime, child: const Text('Избери')),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Цвят:'),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (_) => SimpleDialog(
                        title: const Text('Избери цвят'),
                        children: [
                          Wrap(
                            spacing: 10,
                            children: [
                              Colors.red,
                              Colors.green,
                              Colors.blue,
                              Colors.orange,
                              Colors.purple,
                              Colors.teal,
                              Colors.black,
                            ].map((color) {
                              return GestureDetector(
                                onTap: () => Navigator.pop(context, color),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedColor == color ? Colors.black : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                    if (color != null) setState(() => selectedColor = color);
                  },
                  child: CircleAvatar(
                    backgroundColor: selectedColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveEvent,
              child: Text(isEditing ? 'Запази промените' : 'Запази събитието'),
            )
          ],
        ),
      ),
    );
  }
}