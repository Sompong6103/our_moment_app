class AgendaItem {
  final String? id;
  final String dateTime;
  final String title;
  final String description;
  final String location;
  final int? sortOrder;
  final DateTime? rawDateTime;

  const AgendaItem({
    this.id,
    required this.dateTime,
    required this.title,
    required this.description,
    required this.location,
    this.sortOrder,
    this.rawDateTime,
  });

  bool get isPast => rawDateTime != null && rawDateTime!.isBefore(DateTime.now());

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    final rawTime = json['dateTime'] ?? json['startTime'];
    final startTime = rawTime != null ? DateTime.tryParse(rawTime.toString()) : null;
    String formattedDateTime = '';
    if (startTime != null) {
      final local = startTime.toLocal();
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      formattedDateTime = '${days[local.weekday - 1]}, ${local.day} ${months[local.month - 1]} ${local.year} | $h:$m';
    }

    return AgendaItem(
      id: json['id'],
      dateTime: formattedDateTime,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      sortOrder: json['sortOrder'],
      rawDateTime: startTime,
    );
  }
}
