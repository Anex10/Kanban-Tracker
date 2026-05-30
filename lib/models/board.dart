class Board {
  final String id;
  final String name;
  final List<BoardColumn> columns;
 
  Board({required this.id, required this.name, required this.columns});
 
  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      name: json['name'],
      columns: (json['columns'] as List)
          .map((c) => BoardColumn.fromJson(c))
          .toList(),
    );
  }
}
 
class BoardColumn {
  final String id;
  final String name;
  final List<CardModel> cards;
 
  BoardColumn({required this.id, required this.name, required this.cards});
 
  factory BoardColumn.fromJson(Map<String, dynamic> json) {
    return BoardColumn(
      id: json['id'],
      name: json['name'],
      cards: (json['cards'] as List)
          .map((c) => CardModel.fromJson(c))
          .toList(),
    );
  }
}
 
class CardModel {
  final String id;
  final String title;
  final String description;
  final int order;
 
  CardModel({required this.id, required this.title, required this.description,required this.order});
 
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      title: json['title'],
      order:json['order'] as int? ?? 0,
      description: json['description'] ?? "",
    );
  }
}