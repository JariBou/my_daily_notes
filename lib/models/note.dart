class NoteTables {
  static const String draftNotes = 'draftnotes';
  static const String sentNotes = 'sentnotes';
  static const String receivedNotes = 'receivednotes';

  static const List<String> fields = [draftNotes, sentNotes, receivedNotes];

  static const Map<String, String> tableName= {
    draftNotes: 'Draft Notes',
    sentNotes: 'Sent Notes',
    receivedNotes: 'Received Notes'
  };

}

class NoteFields {
  static const String id = '_id';
  static const String title = 'title';
  static const String description = 'description';
  static const String time = 'time';
  static const String author = 'author';

  static const List<String> values = [id, title, description, time, author];// ,author
}

class Note {
  final int? id;
  final String title;
  final String description;
  final DateTime time;
  final String author;

  const Note({
    this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.author,
  });

  Map<String, Object?> toJson() => {
    NoteFields.id: id,
    NoteFields.title: title,
    NoteFields.description: description,
    NoteFields.time: time.toIso8601String(),
    NoteFields.author: author,
  };

  /// Copies a note while changing given values
  Note copy({
    int? id,
    String? title,
    String? description,
    DateTime? time,
    String? author,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        time: time ?? this.time,
        author: author ?? this.author,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
    id: json[NoteFields.id] as int?,
    title: json[NoteFields.title] as String,
    description: json[NoteFields.description] as String,
    time: DateTime.parse(json[NoteFields.time] as String),
    author: json[NoteFields.author] as String,
  );

  /// Returns note with void id
  Note removeId() => Note(
    time: time,
    title: title,
    description: description,
    author: author,
  );

}