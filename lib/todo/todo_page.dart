import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference todosRef;

  @override
  void initState() {
    super.initState();
    todosRef = FirebaseDatabase.instance.ref('todos/${user!.uid}');
  }

  void _addOrEditTodo({Todo? todo}) async {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descController = TextEditingController(text: todo?.description ?? '');
    DateTime? dueDate = todo?.dueDate ?? DateTime.now();
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(todo == null ? 'Ajouter une tâche' : 'Modifier une tâche'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                TextButton(
                  child: Text(dueDate == null ? 'Choisir une date d\'échéance' : dueDate!.toLocal().toString().split(' ')[0]),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => dueDate = picked);
                  },
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(errorText!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Annuler'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text(todo == null ? 'Ajouter' : 'Enregistrer'),
                onPressed: () async {
                  if (titleController.text.isEmpty) {
                    setState(() => errorText = 'Un titre est requis');
                    return;
                  }
                  if (dueDate == null) {
                    setState(() => errorText = 'La date d\'échéance est requise');
                    return;
                  }
                  final newTodo = Todo(
                    id: todo?.id ?? todosRef.push().key!,
                    title: titleController.text,
                    description: descController.text,
                    dueDate: dueDate!,
                    isDone: todo?.isDone ?? false,
                  );
                  try {
                    await todosRef.child(newTodo.id).set(newTodo.toMap());
                    Navigator.pop(context);
                  } catch (e) {
                    setState(() => errorText = 'Échec de l\'enregistrement de la tâche : $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
            child: const Text('Supprimer'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              todosRef.child(id).remove();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _toggleDone(Todo todo) {
    todosRef.child(todo.id).update({'isDone': !todo.isDone});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Tâches'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'À faire'),
              Tab(text: 'Tâches terminées'),
            ],
          ),
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: todosRef.orderByChild('dueDate').onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('Aucune tâche disponible dans cet onglet.'));
            }
            final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final todos = data.entries
                .map((e) => Todo.fromMap(Map<String, dynamic>.from(e.value), e.key))
                .toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
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
          onPressed: () => _addOrEditTodo(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return const Center(child: Text('Aucune tâche pour le moment.'));
    }
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, i) {
        final todo = todos[i];
        return ListTile(
          title: Text(todo.title),
          subtitle: Text('${todo.description}\nDue: ${todo.dueDate.toLocal().toString().split(' ')[0]}'),
          isThreeLine: true,
          leading: Checkbox(
            value: todo.isDone,
            onChanged: (_) => _toggleDone(todo),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _addOrEditTodo(todo: todo)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTodo(todo.id)),
            ],
          ),
        );
      },
    );
  }
}
