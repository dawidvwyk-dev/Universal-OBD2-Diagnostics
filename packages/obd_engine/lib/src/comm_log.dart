/// In-memory communication log (ring buffer) that the user can export.
library;

enum LogDirection { tx, rx, info, error }

class LogEntry {
  LogEntry(this.time, this.direction, this.text);
  final DateTime time;
  final LogDirection direction;
  final String text;

  @override
  String toString() {
    final tag = switch (direction) {
      LogDirection.tx => '>>',
      LogDirection.rx => '<<',
      LogDirection.info => '--',
      LogDirection.error => '!!',
    };
    return '${time.toIso8601String()} $tag ${text.replaceAll('\r', r'\r')}';
  }
}

class CommLog {
  CommLog({this.capacity = 5000});
  final int capacity;
  final List<LogEntry> _entries = [];
  final List<void Function(LogEntry)> _listeners = [];

  List<LogEntry> get entries => List.unmodifiable(_entries);

  void add(LogDirection d, String text) {
    final e = LogEntry(DateTime.now(), d, text);
    _entries.add(e);
    if (_entries.length > capacity) _entries.removeAt(0);
    for (final l in _listeners) {
      l(e);
    }
  }

  void listen(void Function(LogEntry) l) => _listeners.add(l);

  String export() => _entries.join('\n');
}
