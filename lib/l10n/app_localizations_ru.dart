// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'AllMovies';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get guestUser => 'Гость';

  @override
  String get search => 'Искать фильмы...';

  @override
  String get movies => 'Фильмы';

  @override
  String get series => 'Сериалы';

  @override
  String get people => 'Персоны';

  @override
  String get companies => 'Компании';

  @override
  String get settings => 'Настройки';

  @override
  String get about => 'О приложении';

  @override
  String get logout => 'Выйти';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Регистрация';

  @override
  String get email => 'Эл. почта';

  @override
  String get password => 'Пароль';

  @override
  String get fullName => 'Полное имя';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get localization => 'Локализация';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get chooseTheme => 'Выбор темы';

  @override
  String get chooseLanguage => 'Выбор языка';

  @override
  String get cancel => 'Отмена';

  @override
  String get home => 'Главная';

  @override
  String get exploreCollections =>
      'Ознакомьтесь с последними новинками нашего каталога.';

  @override
  String get noMoviesFound => 'По вашему запросу ничего не найдено.';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get keywords => 'Ключевые слова';

  @override
  String get apiExplorer => 'TMDB Эксплорер';

  @override
  String get filters => 'Фильтры';

  @override
  String get reset => 'Сброс';

  @override
  String get region => 'Регион';

  @override
  String get byDecade => 'По десятилетиям';

  @override
  String get certification => 'Возрастной рейтинг';

  @override
  String get releaseDateRange => 'Диапазон дат релиза';

  @override
  String get from => 'От';

  @override
  String get to => 'До';

  @override
  String get voteAverage => 'Средний рейтинг';

  @override
  String get runtimeMinutes => 'Продолжительность (мин)';

  @override
  String get voteCountMinimum => 'Минимум голосов';

  @override
  String get monetizationTypes => 'Типы монетизации';

  @override
  String get watchProvidersIds => 'Провайдеры (ID)';

  @override
  String get providerIdsHint => 'ID провайдеров через запятую, напр.: 8,9,337';

  @override
  String get releaseType => 'Тип релиза';

  @override
  String get releaseTypePremiere => 'Премьера';

  @override
  String get releaseTypeTheatricalLimited => 'Кино (ограниченный)';

  @override
  String get releaseTypeTheatrical => 'Кино';

  @override
  String get releaseTypeDigital => 'Цифровой';

  @override
  String get releaseTypePhysical => 'Физический';

  @override
  String get releaseTypeTV => 'ТВ';

  @override
  String get includeAdultContent => 'Включить контент 18+';

  @override
  String get peopleCompaniesKeywords => 'Персоны, компании и ключевые слова';

  @override
  String get withCastHint => 'С актёрами (ID через запятую)';

  @override
  String get withCrewHint => 'С командой (ID через запятую)';

  @override
  String get withCompaniesHint => 'С компаниями (ID через запятую)';

  @override
  String get withKeywordsHint => 'С ключевыми словами (ID через запятую)';

  @override
  String get apply => 'Применить';

  @override
  String get peopleDepartmentsLabel => 'Направление';

  @override
  String get peopleDepartmentsAll => 'Все направления';

  @override
  String get peopleDepartmentsActing => 'Актёрская игра';

  @override
  String get peopleDepartmentsDirecting => 'Режиссура';

  @override
  String get peopleDepartmentsProduction => 'Продюсирование';

  @override
  String get peopleDepartmentsWriting => 'Сценарий';

  @override
  String get peopleDepartmentsEditing => 'Монтаж';

  @override
  String get peopleDepartmentsCamera => 'Операторская работа';

  @override
  String get peopleDepartmentsSound => 'Звук';

  @override
  String get peopleDepartmentsArt => 'Художественный отдел';

  @override
  String get peopleDepartmentsCostumeAndMakeUp => 'Костюмы и грим';

  @override
  String get peopleDepartmentsCrew => 'Съемочная группа';

  @override
  String get peopleDepartmentsLighting => 'Освещение';

  @override
  String get peopleDepartmentsVisualEffects => 'Визуальные эффекты';

  @override
  String get genresTitle => 'Жанры';

  @override
  String get genresMoviesTab => 'Фильмы';

  @override
  String get genresTvTab => 'Сериалы';

  @override
  String get genresEmptyMovies => 'Жанры фильмов появятся после синхронизации с TMDB.';

  @override
  String get genresEmptyTv => 'Жанры сериалов появятся после синхронизации с TMDB.';

  @override
  String get genresDiscoverMovies => 'Открыть подборку фильмов';

  @override
  String get genresDiscoverTv => 'Открыть подборку сериалов';

  @override
  String get genresAdjustFilters => 'Настроить фильтры';

  @override
  String get genresErrorFallback => 'Показываем резервный список жанров, пока TMDB недоступен.';
}
