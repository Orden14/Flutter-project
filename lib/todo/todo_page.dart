import 'model/todo.dart';
import 'package:flutter/material.dart';
import 'service/todo_dialog_service.dart';
import 'package:todolist/todo/repository/abstract_todo_repository.dart';
import 'package:todolist/todo/service/todo_repository_service.dart';

final class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

final class _TodoPageState extends State<TodoPage> {
  final AbstractTodoRepository _todoRepository = TodoRepositoryService.grabRepository();
  final TodoDialogService _todoDialogService = TodoDialogService();

  Future<void> _showTodoDialogAndSave({Todo? todo}) async {
    final newTodo = await _todoDialogService.showFormDialog(context: context, todo: todo);
    if (newTodo != null) {
      try {
        await _todoRepository.addOrEditTodo(newTodo);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de l'enregistrement de la tâche : $e")),
        );
      }
    }
  }

  void _deleteTodo(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _todoRepository.deleteTodo(id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes tâches'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'À faire'),
              Tab(text: 'Terminées'),
            ],
          ),
        ),
        body: StreamBuilder<List<Todo>>(
          stream: _todoRepository.todos(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune tâche disponible dans cet onglet.'));
            }

            final todos = snapshot.data!..sort((a, b) => a.dueDate.compareTo(b.dueDate));
            final toDoList = todos.where((t) => !t.isDone).toList();
            final doneList = todos.where((t) => t.isDone).toList();

            return TabBarView(
              children: [
                _buildTodoList(toDoList),
                _buildTodoList(doneList),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showTodoDialogAndSave(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return const Center(child: Text('Aucune tâche ici.'));
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, i) {
        final todo = todos[i];
        
        return ListTile(
          title: Text(todo.title),
          subtitle: Text('${todo.description}\nÉchéance : ${todo.dueDate.toLocal().toString().split(' ')[0]}'),
          isThreeLine: true,
          leading: Checkbox(
            value: todo.isDone,
            onChanged: (_) async => await _todoRepository.toggleDone(todo),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _showTodoDialogAndSave(todo: todo)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTodo(todo.id)),
            ],
          ),
        );
      },
    );
  }
}
