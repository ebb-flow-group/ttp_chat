K $enumDecode<K extends Enum, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  for (var entry in enumValues.entries) {
    if (entry.value == source) {
      return entry.key;
    }
  }

  if (unknownValue == null) {
    throw ArgumentError(
      '`$source` is not one of the supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return unknownValue;
}
