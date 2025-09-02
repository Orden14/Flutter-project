final class Todo {
  String id;
  String title;
  String description;
  DateTime dueDate;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isDone,
  });

  factory Todo.fromMap(Map<dynamic, dynamic> data, String id) {
    return Todo(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: DateTime.parse(data['dueDate']),
      isDone: data['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone,
    };
  }
}
