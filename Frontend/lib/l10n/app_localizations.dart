import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart'; // Ensure this file exists and defines the AppLocalizationsSi class
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
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

  /// No description provided for @personal_information.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_information;

  String get Edit_Profile;

  String get update_your_information;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Farmer/Buyer'**
  String get role;

  String get no;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  String get exit_app;

  String get yes;

  String get are_you_sure_you_want_to_exit;

  /// No description provided for @choose_an_option.
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get choose_an_option;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @crop_listed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Your crop has been listed successfully!'**
  String get crop_listed_successfully;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @add_at_least_one_photo.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one photo of your crop'**
  String get add_at_least_one_photo;

  /// No description provided for @auth_token_not_found.
  ///
  /// In en, this message translates to:
  /// **'Authentication token not found. Please login again.'**
  String get auth_token_not_found;

  String get messages;

  /// No description provided for @an_error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get an_error_occurred;

  /// No description provided for @list_crop.
  ///
  /// In en, this message translates to:
  /// **'List Crop'**
  String get list_crop;

  /// No description provided for @add_photos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get add_photos;

  /// No description provided for @listing_details.
  ///
  /// In en, this message translates to:
  /// **'Listing Details'**
  String get listing_details;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enter_crop_name.
  ///
  /// In en, this message translates to:
  /// **'Enter crop name'**
  String get enter_crop_name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enter_description.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enter_description;

  /// No description provided for @price_lkr.
  ///
  /// In en, this message translates to:
  /// **'Price (LKR)'**
  String get price_lkr;

  /// No description provided for @enter_price.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enter_price;

  /// No description provided for @enter_valid_price.
  ///
  /// In en, this message translates to:
  /// **'Enter valid price'**
  String get enter_valid_price;

  /// No description provided for @select_location.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get select_location;

  /// No description provided for @quantity_kg.
  ///
  /// In en, this message translates to:
  /// **'Quantity (KG)'**
  String get quantity_kg;

  /// No description provided for @enter_quantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enter_quantity;

  /// No description provided for @enter_valid_quantity.
  ///
  /// In en, this message translates to:
  /// **'Enter valid quantity'**
  String get enter_valid_quantity;

  /// No description provided for @harvest_date.
  ///
  /// In en, this message translates to:
  /// **'Harvest Date'**
  String get harvest_date;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get select_date;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @harvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get harvest;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @about_this_product.
  ///
  /// In en, this message translates to:
  /// **'About this Product'**
  String get about_this_product;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @available_quantity.
  ///
  /// In en, this message translates to:
  /// **'Available Quantity'**
  String get available_quantity;

  /// No description provided for @add_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get add_to_cart;

  /// No description provided for @chat_with_seller.
  ///
  /// In en, this message translates to:
  /// **'Chat with Seller'**
  String get chat_with_seller;

  /// No description provided for @call_instead.
  ///
  /// In en, this message translates to:
  /// **'Call Instead'**
  String get call_instead;

  /// No description provided for @comment_.
  ///
  /// In en, this message translates to:
  /// **'texts for settings_main_page,dart'**
  String get comment_;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @market_prices.
  ///
  /// In en, this message translates to:
  /// **'Market\nPrices'**
  String get market_prices;

  /// No description provided for @negotiations.
  ///
  /// In en, this message translates to:
  /// **'Negotiations'**
  String get negotiations;

  /// No description provided for @market_place.
  ///
  /// In en, this message translates to:
  /// **'Market\nPlace'**
  String get market_place;

  /// No description provided for @your_account_information.
  ///
  /// In en, this message translates to:
  /// **'Your account information'**
  String get your_account_information;

  /// No description provided for @password_and_account.
  ///
  /// In en, this message translates to:
  /// **'Password and account'**
  String get password_and_account;

  /// No description provided for @language_settings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
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

  /// No description provided for @change_your_language_here.
  ///
  /// In en, this message translates to:
  /// **'Change your language here'**
  String get change_your_language_here;

  String get see_your_profile_details;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Policy'**
  String get privacy_policy;

  /// No description provided for @change_privacy_security_settings.
  ///
  /// In en, this message translates to:
  /// **'Change your privacy & security settings'**
  String get change_privacy_security_settings;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**

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

  ///No description provided for @all_messages
  ///
  /// In en, this message translates to:
  /// **'All Messages'**
  String get all_messages;

  /// No description provided for @conversations_count.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
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
