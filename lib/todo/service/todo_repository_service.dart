import 'package:todolist/todo/repository/abstract_todo_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:todolist/todo/repository/firebase_todo_repository.dart';
import 'package:todolist/todo/repository/mock_todo_repository.dart';

final class TodoRepositoryService {
  static AbstractTodoRepository grabRepository() {
    final env = dotenv.env['ENV'] ?? 'dev';
    
    return env == 'prod' ? FirebaseTodoRepository() : MockTodoRepository();
  }
}
