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
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final h = startTime.hour.toString().padLeft(2, '0');
      final m = startTime.minute.toString().padLeft(2, '0');
      formattedDateTime = '${days[startTime.weekday - 1]}, ${startTime.day} ${months[startTime.month - 1]} ${startTime.year} | $h:$m';
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
