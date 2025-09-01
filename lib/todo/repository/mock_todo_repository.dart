import 'dart:async';
import '../model/todo.dart';
import 'abstract_todo_repository.dart';

class MockTodoRepository implements AbstractTodoRepository {
  final List<Todo> _todos = [];
  final _controller = StreamController<List<Todo>>.broadcast();

  MockTodoRepository() {
    _controller.add(_todos);
  }

  @override
  Future<void> addOrEditTodo(Todo todo) async {
    _todos.removeWhere((t) => t.id == todo.id);
    _todos.add(todo);
    _controller.add(List<Todo>.from(_todos));
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    _controller.add(List<Todo>.from(_todos));
  }

  @override
  Future<void> toggleDone(Todo todo) async {
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    
    if (idx != -1) {
      _todos[idx] = Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        dueDate: todo.dueDate,
        isDone: !todo.isDone,
      );
      _controller.add(List<Todo>.from(_todos));
    }
  }

  @override
  Stream<List<Todo>> todos() => _controller.stream;
}
