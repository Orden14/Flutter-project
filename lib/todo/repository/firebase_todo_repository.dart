import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/todo.dart';
import 'abstract_todo_repository.dart';

final class FirebaseTodoRepository implements AbstractTodoRepository {
  final user = FirebaseAuth.instance.currentUser;
  late final DatabaseReference todosRef;

  FirebaseTodoRepository() {
    todosRef = FirebaseDatabase.instance.ref('todos/${user!.uid}');
  }

  @override
  Future<void> addOrEditTodo(Todo todo) async {
    await todosRef.child(todo.id).set(todo.toMap());
  }

  @override
  Future<void> deleteTodo(String id) async {
    await todosRef.child(id).remove();
  }

  @override
  Future<void> toggleDone(Todo todo) async {
    await todosRef.child(todo.id).update({'isDone': !todo.isDone});
  }

  @override
  Stream<List<Todo>> todos() {
    return todosRef.orderByChild('dueDate').onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      
      return data.entries
          .map((e) => Todo.fromMap(Map<String, dynamic>.from(e.value), e.key))
          .toList();
    });
  }
}
