import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Localization delegate for date picker
class DatePickerLocalizationsDelegate
    extends LocalizationsDelegate<DatePickerLocalizations> {
  const DatePickerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => 
      ['en', 'zh', 'es', 'fr', 'de', 'ja', 'ko'].contains(locale.languageCode);

  @override
  Future<DatePickerLocalizations> load(Locale locale) async {
    return DatePickerLocalizations(locale);
  }

  @override
  bool shouldReload(DatePickerLocalizationsDelegate old) => false;
}

/// Localization class for date picker
class DatePickerLocalizations {
  final Locale locale;

  const DatePickerLocalizations(this.locale);

  static DatePickerLocalizations? of(BuildContext context) {
    return Localizations.of<DatePickerLocalizations>(context, DatePickerLocalizations);
  }

  static const LocalizationsDelegate<DatePickerLocalizations> delegate =
      DatePickerLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    DatePickerLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
  ];

  // Month names in different languages
  static const Map<String, List<String>> _monthNames = {
    'en': [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ],
    'zh': [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ],
    'es': [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ],
    'fr': [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ],
    'de': [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ],
    'ja': [
      '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月'
    ],
    'ko': [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ],
  };

  // Weekday names in different languages
  static const Map<String, List<String>> _weekdayNames = {
    'en': ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    'zh': ['日', '一', '二', '三', '四', '五', '六'],
    'es': ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá'],
    'fr': ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
    'de': ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
    'ja': ['日', '月', '火', '水', '木', '金', '土'],
    'ko': ['일', '월', '화', '수', '목', '금', '토'],
  };

  List<String> get monthNames => _monthNames[locale.languageCode]!;
  List<String> get weekdayNames => _weekdayNames[locale.languageCode]!;

  String getMonthName(int month) => monthNames[month - 1];
  String getWeekdayName(int weekday) => weekdayNames[weekday % 7];

  // Common strings
  String get selectYear => _getString('selectYear', 'Select Year');
  String get selectMonth => _getString('selectMonth', 'Select Month');
  String get selectDate => _getString('selectDate', 'Select Date');
  String get cancel => _getString('cancel', 'Cancel');
  String get confirm => _getString('confirm', 'Confirm');

  // Date format patterns
  String get monthYearFormat {
    switch (locale.languageCode) {
      case 'zh':
        return 'yyyy年M月';
      case 'ja':
      case 'ko':
        return 'yyyy年M月';
      default:
        return 'MMMM yyyy';
    }
  }

  String _getString(String key, String defaultValue) {
    final strings = _localizedStrings[locale.languageCode] ?? {};
    return strings[key] ?? defaultValue;
  }

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'selectYear': 'Select Year',
      'selectMonth': 'Select Month',
      'selectDate': 'Select Date',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
    },
    'zh': {
      'selectYear': '选择年份',
      'selectMonth': '选择月份',
      'selectDate': '选择日期',
      'cancel': '取消',
      'confirm': '确定',
    },
    'es': {
      'selectYear': 'Seleccionar Año',
      'selectMonth': 'Seleccionar Mes',
      'selectDate': 'Seleccionar Fecha',
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
    },
    'fr': {
      'selectYear': 'Sélectionner l\'année',
      'selectMonth': 'Sélectionner le mois',
      'selectDate': 'Sélectionner la date',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
    },
    'de': {
      'selectYear': 'Jahr auswählen',
      'selectMonth': 'Monat auswählen',
      'selectDate': 'Datum auswählen',
      'cancel': 'Abbrechen',
      'confirm': 'Bestätigen',
    },
    'ja': {
      'selectYear': '年を選択',
      'selectMonth': '月を選択',
      'selectDate': '日付を選択',
      'cancel': 'キャンセル',
      'confirm': '確定',
    },
    'ko': {
      'selectYear': '연도 선택',
      'selectMonth': '월 선택',
      'selectDate': '날짜 선택',
      'cancel': '취소',
      'confirm': '확인',
    },
  };
}