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
  String get signInBody => 'Войдите, чтобы сохранить подписку и портфель на всех устройствах.';

  @override
  String get signUpTitle => 'Создать аккаунт';

  @override
  String get signUpBody =>
      'Создайте аккаунт, чтобы подписка и портфель синхронизировались между устройствами.';

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
  String get otpResendSuccess => 'Код отправлен';

  @override
  String otpResendCooldown(int seconds) {
    return 'Повторно через $seconds с';
  }

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
  String get authEmailFallback => 'Или создайте аккаунт по email';

  @override
  String get switchToSignUp => 'Нет аккаунта? Создать';

  @override
  String get switchToSignIn => 'Уже есть аккаунт? Войти';

  @override
  String get signUpLegalPrefix => 'Создавая аккаунт, вы соглашаетесь с';

  @override
  String get signUpLegalTerms => 'Условиями';

  @override
  String get signUpLegalPrivacy => 'Политикой конфиденциальности';

  @override
  String get validationInvalidEmail => 'Введите корректный email.';

  @override
  String get validationPasswordRule => 'Используйте минимум 6 символов, буквы и цифры.';

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
  String get errorForbidden => 'Недостаточно прав для выполнения действия.';

  @override
  String get errorNotFound => 'Не удалось найти запрошенные данные.';

  @override
  String get errorValidation => 'Проверьте введённые данные и попробуйте снова.';

  @override
  String get errorConflict => 'Этот email уже используется.';

  @override
  String get errorRateLimited => 'Слишком много попыток. Попробуйте позже.';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get splashRestoring => 'Восстанавливаем сессию...';

  @override
  String get genericErrorTitle => 'Что-то пошло не так.';

  @override
  String get retryAction => 'Попробовать снова';

  @override
  String get onboardingBaseCurrencyTitle => 'Выберите базовую валюту';

  @override
  String get onboardingBaseCurrencyBody => 'Все итоги будут пересчитаны в эту валюту.';

  @override
  String get baseCurrencyConversionCaption => 'В эту валюту конвертируются ваши активы.';

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
  String get onboardingUpgradeRequired => 'Для выбора этой валюты нужен Pro-план.';

  @override
  String get onboardingCarouselTitle1 => 'Весь капитал в одной валюте';

  @override
  String get onboardingCarouselBody1 =>
      'Отслеживайте банковские счета, наличные и криптокошельки, чтобы всегда видеть общий итог в базовой валюте.';

  @override
  String get onboardingCarouselTitle2 => 'Повторите реальную структуру активов';

  @override
  String get onboardingCarouselBody2 =>
      'Создавайте аккаунты: банк, кошелёк, биржа, наличные или другое. Внутри аккаунта добавляйте отдельные позиции для BTC, ETH, USDT, EUR — как в реальной жизни.';

  @override
  String get onboardingCarouselTitle3 => 'Обновляйте балансы за секунды';

  @override
  String get onboardingCarouselBody3 =>
      'Быстро обновляйте баланс. Мы показываем, что изменилось с прошлого раза, и пересчитываем итоги по регулярно обновляемым курсам.';

  @override
  String get onboardingCarouselBody3Footnote =>
      'Далее: войдите, чтобы синхронизировать данные между устройствами.';

  @override
  String get onboardingCarouselQuickUpdatesCaption => 'Быстрые обновления баланса';

  @override
  String get onboardingCarouselSignInCta => 'У меня уже есть аккаунт';

  @override
  String get onboardingCarouselNext => 'Продолжить';

  @override
  String get onboardingCarouselGetStarted => 'Начать';

  @override
  String get onboardingCarouselSkip => 'Пропустить';

  @override
  String get onboardingCarouselBack => 'Назад';

  @override
  String get onboardingCarouselChip1First => 'Один итог';

  @override
  String get onboardingCarouselChip1Second => 'Быстро';

  @override
  String get onboardingCarouselChip2First => 'Любая валюта';

  @override
  String get onboardingCarouselChip2Second => 'Точные курсы';

  @override
  String get onboardingCarouselChip3First => 'История изменений';

  @override
  String get onboardingCarouselChip3Second => 'Простой учёт';

  @override
  String get overviewTitle => 'Обзор';

  @override
  String get mainTitle => 'Главная';

  @override
  String get mainAddAccount => 'Добавить аккаунт';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsBreakdownTitle => 'Структура';

  @override
  String get analyticsBreakdownCaption =>
      'Доли считаются в базовой валюте по последним доступным курсам.';

  @override
  String get analyticsUpdatesTitle => 'Обновления баланса';

  @override
  String get analyticsUpdatesCaption =>
      'Отслеживайте динамику общего баланса по последним обновлениям. Ниже показано изменение в каждой записи.';

  @override
  String get analyticsEmptyTitle => 'Пока нет аналитики';

  @override
  String get analyticsEmptyBody =>
      'Добавьте аккаунты и балансы, чтобы увидеть структуру и обновления.';

  @override
  String get actionsTitle => 'Действия';

  @override
  String get overviewTotalLabel => 'Итого';

  @override
  String get notAvailable => 'Н/Д';

  @override
  String get unpriced => 'Без курса';

  @override
  String get overviewEmptyBody => 'Данные появятся после добавления аккаунтов.';

  @override
  String get overviewEmptyNoAccountsTitle => 'Создайте первый аккаунт';

  @override
  String get overviewEmptyNoAccountsBody =>
      'Добавьте аккаунт, чтобы начать отслеживать активы и итоги.';

  @override
  String get overviewEmptyNoAccountsCta => 'Создать аккаунт';

  @override
  String get overviewEmptyNoAssetsTitle => 'Добавьте первый актив';

  @override
  String get overviewEmptyNoAssetsBody => 'Добавьте валюты или токены в один из аккаунтов.';

  @override
  String get overviewEmptyNoAssetsCta => 'Добавить актив';

  @override
  String get overviewEmptyNoBalancesTitle => 'Добавьте первый баланс';

  @override
  String get overviewEmptyNoBalancesBody => 'Добавьте баланс или изменение, чтобы увидеть итоги.';

  @override
  String get overviewEmptyNoBalancesCta => 'Добавить баланс';

  @override
  String get overviewPricedTotalLabel => 'Итого с курсами';

  @override
  String get overviewMissingRatesTitle => 'Некоторые активы сейчас нельзя оценить.';

  @override
  String get overviewMissingRatesBody =>
      'Активы без курса не учитываются в итогах, пока курсы не обновятся.';

  @override
  String get overviewUnpricedHoldingsTitle => 'Активы без курса';

  @override
  String get overviewPartialHint => 'Частично';

  @override
  String get offlineTitle => 'Офлайн';

  @override
  String offlineShowingLastSaved(String time) {
    return 'Показаны последние сохранённые итоги от $time.';
  }

  @override
  String get pullToRefreshHint => 'Потяните, чтобы обновить';

  @override
  String overviewRatesUpdatedAt(String time) {
    return 'Курсы обновлены: $time';
  }

  @override
  String get overviewRatesUnavailable => 'Курсы недоступны';

  @override
  String get accountsTitle => 'Аккаунты';

  @override
  String get accountsAddAccount => 'Добавить аккаунт';

  @override
  String get accountsActiveSection => 'Аккаунты';

  @override
  String get accountsArchivedSection => 'Архив';

  @override
  String get accountsOnlyArchivedHint => 'Показаны только архивные аккаунты.';

  @override
  String get accountsEmptyTitle => 'Пока нет аккаунтов';

  @override
  String get accountsEmptyBody => 'Создайте аккаунт, чтобы начать отслеживать активы.';

  @override
  String get accountsCreateAccount => 'Создать аккаунт';

  @override
  String get accountsNewTitle => 'Новый аккаунт';

  @override
  String get accountsNewBody =>
      'Дайте аккаунту название и выберите тип: банк, кошелёк, биржа, наличные или другое.';

  @override
  String get accountsEditTitle => 'Редактировать аккаунт';

  @override
  String get accountsNameLabel => 'Название аккаунта';

  @override
  String get accountsNameHint => 'например, Cash USD';

  @override
  String get accountsNameRequired => 'Название обязательно';

  @override
  String get accountsTypeLabel => 'Тип';

  @override
  String get accountsTypeBank => 'Банк';

  @override
  String get accountsTypeCryptoWallet => 'Криптокошелёк';

  @override
  String get accountsTypeExchange => 'Биржа';

  @override
  String get accountsTypeCash => 'Наличные';

  @override
  String get accountsTypeOther => 'Другое';

  @override
  String get accountsTypeBankDescription => 'Банковский счёт или накопления';

  @override
  String get accountsTypeCryptoWalletDescription => 'Криптокошелёк или самостоятельное хранение';

  @override
  String get accountsTypeExchangeDescription => 'Биржевой или торговый аккаунт';

  @override
  String get accountsTypeCashDescription => 'Наличные в наличии';

  @override
  String get accountsTypeOtherDescription => 'Другие активы или произвольный тип';

  @override
  String get accountsEdit => 'Редактировать';

  @override
  String get accountsArchive => 'В архив';

  @override
  String get accountsUnarchive => 'Из архива';

  @override
  String get accountsDelete => 'Удалить';

  @override
  String get accountsArchiveConfirmTitle => 'Отправить аккаунт в архив?';

  @override
  String get accountsArchiveConfirmBody => 'Этот аккаунт будет скрыт из итогов.';

  @override
  String get accountsUnarchiveConfirmTitle => 'Вернуть аккаунт из архива?';

  @override
  String get accountsDeleteConfirmTitle => 'Удалить аккаунт?';

  @override
  String get accountsDeleteConfirmBody =>
      'Будут удалены все активы и история балансов в этом аккаунте.';

  @override
  String get accountDetailAssetsTitle => 'Активы';

  @override
  String get accountDetailEmptyTitle => 'В этом аккаунте нет активов';

  @override
  String get accountDetailEmptyBody => 'Добавьте валюты или токены, которые вы держите здесь.';

  @override
  String get accountDetailArchivedHint => 'Архив — по умолчанию скрыт из итогов.';

  @override
  String get accountDetailTotalLabel => 'Итого';

  @override
  String get accountDetailMissingRatesTitle => 'Некоторые активы сейчас нельзя оценить.';

  @override
  String get accountDetailMissingRatesBody => 'Активы без курса не включены в итог с курсами.';

  @override
  String get assetAddTitle => 'Добавить актив';

  @override
  String get assetSearchHint => 'Поиск по коду или названию';

  @override
  String get assetAddCta => 'Добавить';

  @override
  String get assetDuplicateError => 'Этот актив уже добавлен в аккаунт.';

  @override
  String get assetNoMatchesTitle => 'Ничего не найдено';

  @override
  String get assetNoMatchesBody => 'Попробуйте изменить запрос.';

  @override
  String get assetPaywallHint => 'Перейдите на Pro, чтобы отслеживать больше активов.';

  @override
  String get assetAlreadyAddedLabel => 'Добавлено';

  @override
  String get assetKindFiat => 'Фиат';

  @override
  String get assetKindCrypto => 'Крипто';

  @override
  String get subaccountsCountLabel => 'позиций';

  @override
  String get subaccountCreateTitle => 'Добавить позицию';

  @override
  String get subaccountCreateCta => 'Добавить позицию';

  @override
  String get subaccountCurrencyLabel => 'Валюта';

  @override
  String get subaccountCurrencyRequired => 'Выберите валюту';

  @override
  String get subaccountNameHint => 'например, USDT (TRC20)';

  @override
  String get subaccountNameHintBank => 'например, Накопления USD';

  @override
  String get subaccountNameHintWalletExchange => 'например, BTC spot wallet';

  @override
  String get subaccountNameHintCash => 'например, Наличные дома';

  @override
  String get subaccountNameHintOther => 'например, Резерв';

  @override
  String get subaccountNameHelperBank => '';

  @override
  String get subaccountNameHelperWalletExchange =>
      'Добавьте сеть или площадку в название, чтобы различать похожие криптопозиции.';

  @override
  String get subaccountNameHelperCash =>
      'Укажите место или назначение: кошелёк, сейф или наличные в поездке.';

  @override
  String get subaccountNameHelperOther =>
      'Используйте любое название, по которому вы быстро узнаете эту позицию.';

  @override
  String get subaccountAmountHelperBank => 'Введите текущий баланс этой позиции.';

  @override
  String get subaccountAmountHelperWalletExchange => 'Введите текущее количество этого актива.';

  @override
  String get subaccountAmountHelperCash => 'Введите сумму наличных на руках.';

  @override
  String get subaccountAmountHelperOther =>
      'Введите текущую сумму, которую вы учитываете в этой позиции.';

  @override
  String get subaccountEmptyTitle => 'Пока нет позиций';

  @override
  String get subaccountEmptyBody => 'Добавьте активы, которые хранятся в этом аккаунте.';

  @override
  String get subaccountListTitle => 'Позиции';

  @override
  String get subaccountListCaption =>
      'Используйте отдельные позиции для каждой валюты или токена внутри этого аккаунта.';

  @override
  String get subaccountUpdateBalanceCta => 'Установить баланс';

  @override
  String get subaccountRenameCta => 'Переименовать';

  @override
  String get subaccountRenameTitle => 'Переименовать позицию';

  @override
  String get subaccountDeleteCta => 'Удалить';

  @override
  String get subaccountDeleteConfirmTitle => 'Удалить позицию?';

  @override
  String get subaccountDeleteConfirmBody => 'История балансов этой позиции будет удалена.';

  @override
  String get assetRemove => 'Удалить';

  @override
  String get assetRemoveConfirmTitle => 'Удалить актив?';

  @override
  String get assetRemoveConfirmBody =>
      'Актив будет удалён из этого аккаунта вместе с историей балансов.';

  @override
  String get positionCurrentBalanceLabel => 'Текущий баланс';

  @override
  String get positionConvertedValueLabel => 'Стоимость';

  @override
  String get positionUnpricedHint => 'Стоимость недоступна до обновления курсов.';

  @override
  String get positionAddBalance => 'Добавить баланс';

  @override
  String get positionUpdateThisMonth => 'Обновить за этот месяц';

  @override
  String get positionHistoryTitle => 'История баланса';

  @override
  String get positionHistoryDescription =>
      'Посмотрите, как баланс этой позиции менялся после каждого обновления.';

  @override
  String get positionHistoryEmptyTitle => 'Пока нет истории балансов';

  @override
  String get positionHistoryEmptyBody => 'Добавьте баланс или изменение, чтобы начать отслеживать.';

  @override
  String get positionHistoryEmptyCta => 'Добавить первый баланс';

  @override
  String get positionLoadMore => 'Загрузить ещё';

  @override
  String get balanceEntrySnapshot => 'Баланс';

  @override
  String get balanceEntryDelta => 'Изменение';

  @override
  String get balanceEntryImpliedDeltaLabel => 'Расчётное изменение';

  @override
  String get addBalanceTitle => 'Добавить баланс';

  @override
  String get addBalanceEntryTypeLabel => 'Тип записи';

  @override
  String get addBalanceTypeSnapshot => 'Текущий баланс';

  @override
  String get addBalanceTypeDelta => 'Изменение';

  @override
  String get addBalanceDateLabel => 'Дата';

  @override
  String get addBalanceAmountLabel => 'Сумма';

  @override
  String get addBalanceHelperSnapshot => 'Укажите новое текущее значение баланса этой позиции.';

  @override
  String get addBalanceHelperDelta => 'Изменение — насколько он вырос или уменьшился.';

  @override
  String get addBalanceValidationAmount => 'Введите сумму';

  @override
  String get addBalanceValidationDate => 'Выберите дату';

  @override
  String get paywallTitle => 'Перейти на Pro';

  @override
  String get paywallHeaderTitle => 'Перейти на Pro';

  @override
  String get paywallReasonAccounts => 'Вы достигли лимита Free-плана: 5 аккаунтов.';

  @override
  String get paywallReasonSubaccounts => 'Вы достигли лимита Free-плана: 15 позиций.';

  @override
  String get paywallReasonBaseCurrency => 'Перейдите на Pro, чтобы выбрать любую базовую валюту.';

  @override
  String get paywallReasonOnboarding => 'Начните с Pro-плана для полноценного учёта капитала.';

  @override
  String get paywallReasonManageSubscription =>
      'Перейдите на Pro в настройках и откройте все возможности приложения.';

  @override
  String get paywallEntitlementsError => 'Не удалось проверить подписку. Попробуйте снова.';

  @override
  String get paywallRestore => 'Восстановить';

  @override
  String get paywallIdentityPending => 'Подготавливаем безопасную покупку подписки...';

  @override
  String get paywallUnlockTitle => 'Перейти на Pro';

  @override
  String get paywallSubtitle => 'Без ограничений по аккаунтам, позициям и валютам.';

  @override
  String get paywallValueTitle => 'Весь капитал без ограничений';

  @override
  String get paywallValueSubtitle =>
      'Pro открывает полный учёт портфеля: аккаунты, позиции, валюты и свежие курсы.';

  @override
  String get paywallLoadingOfferings => 'Загружаем варианты подписки...';

  @override
  String get paywallNoOfferings => 'Сейчас нет доступных вариантов подписки.';

  @override
  String get paywallDismiss => 'Не сейчас';

  @override
  String get paywallContinue => 'Продолжить';

  @override
  String get paywallContinueFree => 'Продолжить бесплатно';

  @override
  String get paywallStartPro => 'Начать Pro';

  @override
  String get paywallMostPopular => 'Самый популярный';

  @override
  String get paywallFreeTitle => 'Free';

  @override
  String get paywallProTitle => 'Pro';

  @override
  String get paywallFreeFeatureAccounts => 'До 5 аккаунтов';

  @override
  String get paywallFreeFeatureSubaccounts => 'До 15 позиций';

  @override
  String get paywallFreeFeatureFiat => '5 популярных фиатных валют';

  @override
  String get paywallFreeFeatureCrypto => '5 популярных криптовалют';

  @override
  String get paywallProFeatureAccounts => 'Без ограничений по аккаунтам';

  @override
  String get paywallProFeatureSubaccounts => 'Без ограничений по позициям';

  @override
  String get paywallProFeatureFiat => '100+ фиатных валют';

  @override
  String get paywallProFeatureCrypto => '100+ криптовалют';

  @override
  String get paywallProFeatureFreshRates => 'Свежие курсы для всех итогов';

  @override
  String get paywallLegalPrefix =>
      'Отменить можно в любой момент. Оплата будет списана через магазин приложений.';

  @override
  String paywallLegalPrefixWithPrice(String price, String period) {
    return '$price / $period. Подписка продлевается автоматически, если не отменить её в аккаунте магазина.';
  }

  @override
  String get paywallBillingPeriodMonthly => 'месяц';

  @override
  String get paywallBillingPeriodAnnual => 'год';

  @override
  String get paywallLegalTerms => 'Условия';

  @override
  String get paywallLegalPrivacy => 'Конфиденциальность';

  @override
  String paywallMonthlyPrice(String price) {
    return 'Ежемесячно: $price / месяц';
  }

  @override
  String paywallYearlyPrice(String price) {
    return 'Ежегодно: $price / год';
  }

  @override
  String get paywallIncludesTitle => 'Что включено';

  @override
  String get paywallFeatureAccounts => 'Больше аккаунтов';

  @override
  String get paywallFeatureSubaccounts => 'Больше позиций';

  @override
  String get paywallFeatureCurrencies => 'Любая базовая валюта';

  @override
  String get paywallFeatureUpdates => 'Актуальный статус подписки';

  @override
  String get paywallPlansTitle => 'Выберите план';

  @override
  String get paywallPlanMonthlyTitle => 'Ежемесячно';

  @override
  String get paywallPlanMonthlySubtitle => 'Отмена в любой момент';

  @override
  String get paywallPlanAnnualTitle => 'Ежегодно';

  @override
  String get paywallPlanAnnualSubtitle => 'Выгоднее';

  @override
  String get paywallPlanRecommended => 'Рекомендуем';

  @override
  String get paywallUpgrade => 'Перейти на Pro';

  @override
  String get paywallAlreadyPaid => 'У вас уже активен Pro-план.';

  @override
  String get dsPreviewTotalBalanceLabel => 'Общий баланс';

  @override
  String get dsPreviewMonthlyReturnLabel => 'Доходность за месяц';

  @override
  String get dsPreviewRiskScoreLabel => 'Риск';

  @override
  String get dsPreviewRiskLow => 'Низкий';

  @override
  String get dsPreviewSectionTypography => 'Типографика';

  @override
  String get dsPreviewTypographyH1 => 'Заголовок 1';

  @override
  String get dsPreviewTypographyH2 => 'Заголовок 2';

  @override
  String get dsPreviewTypographyH3 => 'Заголовок 3';

  @override
  String get dsPreviewTypographyBody => 'Пример основного текста';

  @override
  String get dsPreviewTypographyCaption => 'Подпись';

  @override
  String get dsPreviewSectionButtons => 'Кнопки';

  @override
  String get dsPreviewButtonAddAsset => 'Добавить актив';

  @override
  String get dsPreviewButtonSecondary => 'Вторичная';

  @override
  String get dsPreviewButtonDelete => 'Удалить';

  @override
  String get dsPreviewButtonLoading => 'Загрузка';

  @override
  String get dsPreviewSectionInputs => 'Поля ввода';

  @override
  String get dsPreviewInputAccountNameLabel => 'Название аккаунта';

  @override
  String get dsPreviewInputAccountNameHint => 'например, Cash USD';

  @override
  String get dsPreviewInputAmountLabel => 'Сумма';

  @override
  String get dsPreviewSectionCards => 'Карточки';

  @override
  String get dsPreviewCardPortfolioTitle => 'Снимок портфеля';

  @override
  String get dsPreviewCardPortfolioBody => 'Диверсифицировано по 6 аккаунтам и 19 активам.';

  @override
  String get dsPreviewCardViewReport => 'Открыть отчёт';

  @override
  String get dsPreviewCardRebalance => 'Ребалансировать';

  @override
  String get dsPreviewSectionListItems => 'Список';

  @override
  String get dsPreviewListCheckingTitle => 'Расчётный счёт';

  @override
  String get dsPreviewListBankSubtitle => 'Банк';

  @override
  String get dsPreviewListBrokerageTitle => 'Брокерский счёт';

  @override
  String get dsPreviewListInvestmentSubtitle => 'Инвестиции';

  @override
  String get dsPreviewListCashWalletTitle => 'Кошелёк';

  @override
  String get dsPreviewListCashSubtitle => 'Наличные';

  @override
  String get dsPreviewSectionDialogs => 'Диалоги';

  @override
  String get dsPreviewDialogShowButton => 'Показать диалог';

  @override
  String get dsPreviewDialogDeleteAccountTitle => 'Удалить аккаунт';

  @override
  String get dsPreviewDialogDeleteAccountBody => 'Это действие нельзя отменить.';

  @override
  String get dsPreviewDialogCancel => 'Отмена';

  @override
  String get dsPreviewSectionLoaders => 'Индикаторы';

  @override
  String get dsPreviewSectionShimmers => 'Шиммеры';

  @override
  String get dsPreviewSectionStates => 'Состояния';

  @override
  String get dsPreviewStateEmptyTitle => 'Нет аккаунтов';

  @override
  String get dsPreviewStateEmptyBody => 'Создайте первый аккаунт, чтобы начать.';

  @override
  String get dsPreviewStateEmptyAction => 'Создать аккаунт';

  @override
  String get dsPreviewStateErrorTitle => 'Что-то пошло не так';

  @override
  String get dsPreviewStateErrorBody => 'Не удалось загрузить данные. Попробуйте снова.';

  @override
  String dsPreviewPercentThisMonth(String percent) {
    return '$percent за месяц';
  }

  @override
  String dsPreviewUpdatedAt(String timestamp) {
    return 'Обновлено: $timestamp';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionPreferences => 'Предпочтения';

  @override
  String get settingsBaseCurrency => 'Базовая валюта';

  @override
  String get settingsSectionSubscription => 'Подписка';

  @override
  String get settingsPlanStatus => 'Тариф';

  @override
  String get settingsPlanFree => 'Free-план';

  @override
  String get settingsPlanPaid => 'Pro-план';

  @override
  String get settingsManageSubscription => 'Управлять подпиской';

  @override
  String get profileUpgradePlan => 'Перейти на Pro';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get profileSignOutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get profileSignOutConfirmBody =>
      'Чтобы снова получить доступ к аккаунту, нужно будет войти заново.';

  @override
  String get profileSignOutConfirmCta => 'Выйти';

  @override
  String get settingsEntitlementsError => 'Не удалось проверить статус подписки.';

  @override
  String get baseCurrencySettingsTitle => 'Базовая валюта';

  @override
  String get baseCurrencySettingsCurrentTitle => 'Ваша базовая валюта';

  @override
  String get baseCurrencySettingsCurrentBody => 'Все итоги конвертируются в эту валюту.';

  @override
  String get baseCurrencySettingsPickerTitle => 'Выберите валюту';

  @override
  String get baseCurrencySettingsSave => 'Сохранить';

  @override
  String get baseCurrencySettingsLoadErrorTitle => 'Не удалось загрузить валюты.';

  @override
  String get baseCurrencySettingsPaywallHint =>
      'Перейдите на Pro, чтобы открыть больше базовых валют.';

  @override
  String get baseCurrencySettingsSearchHint => 'Поиск валюты';

  @override
  String get baseCurrencySettingsBrowseAll => 'Показать все валюты';

  @override
  String get baseCurrencySettingsSearchTip =>
      'Подсказка: введите минимум 2 символа. По умолчанию показаны популярные валюты.';

  @override
  String get baseCurrencySettingsResultsHint =>
      'Показана только часть результатов. Уточните запрос, чтобы найти больше.';

  @override
  String get baseCurrencyHowTitle => 'Как считается итог';

  @override
  String get baseCurrencyHowRatesTitle => 'Курсы обновляются каждый час';

  @override
  String get baseCurrencyHowRatesBody => 'Для каждой валюты используются свежие курсы.';

  @override
  String get baseCurrencyHowConvertTitle => 'Каждая позиция пересчитывается';

  @override
  String get baseCurrencyHowConvertBody =>
      'Каждый актив конвертируется в базовую валюту по текущему курсу.';

  @override
  String get baseCurrencyHowSumTitle => 'Суммы складываются';

  @override
  String get baseCurrencyHowSumBody => 'Конвертированные суммы складываются в общий итог портфеля.';

  @override
  String get currencyPickerRecentTitle => 'Недавние';

  @override
  String get currencyPickerSelectedTitle => 'Выбрано';

  @override
  String get currencyPickerChangeAction => 'Изменить';

  @override
  String get currencyPickerNoResultsTitle => 'Валюты не найдены';

  @override
  String get currencyPickerNoResultsBody => 'Попробуйте другой код или название.';

  @override
  String get subscriptionTitle => 'Подписка';

  @override
  String get subscriptionStatusTitle => 'Статус';

  @override
  String get subscriptionManage => 'Управлять подпиской';

  @override
  String get subscriptionRestore => 'Восстановить покупки';

  @override
  String get subscriptionCancel => 'Отменить подписку';

  @override
  String get subscriptionUpgrade => 'Перейти на годовой Pro';

  @override
  String get subscriptionFreeHeroTitle => 'Откройте полный учёт портфеля';

  @override
  String get subscriptionFreeHeroBody =>
      'Pro снимает лимиты по аккаунтам, позициям, базовым валютам и итогам со свежими курсами.';

  @override
  String get subscriptionFreeBody =>
      'У вас Free-план. Перейдите на Pro, чтобы открыть все базовые валюты.';

  @override
  String get subscriptionPaidBody => 'У вас Pro-план. Спасибо за поддержку Asset Tuner.';

  @override
  String get subscriptionFeaturesTitle => 'Что включено';

  @override
  String get subscriptionStatusActive => 'Активна';

  @override
  String get subscriptionPlaceholderBody => 'Управление подпиской появится в будущих обновлениях.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileSectionPreferences => 'Предпочтения';

  @override
  String get profileSectionPortfolio => 'Портфель';

  @override
  String get profileAccounts => 'Аккаунты';

  @override
  String get settingsArchivedAccounts => 'Архивные аккаунты';

  @override
  String get archivedAccountsGlobalTotalHint => 'Архивные аккаунты не участвуют в общем итоге.';

  @override
  String get archivedAccountsEmptyTitle => 'Нет архивных аккаунтов';

  @override
  String get archivedAccountsEmptyBody => 'Аккаунты, которые вы архивируете, появятся здесь.';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileLanguageSystem => 'Системный';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageRussian => 'Русский';

  @override
  String get profileTheme => 'Тема';

  @override
  String get profileThemeSystem => 'Системная';

  @override
  String get profileThemeLight => 'Светлая';

  @override
  String get profileThemeDark => 'Тёмная';

  @override
  String get profileSectionSupport => 'Поддержка';

  @override
  String get profileContactDeveloperAction => 'Связаться с разработчиком';

  @override
  String get profileContactDeveloperTitle => 'Связаться с разработчиком';

  @override
  String get profileContactDeveloperDescription =>
      'Опишите баг или идею. Мы ответим на вашу почту.';

  @override
  String get profileContactDeveloperEmailLabel => 'Ваш email';

  @override
  String get profileContactDeveloperMessageLabel => 'Сообщение';

  @override
  String get profileContactDeveloperMessageHint => 'Опишите проблему или предложение';

  @override
  String get profileContactDeveloperMessageRequired => 'Введите сообщение';

  @override
  String get profileContactDeveloperSubmitCta => 'Отправить';

  @override
  String get profileContactDeveloperSuccess => 'Спасибо, что поделились';

  @override
  String get profileSectionLegal => 'Юридическая информация';

  @override
  String get profileLegalTermsOfUse => 'Условия использования';

  @override
  String get profileLegalPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get profileSectionAccount => 'Аккаунт';

  @override
  String get profileAccountActionsTitle => 'Действия аккаунта';

  @override
  String get profileAccountActionsSubtitle => 'Выход или удаление аккаунта';

  @override
  String get profileDeleteAccountTitle => 'Удалить аккаунт';

  @override
  String get profileDeleteAccountBody =>
      'Локальные данные будут удалены, а вы выйдете из аккаунта.';

  @override
  String get profileDeleteAccountCta => 'Удалить аккаунт';

  @override
  String get profileDeleteConfirmTitle => 'Удалить аккаунт?';

  @override
  String get profileDeleteConfirmBody => 'Это действие нельзя отменить.';

  @override
  String get profileDeleteConfirmCta => 'Удалить';

  @override
  String get profileDeleteConfirmCancel => 'Отмена';

  @override
  String profileHeaderSubtitle(String plan, String currency) {
    return '$plan · Базовая валюта: $currency';
  }

  @override
  String profileHeaderCurrencyLabel(String currency) {
    return 'Базовая валюта: $currency';
  }

  @override
  String get subscriptionManageSuccess => 'Статус подписки обновлён.';

  @override
  String get subscriptionRestoreSuccess => 'Покупки восстановлены.';

  @override
  String get subscriptionCancelSuccess => 'Подписка отменена.';

  @override
  String get guidedTourSkip => 'Пропустить';

  @override
  String get guidedTourNext => 'Далее';

  @override
  String get guidedTourFinish => 'Завершить';

  @override
  String guidedTourProgress(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get guidedTourOverviewStep1Title => 'Итог портфеля';

  @override
  String get guidedTourOverviewStep1Body =>
      'В этой карточке отображается общая стоимость активов в выбранной базовой валюте.';

  @override
  String get guidedTourOverviewStep2Title => 'Создайте аккаунт';

  @override
  String get guidedTourOverviewStep2Body =>
      'Нажмите здесь, чтобы добавить банковский аккаунт, кошелёк, биржу, наличные или другой тип аккаунта.';

  @override
  String get guidedTourOverviewStep3Title => 'Обновляйте данные';

  @override
  String get guidedTourOverviewStep3Body =>
      'Потяните экран «Главная» вниз, чтобы обновить балансы и курсы.';
}
