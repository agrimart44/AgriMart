import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'app_localizations_en.dart';
import 'app_localizations_si.dart'; 
import 'app_localizations_ta.dart';


abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate's supported locales.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];


  String get personal_information;

  String get Edit_Profile;

  String get update_your_information;

  String get full_name;

  String get gender;

  String get role;

  String get no;

  String get location;

  String get exit_app;

  String get yes;

  String get are_you_sure_you_want_to_exit;

  String get choose_an_option;

  String get gallery;

  String get camera;

  String get success;

  String get crop_listed_successfully;

  String get ok;

  String get error;

  String get add_at_least_one_photo;

  String get auth_token_not_found;

  String get messages;

  String get an_error_occurred;

  String get list_crop;

  String get add_photos;

  String get listing_details;

  String get name;

  String get enter_crop_name;

  String get description;

  String get enter_description;

  String get price_lkr;

  String get enter_price;

  String get enter_valid_price;

  String get select_location;

  String get quantity_kg;

  String get enter_quantity;

  String get enter_valid_quantity;

  String get harvest_date;

  String get select_date;

  String get done;

  String get harvest;

  String get view_details;

  String get about_this_product;

  String get quantity;

  String get available_quantity;

  String get add_to_cart;

  String get chat_with_seller;

  String get call_instead;

  String get comment_;

  String get search;

  String get market_prices;

  String get negotiations;

  String get market_place;

  String get your_account_information;

  String get password_and_account;

  String get language_settings;

  String get choose_your_preffered_language;

  String get checkout_our_policy_details;

  String get per_kg;

  String get listing_crop;

  String get crop_harvest_date;

  String get add_upto_3_photos;

  String get crop_location;

  String get add_clear_photos;

  String get list_new_crop;

  String get organic_tomatoes;

  String get tap_to_add_photos;

  String get crop_photos;

  String get home;

  String get cart;

  String get describe_your_crop;

  String get avg_price;

  String get active_crops;

  String get profile;

  String get crops_with_interest;

  String get farm_statistics;

  String get total_crops;

  String get settings;

  String get total_quantity;

  String get conversations;

  String get total_value;

  String get welcome;

  String get manage_your_agricultural_business;

  String get quick_actions;

  String get track_market_trends;

  String get chat_with_buyers;

  String get add_new_products;

  String get browse_crops;

  String get change_your_language_here;

  String get see_your_profile_details;

  String get privacy_policy;

  String get change_privacy_security_settings;

  String get phone;

  String get email;

  String get cart_items;

  String get sign_out;

  String get vegetable_analysis;

  String get current_price;

  String get predicted_price;

  String get market_demand;

  String get demand_is_high;

  String get demand_is_low;

  String get price_trends;

  String get change;

  String get select_date_to_view_price;

  String get select_your_language;

  String get all_messages;

  String get conversation_count;

  String get select_a_vegetable;

  String get carrot;

  String get tomato;

  String get pumpkin;

  String get lime;

  String get cabbage;

  String get brinjal;

  String get snake_gourd;

  String get green_chilli;

  String get current;

  String get predicted;

  String get price_breakdown;

  String get loading;

  String get how_it_will_change;

  String get crop_details;

  String get my_listed_crops;

  String get You_havent_listed_any_crops_yet;

  String get list_a_crop;

  String get your_cart_is_empty;

  String get looks_like_you_havent_added_any_items_to_your_cart_yet;

  String get browse_products;

  String get my_cart;

  String get proceed_to_checkout;

  String get total;

  String get clear_all;

  String get items;

  String get confirm_order;

  String get are_you_sure_you_want_to_place_this_order;

  String get confirm;

  String get cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
