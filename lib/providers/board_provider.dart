import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/api_service.dart';
import '../models/column.dart';
import 'auth_provider.dart';
 
class BoardState {
  final List<dynamic> boards; 
  final List<KanbanColumn> columns;
  final bool isLoading;
  final String? activeBoardId;
 
  BoardState({
    this.boards = const [], 
    this.columns = const [],
    this.isLoading = false,
    this.activeBoardId,
  });
}
 
class BoardNotifier extends StateNotifier<BoardState> {
  final ApiService _api = ApiService();
  final String? _token;
 
  BoardNotifier(this._token) : super(BoardState()) {
    if (_token != null) initBoard();
  }
 
  Future<void> initBoard() async {
    state = BoardState(isLoading: true);
    try {
      final List boardsJson = await _api.get('/boards/', _token);
      
      if (boardsJson.isEmpty) {
        await _autoSetup();
      } else {
        state = BoardState(
          boards: boardsJson,
          isLoading: false,
          activeBoardId: null
        );
      }
    } catch (e) {
      state = BoardState(isLoading: false);
      print("Init Error: $e");
    }
  }
 
 Future<void> _autoSetup() async {
    try {
      final board = await _api.post('/boards/', {'name': 'My Tasks'}, _token);
      String boardId = board['id'];
 
      final defaultCols = ['To Do', 'In Progress', 'Done'];
      for (var colName in defaultCols) {
        await _api.post('/columns/', {'name': colName, 'board_id': boardId}, _token);
      }
      await initBoard();
    } catch (e) {
      print("AutoSetup Error: $e");
      state = BoardState(isLoading: false);
    }
  }

  Future<void> addBoard(String name) async {
    try {
      await _api.post('/boards/', {'name': name}, _token);
      await initBoard();
    } catch (e) {
      print("Add Board Error: $e");
    }
  }
 Future<void>updateBoard(String boardId,String newName)async{
  try{
    await _api.patch('/boards/$boardId',{'name': newName},_token);
    await initBoard();
  }catch(e){
    print("Rename Error:$e");
  }
 }
 
  Future<void> deleteBoard(String boardId) async {
    try {
      await _api.delete('/boards/$boardId', _token);
      await initBoard(); 
    } catch (e) {
      print("Delete Board Error: $e");
    }
  }
 
  Future<void> selectBoard(String boardId) async {
    state = BoardState(
      boards: state.boards,
      columns: state.columns,
      activeBoardId: boardId,
      isLoading: true
    );
    await refreshBoard(boardId);
  }

  Future<void> refreshBoard(String boardId) async {
    try {
      final colsJson = await _api.get('/columns/$boardId', _token);
      final cols = (colsJson as List).map((c) => KanbanColumn.fromJson(c)).toList();
      state = BoardState(
        boards: state.boards, 
        columns: cols,
        activeBoardId: boardId,
        isLoading: false
      );
    } catch (e) {
      state = BoardState(isLoading: false, boards: state.boards);
    }
  }

 Future<void> moveCard(String cardId, String targetColumnId, int newOrder) async {
  print("Moving card $cardId to column $targetColumnId at position $newOrder");
  
  try {
    await _api.patch('/cards/$cardId/reorder', {
      'new_column_id': targetColumnId,
      'new_order': newOrder,
    }, _token);
    
    if (state.activeBoardId != null) await refreshBoard(state.activeBoardId!);
  } catch (e) {
    print("Move Card Error: $e");
    if (state.activeBoardId != null) await refreshBoard(state.activeBoardId!);
  }
}


  Future<void> addCard(String title, String description, String colId,{DateTime? dueDate}) async {
    try {
      await _api.post('/cards/', {
        'title': title,
        'description': description,
        'column_id': colId,
        'order': 0,
        'due_date': dueDate?.toIso8601String(),
      }, _token);
      if (state.activeBoardId != null) await refreshBoard(state.activeBoardId!);
    } catch (e) {
      print("Add Card Error: $e");
    }
  }
 
Future<void> updateCard(String cardId, String title, String description, {DateTime? dueDate}) async {
  try {
    await _api.put('/cards/$cardId', {
      'title': title,
      'description': description,
      'due_date':dueDate?.toIso8601String(),
    }, _token);
    if (state.activeBoardId != null) await refreshBoard(state.activeBoardId!);
  } catch (e) {
    print("Update Error: $e");
  }
}


  Future<void> deleteCard(String cardId) async {
    try {
      await _api.delete('/cards/$cardId', _token);
      if (state.activeBoardId != null) await refreshBoard(state.activeBoardId!);
    } catch (e) {
      print("Delete Error: $e");
    }
  }
 
Future<void> addColumn(String name) async {
  if (state.activeBoardId == null) return;
  try {
    await _api.post('/columns/', {
      'name': name,
      'board_id': state.activeBoardId,
    }, _token);
    await refreshBoard(state.activeBoardId!);
  } catch (e) {
    print("Add Column Error: $e");
  }
}

Future<void> updateColumn(String columnId, String newName) async {
  try {
    await _api.put('/columns/$columnId', {
      'name': newName,
      'board_id': state.activeBoardId,
    }, _token);
    
    if (state.activeBoardId != null) await refreshBoard(state.activeBoardId!);
  } catch (e) {
    print("Update Column Error: $e");
  }
}

  Future<void> deleteColumn(String columnId) async {
    try {
      await _api.delete('/columns/$columnId', _token);
      if (state.activeBoardId != null) await refreshBoard(state.activeBoardId!);
    } catch (e) {
      print("Delete Column Error: $e"); 
    }
  }
}
 
final boardProvider = StateNotifierProvider<BoardNotifier, BoardState>((ref) {
  return BoardNotifier(ref.watch(authProvider).token);
});