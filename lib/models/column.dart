import 'card.dart';
 
class KanbanColumn {
  final String id;
  final String name;
  final List<KanbanCard> cards;
 
  KanbanColumn({required this.id, required this.name, required this.cards});
 
  factory KanbanColumn.fromJson(Map<String, dynamic> json) {
    return KanbanColumn(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled',
      cards: json['cards'] != null
        ? (json['cards'] as List).map((card) => KanbanCard.fromJson(card)).toList()
        : [],
    );
  }
}
 