class AssetPickerItemDto {
  const AssetPickerItemDto({
    required this.id,
    required this.kind,
    required this.code,
    required this.name,
    required this.rank,
    required this.isUnlocked,
  });

  final String id;
  final String kind;
  final String code;
  final String name;
  final int rank;
  final bool isUnlocked;

  factory AssetPickerItemDto.fromJson(Map<String, dynamic> json) {
    final rankRaw = json['rank'];
    final rank = rankRaw is num ? rankRaw.toInt() : 999999;
    final isLockedRaw = json['is_locked'];
    final isUnlocked = switch (isLockedRaw) {
      bool isLocked => !isLocked,
      _ => json['is_unlocked'] == true,
    };

    return AssetPickerItemDto(
      id: (json['id'] as String?) ?? '',
      kind: (json['kind'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      rank: rank > 0 ? rank : 999999,
      isUnlocked: isUnlocked,
    );
  }
}
