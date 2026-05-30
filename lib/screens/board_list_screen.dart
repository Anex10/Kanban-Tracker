import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/board_provider.dart';
import '../providers/auth_provider.dart';
import 'board_screen.dart';
 
class BoardListScreen extends ConsumerWidget {
  const BoardListScreen({super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(boardProvider);
    // ignore: unused_local_variable
    final authState = ref.watch(authProvider);
 
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("MY WORKSPACE",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                _showProfileDialog(context, ref);
              } else if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text("View Profile")),
              const PopupMenuItem(
                value: 'logout',
                child: Text("Logout", style: TextStyle(color: Colors.redAccent))
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: boardState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: boardState.boards.length,
              itemBuilder: (context, index) {
                final board = boardState.boards[index];
                return _buildBoardListItem(context, ref, board);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showBoardDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBoardListItem(BuildContext context, WidgetRef ref, dynamic board) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          ref.read(boardProvider.notifier).selectBoard(board['id']);
          Navigator.push(context, MaterialPageRoute(builder: (c) => const BoardScreen()));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.dashboard_rounded, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  board['name'] ?? 'Untitled Board',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              _buildMenu(context, ref, board),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref, dynamic board) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white38),
      onSelected: (value) {
        if (value == 'rename') {
          _showBoardDialog(context, ref, id: board['id'], oldName: board['name']);
        } else if (value == 'delete') {
          ref.read(boardProvider.notifier).deleteBoard(board['id']);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'rename', child: Text("Rename")),
        const PopupMenuItem(
          value: 'delete',
          child: Text("Delete", style: TextStyle(color: Colors.redAccent))
        ),
      ],
    );
  }

  void _showBoardDialog(BuildContext context, WidgetRef ref, {String? id, String? oldName}) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(id == null ? "New Board" : "Rename Board",
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter board name",
            hintStyle: TextStyle(color: Colors.white38)
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (id == null) {
                ref.read(boardProvider.notifier).addBoard(controller.text);
              } else {
                ref.read(boardProvider.notifier).updateBoard(id, controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
 
void _showProfileDialog(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authProvider);
 
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("User Profile", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(height: 20),
          Text(
            "Email: ${authState.user?.email ?? 'Not Available'}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}
}