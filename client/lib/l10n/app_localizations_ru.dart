// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Asset Tuner';

  @override
  String get homeTitle => 'Главная';

  @override
  String get designSystemPreview => 'Дизайн-система';

  @override
  String get signInTitle => 'Вход';

  @override
  String get signInBody => 'Отслеживайте активы на всех устройствах.';

  @override
  String get signUpTitle => 'Создать аккаунт';

  @override
  String get signUpBody =>
      'Присоединяйтесь к Asset Tuner для синхронизации портфеля.';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordHint => 'Минимум 6 символов';

  @override
  String get confirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get confirmPasswordHint => 'Повторите пароль';

  @override
  String get otpTitle => 'Подтвердите почту';

  @override
  String otpBodyWithEmail(String email) {
    return 'Введите 6-значный код, отправленный на $email.';
  }

  @override
  String get otpCodeLabel => 'Код подтверждения';

  @override
  String get otpCodeHint => '123456';

  @override
  String get signInPrimary => 'Войти';

  @override
  String get signUpPrimary => 'Создать аккаунт';

  @override
  String get sendOtp => 'Отправить код';

  @override
  String get verifyOtp => 'Подтвердить';

  @override
  String get resendOtp => 'Отправить снова';

  @override
  String get changeEmail => 'Изменить почту';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get signInWith => 'Или продолжить с';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get switchToSignUp => 'Нет аккаунта? Создать';

  @override
  String get switchToSignIn => 'Уже есть аккаунт? Войти';

  @override
  String get validationInvalidEmail => 'Введите корректный email.';

  @override
  String get validationPasswordRule => 'Минимум 6 символов, буквы и цифры.';

  @override
  String get validationPasswordMismatch => 'Пароли не совпадают.';

  @override
  String get validationOtpLength => 'Введите 6-значный код.';

  @override
  String get bannerSignInError => 'Не удалось войти.';

  @override
  String get bannerSignUpError => 'Не удалось создать аккаунт.';

  @override
  String get bannerOtpError => 'Не удалось подтвердить код.';

  @override
  String get bannerOtpSuccessTitle => 'Проверьте почту';

  @override
  String bannerOtpSuccessBodyWithEmail(String email) {
    return 'Мы отправили код подтверждения на $email.';
  }

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте снова.';

  @override
  String get errorNetwork => 'Нет сети. Попробуйте снова.';

  @override
  String get errorUnauthorized => 'Сессия истекла. Войдите снова.';

  @override
  String get errorConflict => 'Этот email уже используется.';

  @override
  String get errorRateLimited => 'Слишком много попыток. Попробуйте позже.';

  @override
  String get splashRestoring => 'Восстанавливаем сессию...';

  @override
  String get splashPreparingProfile => 'Готовим профиль...';

  @override
  String get splashErrorTitle => 'Что-то пошло не так.';

  @override
  String get splashRetry => 'Попробовать снова';

  @override
  String get onboardingBaseCurrencyTitle => 'Выберите базовую валюту';

  @override
  String get onboardingBaseCurrencyBody => 'Итоги будут в этой валюте.';

  @override
  String get onboardingSearchHint => 'Поиск валюты';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboardingUseUsd => 'Пока использовать USD';

  @override
  String get onboardingLoadError => 'Не удалось загрузить валюты.';

  @override
  String get onboardingSelectCurrency => 'Выберите валюту, чтобы продолжить.';

  @override
  String get onboardingUpgradeRequired =>
      'Нужна подписка для выбора этой валюты.';

  @override
  String get overviewTitle => 'Обзор';

  @override
  String get overviewTotalLabel => 'Итого';

  @override
  String get notAvailable => 'Н/Д';

  @override
  String get overviewEmptyBody => 'Данные появятся после добавления счетов.';

  @override
  String get paywallTitle => 'Подписка';

  @override
  String get paywallHeader => 'Откройте все валюты';

  @override
  String get paywallBody => 'Обновитесь, чтобы выбрать любую базовую валюту.';

  @override
  String get paywallDismiss => 'Позже';
}
