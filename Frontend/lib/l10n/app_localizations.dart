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

  /// No description provided for @change_your_language_here.
  ///
  /// In en, this message translates to:
  /// **'Change your language here'**
  String get change_your_language_here;

  /// No description provided for @privacy_security.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
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

}


class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'market'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'profile'**
  String get profile;

  /// No description provided for @track_market_trends.
  ///
  /// In en, this message translates to:
  /// **'Track market trends'**
  String get track_market_trends;

  /// No description provided for @chat_with_buyers.
  ///
  /// In en, this message translates to:
  /// **'Chat with buyers'**
  String get chat_with_buyers;

  /// No description provided for @add_new_products.
  ///
  /// In en, this message translates to:
  /// **'Add new products'**
  String get add_new_products;

  /// No description provided for @browse_crops.
  ///
  /// In en, this message translates to:
  /// **'Browse crops'**
  String get browse_crops;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'welcome'**
  String get welcome;

  /// No description provided for @manage_your_agricultural_business.
  ///
  /// In en, this message translates to:
  /// **'Manage your agricultural business'**
  String get manage_your_agricultural_business;

  /// No description provided for @manage_your_agricultural_business.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quick_actions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @see_your_profile_details.
  ///
  /// In en, this message translates to:
  /// **'See your profile details'**
  String get see_your_profile_details;

  /// No description provided for @choose_your_preffered_language.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choose_your_preffered_language;

  /// No description provided for @checkout_our_policy_details.
  ///
  /// In en, this message translates to:
  /// **'Checkout our policy details'**
  String get checkout_our_policy_details;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @cart_items.
  ///
  /// In en, this message translates to:
  /// **'Cart_items'**
  String get cart_items;

  /// No description provided for @Items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @select_your_language.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get select_your_language;

  /// No description provided for @Farm Statistics.
  ///
  /// In en, this message translates to:
  /// **'Farm Statistics'**
  String get farm_statistics;

  /// No description provided for @Total Crops.
  ///
  /// In en, this message translates to:
  /// **'Total Crops'**
  String get total_crops;

  /// No description provided for @list_new_crop.
  ///
  /// In en, this message translates to:
  /// **'List new crop'**
  String get list_new_crop;

  /// No description provided for @crop_photos.
  ///
  /// In en, this message translates to:
  /// **'Crop Photos'**
  String get crop_photos;

  /// No description provided for @add_upto_3_photos.
  ///
  /// In en, this message translates to:
  /// **'Add upto 3 photos'**
  String get add_upto_3_photos;

  /// No description provided for @tap_to_add_photos.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photos'**
  String get tap_to_add_photos;

  /// No description provided for @add_clear_photos.
  ///
  /// In en, this message translates to:
  /// **'Add clear, well-lit photos'**
  String get add_clear_photos;

  /// No description provided for @organic_tomatoes.
  ///
  /// In en, this message translates to:
  /// **'Organic Tomatoes'**
  String get organic_tomatoes;

  /// No description provided for @describe_your_crop.
  ///
  /// In en, this message translates to:
  /// **'Describe your crop quality, variety, etc.'**
  String get describe_your_crop;

  /// No description provided for @per_kg.
  ///
  /// In en, this message translates to:
  /// **'per kg'**
  String get per_kg;

  /// No description provided for @available_kg.
  ///
  /// In en, this message translates to:
  /// **'Available kg'**
  String get available_kg;

  /// No description provided for @crop_location.
  ///
  /// In en, this message translates to:
  /// **'Where is your crop located?'**
  String get crop_location;

  /// No description provided for @crop_harvest_date.
  ///
  /// In en, this message translates to:
  /// **'When was the crop harvested?'**
  String get crop_harvest_date;

  /// No description provided for @listing_crop.
  ///
  /// In en, this message translates to:
  /// **'Listing crop...'**
  String get listing_crop;

  /// No description provided for @total_quantity.
  ///
  /// In en, this message translates to:
  /// **'total_quantity...'**
  String get total_quantity;

  /// No description provided for @total_value
  ///
  /// In en, this message translates to:
  /// **'total_value...'**
  String get total_value;

  /// No description provided for @avg_price
  ///
  /// In en, this message translates to:
  /// **'avg_price...'**
  String get avg_price;

  /// No description provided for @active_crops
  ///
  /// In en, this message translates to:
  /// **'active_crops...'**
  String get active_crops;

  /// No description provided for @crops_with_interest
  ///
  /// In en, this message translates to:
  /// **'crops_with_interest...'**
  String get crops_with_interest;

  /// No description provided for @conversations
  ///
  /// In en, this message translates to:
  /// **'conversations'**
  String get conversations;
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
