class KanbanCard{
  final String id;
  final String title;
  final String? description;
  final String columnId;
  final int order;
  final DateTime? dueDate;

  const KanbanCard({
    required this.id,
    required this.title,
    required this.description,
    required this.columnId,
    required this.order,
    this.dueDate
  });

  factory KanbanCard.fromJson(Map<String,dynamic>json){
    return KanbanCard(id: json['id'] ?? '',
     title: json['title'] ?? '', 
     description:json['description'],
     columnId: json['column_id'] ?? '',
     order: json['order'] as int? ?? 0,
     dueDate: json['due_date']!= null? DateTime.parse(json['due_date']):null,
     );
  }
}