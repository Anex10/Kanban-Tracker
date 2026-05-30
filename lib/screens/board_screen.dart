import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/board_provider.dart';
import '../models/column.dart';
import '../models/card.dart';
import 'package:intl/intl.dart';

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("KANBAN BOARD",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.read(boardProvider.notifier).initBoard(),
          ),
        ],
      ),
      body: board.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: board.columns.length + 1,
              itemBuilder: (context, index) {
                if (index == board.columns.length) {
                  return _buildAddColumnButton(context, ref);
                }
                return KanbanColumnWidget(column: board.columns[index]);
              },
            ),
    );
  }


  Widget _buildAddColumnButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showAddColumnDialog(context, ref),
        icon: const Icon(Icons.add, color: Colors.white70),
        label: const Text("Add New Column", style: TextStyle(color: Colors.white70)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white10, style: BorderStyle.solid),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // ignore: deprecated_member_use
          backgroundColor: Colors.white.withOpacity(0.02),
        ),
      ),
    );
  }

  void _showAddColumnDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("New Column", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Column Name (e.g., Testing)",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ref.read(boardProvider.notifier).addColumn(nameCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}

class KanbanColumnWidget extends ConsumerWidget {
  final KanbanColumn column;
  const KanbanColumnWidget({super.key, required this.column});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<String>(
      onWillAccept: (data) => true,
      onAccept: (cardId) {
        ref.read(boardProvider.notifier).moveCard(
              cardId,
              column.id,
              column.cards.length, 
            );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blueAccent : Colors.white10,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        column.name.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Text("${column.cards.length}",
                            style: const TextStyle(color: Colors.white38)),
                        const SizedBox(width: 4),
                        _buildColumnMenu(context, ref),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: column.cards.length,
                  itemBuilder: (context, index) {
                    final card = column.cards[index];
                    return DragTarget<String>(
                      onWillAccept: (draggedCardId) => draggedCardId != card.id,
                      onAccept: (draggedCardId) {
                        ref.read(boardProvider.notifier).moveCard(
                              draggedCardId,
                              column.id,
                              index,
                            );
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Column(
                          children: [         
                            if (candidateData.isNotEmpty)
                              Container(
                                height: 4,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            KanbanCardWidget(card: card),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              _buildAddTaskButton(context, ref),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumnMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
      onSelected: (value) {
        if (value == 'rename') {
          _showRenameDialog(context, ref);
        } else if (value == 'delete') {
          ref.read(boardProvider.notifier).deleteColumn(column.id);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'rename', child: Text("Rename")),
        const PopupMenuItem(
          value: 'delete',
          child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: column.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Rename Column", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "New Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              ref.read(boardProvider.notifier).updateColumn(column.id, nameCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextButton.icon(
        onPressed: () => _showCardDialog(context, ref),
        icon: const Icon(Icons.add, color: Colors.white70),
        label: const Text("Add Task", style: TextStyle(color: Colors.white70)),
        style: TextButton.styleFrom(
            // ignore: deprecated_member_use
            backgroundColor: Colors.white.withOpacity(0.05),
            minimumSize: const Size(double.infinity, 45)),
      ),
    );
  }


  void _showCardDialog(BuildContext context, WidgetRef ref) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime? selectedDate; 
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder( 
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("New Task", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Title")),
            TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Description")),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
              title: Text(
                selectedDate == null ? "Set Due Date" : "Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setDialogState(() => selectedDate = picked); 
                }
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ref.read(boardProvider.notifier).addCard(
                titleCtrl.text,
                descCtrl.text,
                column.id,
                dueDate: selectedDate, 
              );
              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    ),
  );
}
}

class KanbanCardWidget extends ConsumerWidget {
  final KanbanCard card;
  const KanbanCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Draggable<String>(
      data: card.id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            boxShadow: [
              // ignore: deprecated_member_use
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)
            ],
          ),
          child: _cardLayout(isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _cardLayout()),
      child: _cardLayout(context: context, ref: ref),
    );
  }

  Widget _cardLayout(
      {bool isDragging = false, BuildContext? context, WidgetRef? ref}) {
    return Container(
      width: isDragging ? 280 : double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  card.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isDragging && context != null && ref != null)
                _buildCardMenu(context, ref),
            ],
          ),
          if (card.description != null && card.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              card.description!,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
          if (card.dueDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
              decoration:BoxDecoration(
                color: const Color.fromARGB(255, 255, 254, 253),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children:[
                const Icon(Icons.calendar_month_outlined,
                size:14,
                color:Colors.orangeAccent),
                const SizedBox(width: 6),
                Text(
                  DateFormat('yyyy-MM-dd').format(card.dueDate!),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 236, 9, 9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildCardMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white38, size: 18),
      onSelected: (value) {
        if (value == 'delete') {
          ref.read(boardProvider.notifier).deleteCard(card.id);
        } else if (value == 'edit') {
          _showEditDialog(context, ref);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text("Edit")),
        const PopupMenuItem(
          value: 'delete',
          child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

 void _showEditDialog(BuildContext context, WidgetRef ref) {
  final titleCtrl = TextEditingController(text: card.title);
  final descCtrl = TextEditingController(text: card.description ?? "");
  DateTime? selectedDate = card.dueDate;
 
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) { 
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Edit Task", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white)),
              TextField(controller: descCtrl, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  selectedDate == null
                    ? "No Due Date"
                    : "Due: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: selectedDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.redAccent),
                      onPressed: () => setDialogState(() => selectedDate = null),
                    )
                  : null,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                ref.read(boardProvider.notifier).updateCard(
                  card.id,
                  titleCtrl.text,
                  descCtrl.text,
                  dueDate: selectedDate, 
                );
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    ),
  );
}
}