class Message {
  final String fromStudent; // email from the student who sent the message
  final String content; // message content
  final DateTime timestamp; // time the message was sent
  final bool isRead; // whether the message has been read or not
  final bool ownMsg; // True if the message was sent by the current user

  const Message({
    required this.fromStudent,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.ownMsg,
  });

  // Convert a Message into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'fromStudent': fromStudent,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'own_msg': ownMsg,
    };
  }

  // Implement toString to make it easier to see information about
  // each message when using the print statement.
  @override
  String toString() {
    return 'Message{from: $fromStudent, content: $content, timestamp: $timestamp, isRead: $isRead, self: $ownMsg}';
  }
}