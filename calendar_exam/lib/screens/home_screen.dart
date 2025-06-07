import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/event_model.dart';
import 'event_form_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userUid;
  const HomeScreen({super.key, required this.userUid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  List<EventModel> events = [];
  bool showOnlyMine = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);
    final result = showOnlyMine
        ? await DBHelper.getEventsByDate(dateString, widget.userUid)
        : await DBHelper.getAllEventsByDate(dateString);

    setState(() {
      events = result;
    });
  }

  void _goToAddEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(userUid: widget.userUid),
      ),
    );

    if (result == true) {
      loadEvents();
    }
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userUid: widget.userUid),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      loadEvents();
    }
  }

  void _editEvent(EventModel event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          userUid: widget.userUid,
          eventToEdit: event,
        ),
      ),
    );
    if (result == true) loadEvents();
  }

  void _deleteEvent(EventModel event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Потвърди изтриване'),
        content: const Text('Сигурни ли сте, че искате да изтриете събитието?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отказ')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Изтрий')),
        ],
      ),
    );

    if (confirmed == true) {
      await DBHelper.deleteEvent(event.id!);
      loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Събития за $formattedDate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _goToProfile,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 1,
              color: Colors.grey.shade300,
            ),
          ),
          SwitchListTile(
            title: Text(showOnlyMine ? 'Моите събития' : 'Всички събития'),
            value: showOnlyMine,
            onChanged: (value) {
              setState(() {
                showOnlyMine = value;
              });
              loadEvents();
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadEvents,
              child: events.isEmpty
                  ? const Center(child: Text('Няма събития за този ден'))
                  : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isMine = event.createdBy == widget.userUid;

                  final rawColor = event.color ?? '#2196f3'; // null към синьо
                  final eventColor = Color(int.parse(rawColor.replaceFirst('#', '0xff')));

                  return Row(
                    children: [
                      Container(
                        width: 6,
                        height: 70,
                        color: eventColor,
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(event.title),
                          subtitle: Text(event.description ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat.Hm().format(event.startTime)),
                              if (isMine) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editEvent(event),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEvent(event),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'calendar',
            child: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add',
            child: const Icon(Icons.add),
            onPressed: _goToAddEvent,
          ),
        ],
      ),
    );
  }
}