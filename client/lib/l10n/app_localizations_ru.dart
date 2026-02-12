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
  String get errorForbidden => 'Недостаточно прав для выполнения действия.';

  @override
  String get errorNotFound => 'Не удалось найти запрошенные данные.';

  @override
  String get errorValidation =>
      'Проверьте введенные данные и попробуйте снова.';

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
  String get mainTitle => 'Главная';

  @override
  String get mainAddAccount => 'Добавить аккаунт';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsBreakdownTitle => 'Разбивка';

  @override
  String get analyticsUpdatesTitle => 'Обновления';

  @override
  String get analyticsEmptyTitle => 'Пока нет аналитики';

  @override
  String get analyticsEmptyBody =>
      'Добавьте аккаунты и балансы, чтобы увидеть разбивку и обновления.';

  @override
  String get actionsTitle => 'Действия';

  @override
  String get overviewTotalLabel => 'Итого';

  @override
  String get notAvailable => 'Н/Д';

  @override
  String get unpriced => 'Без цены';

  @override
  String get overviewEmptyBody => 'Данные появятся после добавления счетов.';

  @override
  String get overviewEmptyNoAccountsTitle => 'Создайте первый счет';

  @override
  String get overviewEmptyNoAccountsBody =>
      'Добавьте счет, чтобы начать отслеживать активы и итоги.';

  @override
  String get overviewEmptyNoAccountsCta => 'Создать счет';

  @override
  String get overviewEmptyNoAssetsTitle => 'Добавьте первый актив';

  @override
  String get overviewEmptyNoAssetsBody =>
      'Добавьте валюты или токены в один из счетов.';

  @override
  String get overviewEmptyNoAssetsCta => 'Добавить актив';

  @override
  String get overviewEmptyNoBalancesTitle => 'Добавьте первый баланс';

  @override
  String get overviewEmptyNoBalancesBody =>
      'Добавьте снимок или изменение, чтобы увидеть итоги.';

  @override
  String get overviewEmptyNoBalancesCta => 'Добавить баланс';

  @override
  String get overviewPricedTotalLabel => 'Итого по оцененным';

  @override
  String get overviewMissingRatesTitle =>
      'Некоторые активы сейчас нельзя оценить.';

  @override
  String get overviewMissingRatesBody =>
      'Итоги не включают активы без цены, пока курсы не обновятся.';

  @override
  String get overviewUnpricedHoldingsTitle => 'Активы без цены';

  @override
  String get overviewPartialHint => 'Частично';

  @override
  String get offlineTitle => 'Офлайн';

  @override
  String offlineShowingLastSaved(String time) {
    return 'Показаны последние сохраненные итоги от $time.';
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
  String get accountsTitle => 'Счета';

  @override
  String get accountsAddAccount => 'Добавить счет';

  @override
  String get accountsActiveSection => 'Счета';

  @override
  String get accountsArchivedSection => 'Архив';

  @override
  String get accountsOnlyArchivedHint => 'Показаны только архивные счета.';

  @override
  String get accountsEmptyTitle => 'Пока нет счетов';

  @override
  String get accountsEmptyBody =>
      'Создайте счет, чтобы начать отслеживать активы.';

  @override
  String get accountsCreateAccount => 'Создать счет';

  @override
  String get accountsNewTitle => 'Новый счет';

  @override
  String get accountsEditTitle => 'Редактировать счет';

  @override
  String get accountsNameLabel => 'Название счета';

  @override
  String get accountsNameHint => 'например, Cash USD';

  @override
  String get accountsNameRequired => 'Название обязательно';

  @override
  String get accountsTypeLabel => 'Тип';

  @override
  String get accountsTypeBank => 'Банк';

  @override
  String get accountsTypeCryptoWallet => 'Криптокошелек';

  @override
  String get accountsTypeExchange => 'Биржа';

  @override
  String get accountsTypeCash => 'Наличные';

  @override
  String get accountsTypeOther => 'Другое';

  @override
  String get accountsEdit => 'Редактировать';

  @override
  String get accountsArchive => 'В архив';

  @override
  String get accountsUnarchive => 'Из архива';

  @override
  String get accountsDelete => 'Удалить';

  @override
  String get accountsArchiveConfirmTitle => 'Отправить счет в архив?';

  @override
  String get accountsArchiveConfirmBody => 'Этот счет будет скрыт из итогов.';

  @override
  String get accountsUnarchiveConfirmTitle => 'Вернуть счет из архива?';

  @override
  String get accountsDeleteConfirmTitle => 'Удалить счет?';

  @override
  String get accountsDeleteConfirmBody =>
      'Будут удалены все активы и история балансов в этом счете.';

  @override
  String get accountDetailAssetsTitle => 'Активы';

  @override
  String get accountDetailEmptyTitle => 'В этом счете нет активов';

  @override
  String get accountDetailEmptyBody =>
      'Добавьте валюты или токены, которые вы держите здесь.';

  @override
  String get accountDetailArchivedHint =>
      'Архив — по умолчанию скрыт из итогов.';

  @override
  String get accountDetailTotalLabel => 'Итого';

  @override
  String get accountDetailMissingRatesTitle =>
      'Некоторые активы сейчас нельзя оценить.';

  @override
  String get accountDetailMissingRatesBody =>
      'Активы без цены не включены в итог по оцененным.';

  @override
  String get assetAddTitle => 'Добавить актив';

  @override
  String get assetSearchHint => 'Поиск по коду или названию';

  @override
  String get assetAddCta => 'Добавить';

  @override
  String get assetDuplicateError => 'Этот актив уже добавлен в счет.';

  @override
  String get assetNoMatchesTitle => 'Ничего не найдено';

  @override
  String get assetNoMatchesBody => 'Попробуйте изменить запрос.';

  @override
  String get assetPaywallHint =>
      'Оформите подписку, чтобы отслеживать больше активов.';

  @override
  String get assetAlreadyAddedLabel => 'Добавлено';

  @override
  String get assetKindFiat => 'Фиат';

  @override
  String get assetKindCrypto => 'Крипто';

  @override
  String get subaccountsCountLabel => 'счетов';

  @override
  String get subaccountCreateTitle => 'Добавить счет';

  @override
  String get subaccountCreateCta => 'Добавить счет';

  @override
  String get subaccountCurrencyLabel => 'Валюта';

  @override
  String get subaccountNameHint => 'например, USDT (TRC20)';

  @override
  String get subaccountEmptyTitle => 'Пока нет счетов';

  @override
  String get subaccountEmptyBody =>
      'Добавьте активы, которые хранятся в этом аккаунте.';

  @override
  String get subaccountListTitle => 'Счета';

  @override
  String get subaccountUpdateBalanceCta => 'Обновить баланс';

  @override
  String get subaccountRenameCta => 'Переименовать';

  @override
  String get subaccountRenameTitle => 'Переименовать счет';

  @override
  String get subaccountDeleteCta => 'Удалить';

  @override
  String get subaccountDeleteConfirmTitle => 'Удалить счет?';

  @override
  String get subaccountDeleteConfirmBody =>
      'Это удалит историю балансов счета.';

  @override
  String get assetRemove => 'Удалить';

  @override
  String get assetRemoveConfirmTitle => 'Удалить актив?';

  @override
  String get assetRemoveConfirmBody =>
      'Актив будет удален из этого счета вместе с историей балансов.';

  @override
  String get positionCurrentBalanceLabel => 'Текущий баланс';

  @override
  String get positionConvertedValueLabel => 'Стоимость';

  @override
  String get positionUnpricedHint =>
      'Стоимость недоступна до обновления курсов.';

  @override
  String get positionAddBalance => 'Добавить баланс';

  @override
  String get positionUpdateThisMonth => 'Обновить за этот месяц';

  @override
  String get positionHistoryTitle => 'История';

  @override
  String get positionHistoryEmptyTitle => 'Пока нет истории балансов';

  @override
  String get positionHistoryEmptyBody =>
      'Добавьте снимок или изменение, чтобы начать отслеживать.';

  @override
  String get positionHistoryEmptyCta => 'Добавить первый баланс';

  @override
  String get positionLoadMore => 'Загрузить еще';

  @override
  String get balanceEntrySnapshot => 'Снимок';

  @override
  String get balanceEntryDelta => 'Изменение';

  @override
  String get balanceEntryImpliedDeltaLabel => 'Расчетное изменение';

  @override
  String get addBalanceTitle => 'Добавить баланс';

  @override
  String get addBalanceEntryTypeLabel => 'Тип записи';

  @override
  String get addBalanceTypeSnapshot => 'Снимок';

  @override
  String get addBalanceTypeDelta => 'Изменение';

  @override
  String get addBalanceDateLabel => 'Дата';

  @override
  String get addBalanceAmountLabel => 'Сумма';

  @override
  String get addBalanceHelperSnapshot =>
      'Снимок — это ваш баланс на выбранную дату.';

  @override
  String get addBalanceHelperDelta =>
      'Изменение — насколько он вырос или уменьшился.';

  @override
  String get addBalanceValidationAmount => 'Введите сумму';

  @override
  String get addBalanceValidationDate => 'Выберите дату';

  @override
  String get paywallTitle => 'Подписка';

  @override
  String get paywallHeaderTitle => 'Подписка';

  @override
  String get paywallReasonAccounts =>
      'Вы достигли бесплатного лимита: 5 счетов.';

  @override
  String get paywallReasonSubaccounts =>
      'Вы достигли бесплатного лимита: 20 счетов.';

  @override
  String get paywallReasonBaseCurrency => 'Откройте любую базовую валюту.';

  @override
  String get paywallEntitlementsError =>
      'Не удалось проверить подписку. Попробуйте снова.';

  @override
  String get paywallDismiss => 'Позже';

  @override
  String get paywallIncludesTitle => 'Что включено';

  @override
  String get paywallFeatureAccounts => 'Больше счетов';

  @override
  String get paywallFeatureSubaccounts => 'Больше счетов';

  @override
  String get paywallFeatureCurrencies => 'Любая базовая валюта';

  @override
  String get paywallFeatureUpdates => 'Обновление статуса подписки';

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
  String get paywallUpgrade => 'Оформить подписку';

  @override
  String get paywallAlreadyPaid => 'У вас уже активен платный план.';

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
  String get dsPreviewInputAccountNameLabel => 'Название счета';

  @override
  String get dsPreviewInputAccountNameHint => 'например, Cash USD';

  @override
  String get dsPreviewInputAmountLabel => 'Сумма';

  @override
  String get dsPreviewSectionCards => 'Карточки';

  @override
  String get dsPreviewCardPortfolioTitle => 'Снимок портфеля';

  @override
  String get dsPreviewCardPortfolioBody =>
      'Диверсифицировано по 6 счетам и 19 активам.';

  @override
  String get dsPreviewCardViewReport => 'Открыть отчет';

  @override
  String get dsPreviewCardRebalance => 'Ребалансировать';

  @override
  String get dsPreviewSectionListItems => 'Список';

  @override
  String get dsPreviewListCheckingTitle => 'Расчетный счет';

  @override
  String get dsPreviewListBankSubtitle => 'Банк';

  @override
  String get dsPreviewListBrokerageTitle => 'Брокерский счет';

  @override
  String get dsPreviewListInvestmentSubtitle => 'Инвестиции';

  @override
  String get dsPreviewListCashWalletTitle => 'Кошелек';

  @override
  String get dsPreviewListCashSubtitle => 'Наличные';

  @override
  String get dsPreviewSectionDialogs => 'Диалоги';

  @override
  String get dsPreviewDialogShowButton => 'Показать диалог';

  @override
  String get dsPreviewDialogDeleteAccountTitle => 'Удалить счет';

  @override
  String get dsPreviewDialogDeleteAccountBody =>
      'Это действие нельзя отменить.';

  @override
  String get dsPreviewDialogCancel => 'Отмена';

  @override
  String get dsPreviewSectionLoaders => 'Индикаторы';

  @override
  String get dsPreviewSectionShimmers => 'Шиммеры';

  @override
  String get dsPreviewSectionStates => 'Состояния';

  @override
  String get dsPreviewStateEmptyTitle => 'Нет счетов';

  @override
  String get dsPreviewStateEmptyBody => 'Создайте первый счет, чтобы начать.';

  @override
  String get dsPreviewStateEmptyAction => 'Создать счет';

  @override
  String get dsPreviewStateErrorTitle => 'Что-то пошло не так';

  @override
  String get dsPreviewStateErrorBody =>
      'Не удалось загрузить данные. Попробуйте снова.';

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
  String get settingsPlanFree => 'Бесплатный план';

  @override
  String get settingsPlanPaid => 'Платный план';

  @override
  String get settingsManageSubscription => 'Управление подпиской';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsEntitlementsError =>
      'Не удалось проверить статус подписки.';

  @override
  String get baseCurrencySettingsTitle => 'Базовая валюта';

  @override
  String get baseCurrencySettingsCurrentTitle => 'Текущий выбор';

  @override
  String get baseCurrencySettingsCurrentBody =>
      'Итоги будут конвертироваться в эту валюту.';

  @override
  String get baseCurrencySettingsPickerTitle => 'Выберите валюту';

  @override
  String get baseCurrencySettingsSave => 'Сохранить';

  @override
  String get baseCurrencySettingsLoadErrorTitle =>
      'Не удалось загрузить валюты.';

  @override
  String get baseCurrencySettingsPaywallHint =>
      'Оформите подписку, чтобы открыть больше базовых валют.';

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
  String get subscriptionTitle => 'Подписка';

  @override
  String get subscriptionStatusTitle => 'Статус';

  @override
  String get subscriptionManage => 'Управление подпиской';

  @override
  String get subscriptionRestore => 'Восстановить покупки';

  @override
  String get subscriptionCancel => 'Отменить подписку';

  @override
  String get subscriptionUpgrade => 'Оформить подписку';

  @override
  String get subscriptionFreeBody =>
      'У вас бесплатный план. Оформите подписку, чтобы открыть все базовые валюты.';

  @override
  String get subscriptionPaidBody =>
      'У вас платный план. Спасибо за поддержку Asset Tuner.';

  @override
  String get subscriptionPlaceholderBody =>
      'Управление подпиской появится в будущих обновлениях.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileSectionPreferences => 'Предпочтения';

  @override
  String get profileSectionPortfolio => 'Портфель';

  @override
  String get profileAccounts => 'Счета';

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
  String get profileThemeDark => 'Темная';

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
  String get subscriptionManageSuccess => 'Статус подписки обновлен.';

  @override
  String get subscriptionRestoreSuccess => 'Покупки восстановлены.';

  @override
  String get subscriptionCancelSuccess => 'Подписка отменена.';
}
