// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:realtime_client/realtime_client.dart';

typedef BindingCallback = void Function(dynamic payload, [dynamic ref]);

class Binding {
  String type;
  Map<String, String> filter;
  BindingCallback callback;
  String? id;

  Binding(
    this.type,
    this.filter,
    this.callback, [
    this.id,
  ]);

  Binding copyWith({
    String? type,
    Map<String, String>? filter,
    BindingCallback? callback,
    String? id,
  }) {
    return Binding(
      type ?? this.type,
      filter ?? this.filter,
      callback ?? this.callback,
      id ?? this.id,
    );
  }
}

enum PostgresChangeEvent {
  /// Listen to all insert, update, and delete events.
  all,

  /// Listen to insert events.
  insert,

  /// Listen to update events.
  update,

  /// Listen to delete events.
  delete,
}

extension PostgresChangeEventMethods on PostgresChangeEvent {
  String toRealtimeEvent() {
    if (this == PostgresChangeEvent.all) {
      return '*';
    } else {
      return name.toUpperCase();
    }
  }

  static PostgresChangeEvent fromString(String event) {
    switch (event) {
      case 'INSERT':
        return PostgresChangeEvent.insert;
      case 'UPDATE':
        return PostgresChangeEvent.update;
      case 'DELETE':
        return PostgresChangeEvent.delete;
    }
    throw ArgumentError(
        'Only "INSERT", "UPDATE", or "DELETE" can be can be passed to `fromString()` method.');
  }
}

class ChannelFilter {
  /// For [RealtimeListenTypes.postgresChanges] it's one of: `INSERT`, `UPDATE`, `DELETE`
  ///
  /// For [RealtimeListenTypes.presence] it's one of: `sync`, `join`, `leave`
  ///
  /// For [RealtimeListenTypes.broadcast] it can be any string
  final String? event;
  final String? schema;
  final String? table;

  /// For [RealtimeListenTypes.postgresChanges] it's of the format `column=filter.value` with `filter` being one of `eq, neq, lt, lte, gt, gte, in`
  ///
  /// Only one filter can be applied
  final String? filter;

  ChannelFilter({
    this.event,
    this.schema,
    this.table,
    this.filter,
  });

  Map<String, String> toMap() {
    return {
      if (event != null) 'event': event!,
      if (schema != null) 'schema': schema!,
      if (table != null) 'table': table!,
      if (filter != null) 'filter': filter!,
    };
  }
}

enum ChannelResponse { ok, timedOut, rateLimited, error }

enum RealtimeListenTypes { postgresChanges, broadcast, presence }

enum PresenceEvent { sync, join, leave }

extension PresenceEventExtended on PresenceEvent {
  static PresenceEvent fromString(String val) {
    for (final event in PresenceEvent.values) {
      if (event.name == val) {
        return event;
      }
    }
    throw ArgumentError(
        'Only "sync", "join", or "leave" can be can be passed to `fromString()` method.');
  }
}

enum RealtimeSubscribeStatus { subscribed, channelError, closed, timedOut }

extension ToType on RealtimeListenTypes {
  String toType() {
    if (this == RealtimeListenTypes.postgresChanges) {
      return 'postgres_changes';
    } else {
      return name;
    }
  }
}

class RealtimeChannelConfig {
  /// [ack] option instructs server to acknowlege that broadcast message was received
  final bool ack;

  /// [self] option enables client to receive message it broadcasted
  final bool self;

  /// [key] option is used to track presence payload across clients
  final String key;

  const RealtimeChannelConfig({
    this.ack = false,
    this.self = false,
    this.key = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'config': {
        'broadcast': {
          'ack': ack,
          'self': self,
        },
        'presence': {
          'key': key,
        },
      }
    };
  }
}

/// Data class that contains the Postgres change event payload.
class PostgresChangePayload {
  final String schema;
  final String table;
  final DateTime commitTimestamp;
  final PostgresChangeEvent eventType;
  final Map<String, dynamic> newRecord;
  final Map<String, dynamic> oldRecord;
  final dynamic errors;
  PostgresChangePayload({
    required this.schema,
    required this.table,
    required this.commitTimestamp,
    required this.eventType,
    required this.newRecord,
    required this.oldRecord,
    required this.errors,
  });

