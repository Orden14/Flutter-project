import '../model/todo.dart';

abstract class AbstractTodoRepository {
  Future<void> addOrEditTodo(Todo todo);
  Future<void> deleteTodo(String id);
  Future<void> toggleDone(Todo todo);
  Stream<List<Todo>> todos();
}