class EventModel {
  final int? id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String createdBy; // uid
  final String? color;
  final DateTime createdAt;

  EventModel({
    this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdBy': createdBy,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      createdBy: map['createdBy'],
      color: map['color'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}