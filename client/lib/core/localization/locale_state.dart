part of 'locale_cubit.dart';

@freezed
abstract class LocaleState with _$LocaleState {
  const factory LocaleState({String? localeTag}) = _LocaleState;
}
