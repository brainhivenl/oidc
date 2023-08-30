import 'package:json_annotation/json_annotation.dart';

/// Converts a list of strings into a space-delimited string
String? joinSpaceDelimitedList(List<String> value) {
  if (value.isEmpty) {
    return null;
  }
  return value.join(' ');
}

/// Converts a space-delimited string into a list of strings
List<String> splitSpaceDelimitedString(String? value) {
  if (value == null || value.isEmpty) {
    return [];
  }
  return value.split(' ');
}

///
class UriJsonConverter extends JsonConverter<Uri, String> {
  /// Creates a UriJsonConverter
  const UriJsonConverter();

  @override
  Uri fromJson(String json) {
    return Uri.parse(json);
  }

  @override
  String toJson(Uri object) {
    return object.toString();
  }
}

///
class DateTimeEpochConverter extends JsonConverter<DateTime, int> {
  ///
  const DateTimeEpochConverter();

  @override
  DateTime fromJson(int json) {
    return DateTime.fromMillisecondsSinceEpoch(
      json,
      isUtc: true,
    );
  }

  @override
  int toJson(DateTime object) {
    return object.millisecondsSinceEpoch;
  }
}

///
class DurationSecondsConverter extends JsonConverter<Duration, int> {
  ///
  const DurationSecondsConverter();

  @override
  Duration fromJson(int json) {
    return Duration(seconds: json);
  }

  @override
  int toJson(Duration object) {
    return object.inSeconds;
  }
}
