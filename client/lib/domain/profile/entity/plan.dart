enum Plan {
  free('free'),
  pro('pro');

  const Plan(this.code);

  final String code;

  static Plan? tryFromCode(String? code) {
    final normalized = code?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    for (final plan in Plan.values) {
      if (plan.code == normalized) {
        return plan;
      }
    }
    return null;
  }

  static Plan fromCode(String? code) => tryFromCode(code) ?? Plan.free;

  bool get isPro => this == Plan.pro;
}