  /// Creates a PostgresChangePayload instance from the enriched postgres change payload
  PostgresChangePayload.fromPayload(Map<String, dynamic> payload)
      : schema = payload['schema'],
        table = payload['table'],
        commitTimestamp =
            DateTime.parse(payload['commit_timestamp'] ?? '19700101'),
        eventType = PostgresChangeEventMethods.fromString(payload['eventType']),
        newRecord = Map<String, dynamic>.from(payload['new']),
        oldRecord = Map<String, dynamic>.from(payload['old']),
        errors = payload['errors'];

  @override
  String toString() {
    return 'PostgresChangePayload(schema: $schema, table: $table, commitTimestamp: $commitTimestamp, eventType: $eventType, newRow: $newRecord, oldRow: $oldRecord, errors: $errors)';
  }

  @override
  bool operator ==(covariant PostgresChangePayload other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.schema == schema &&
        other.table == table &&
        other.commitTimestamp == commitTimestamp &&
        other.eventType == eventType &&
        mapEquals(other.newRecord, newRecord) &&
        mapEquals(other.oldRecord, oldRecord) &&
        other.errors == errors;
  }

  @override
  int get hashCode {
    return schema.hashCode ^
        table.hashCode ^
        commitTimestamp.hashCode ^
        eventType.hashCode ^
        newRecord.hashCode ^
        oldRecord.hashCode ^
        errors.hashCode;
  }
}

/// Specifies the type of filter to be applied on realtime Postgres Change listener.
enum PostgresChangeFilterType {
  /// Listens to changes where a column's value in a table equals a client-specified value.
  eq,

  /// Listens to changes where a column's value in a table does not equal a value specified.
  neq,

  /// Listen to changes where a column's value in a table is less than a value specified.
  lt,

  /// Listens to changes where a column's value in a table is less than or equal to a value specified.
  lte,

  /// Listens to changes where a column's value in a table is greater than a value specified.
  gt,

  /// Listens to changes where a column's value in a table is greater than or equal to a value specified.
  gte,

  /// Listen to changes when a column's value in a table equals any of the values specified.
  inFilter;
}

/// {@template postgres_change_filter}
/// Creates a filter for realtime postgres change listener.
/// {@endtemplate}
class PostgresChangeFilter {
  /// The type of the filter to set.
  final PostgresChangeFilterType type;

  /// The column to set the filter on.
  final String column;

  /// The value to perform the filter on.
  final dynamic value;

  /// {@macro postgres_change_filter}
  PostgresChangeFilter({
    required this.type,
    required this.column,
    required this.value,
  });

  @override
  String toString() {
    if (type == PostgresChangeFilterType.inFilter) {
      if (value is List<String>) {
        return '$column=in.(${value.map((s) => '"$s"').join(',')})';
      } else {
        return '$column=in.(${value.map((s) => '"$s"').join(',')})';
      }
    }
    return '$column=${type.name}.$value';
  }
}

/// Object for the presence callback payload for when the event is [PresenceEvent.sync].
///
/// For [PresenceEvent.join] event, [PresenceJoinPayload] will be returned, and
/// for [PresenceEvent.leave] event, [PresenceLeavePayload] will be returned.
class PresencePayload {
  final PresenceEvent event;

  PresencePayload({
    required this.event,
  });

  PresencePayload.fromJson(Map<String, dynamic> json)
      : event = PresenceEventExtended.fromString(json['event']);
}

/// Object for the presence callback payload for when the event is `join`.
class PresenceJoinPayload extends PresencePayload {
  final String key;
  final List<Presence> newPresences;
  final List<Presence> currentPresences;

  PresenceJoinPayload({
    required super.event,
    required this.key,
    required this.currentPresences,
    required this.newPresences,
  });

  factory PresenceJoinPayload.fromJson(Map<String, dynamic> json) {
    return PresenceJoinPayload(
      event: PresenceEventExtended.fromString(json['event']),
      key: json['key'] as String,
      newPresences: json['newPresences'] as List<Presence>,
      currentPresences: json['currentPresences'] as List<Presence>,
    );
  }
}

/// Object for the presence callback payload for when the event is `leave`.
class PresenceLeavePayload extends PresencePayload {
  final String key;
  final List<Presence> leftPresences;
  final List<Presence> currentPresences;

  PresenceLeavePayload({
    required super.event,
    required this.key,
    required this.currentPresences,
    required this.leftPresences,
  });

  factory PresenceLeavePayload.fromJson(Map<String, dynamic> json) {
    return PresenceLeavePayload(
      event: PresenceEventExtended.fromString(json['event']),
      key: json['key'] as String,
      leftPresences: json['leftPresences'] as List<Presence>,
      currentPresences: json['currentPresences'] as List<Presence>,
    );
  }
}
