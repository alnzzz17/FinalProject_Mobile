class Timezone {
  final String name;
  final String displayName;

  Timezone({required this.name, required this.displayName});

  // Creates a Timezone from API response string
  factory Timezone.fromApi(String timezone) {
    if (timezone.isEmpty) {
      throw ArgumentError('Timezone string cannot be empty');
    }
    
    final parts = timezone.split('/');
    final displayName = parts.last.replaceAll('_', ' ');
    
    return Timezone(name: timezone, displayName: displayName);
  }

  @override
  String toString() => 'Timezone(name: $name, displayName: $displayName)';

  Timezone copyWith({
    String? name,
    String? displayName,
  }) {
    return Timezone(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
    );
  }
}