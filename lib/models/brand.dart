import 'package:json_annotation/json_annotation.dart';

part 'brand.g.dart';

enum BrandType {
  home,
  normal,
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Brand {
  final int id;
  final BrandType type;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(defaultValue: '')
  final String slug;

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(defaultValue: '')
  final String abbreviation;

  @JsonKey(defaultValue: '')
  final String about;

  @JsonKey(defaultValue: '')
  final String username;

  @JsonKey(defaultValue: '')
  final String availability;

  final bool delivery;
  final bool dineIn;
  final bool takeAway;
  final bool isActive;

  final int minDeliveryTime;
  final int maxDeliveryTime;

  final int? pickupWindow;
  final String? phoneNumber;

  final String? secondaryColour;
  final String? backgroundColour;
  final String? foregroundColour;

  final String? logo;
  final String? thumbnail;
  final String? menuItemPlaceholder;
  final String? media;

  final String? openingHours;

  final String? url;
  final String? contactEmail;

  final String? whatsappAccount;
  final String? instagramAccount;
  final String? facebookAccount;
  final String? linkedinAccount;
  final String? youtubeAccount;
  final String? twitterAccount;

  final String? facebookName;
  final String? twitterName;
  final String? linkedinName;
  final String? youtubeName;
  final String? instagramName;

  final List<String> tags;
  final bool allowDateSelection;

  @JsonKey(defaultValue: '')
  final String uen;

  @JsonKey(defaultValue: '')
  final String entityName;

  @JsonKey(defaultValue: '')
  final String currency;

  @JsonKey(defaultValue: '')
  final String holderName;

  @JsonKey(defaultValue: '')
  final String bankName;

  @JsonKey(defaultValue: '')
  final String accountNumber;

  @JsonKey(defaultValue: '')
  final String termAndCondition;

  @JsonKey(defaultValue: '')
  final String frequencyPayout;

  final bool isRegisteredEntity;

  @JsonKey(name: 'users', defaultValue: [])
  final List<int> userIds;

  Brand({
    required this.id,
    required this.type,
    required this.name,
    required this.slug,
    required this.description,
    required this.abbreviation,
    required this.about,
    required this.delivery,
    required this.dineIn,
    required this.takeAway,
    required this.isActive,
    required this.minDeliveryTime,
    required this.maxDeliveryTime,
    required this.username,
    required this.availability,
    this.pickupWindow,
    this.phoneNumber,
    this.secondaryColour,
    this.backgroundColour,
    this.foregroundColour,
    this.logo,
    this.thumbnail,
    this.menuItemPlaceholder,
    this.media,
    this.openingHours,
    this.url,
    this.contactEmail,
    this.whatsappAccount,
    this.instagramAccount,
    this.facebookAccount,
    this.linkedinAccount,
    this.youtubeAccount,
    this.twitterAccount,
    this.facebookName,
    this.twitterName,
    this.linkedinName,
    this.youtubeName,
    this.instagramName,
    required this.tags,
    required this.allowDateSelection,
    required this.uen,
    required this.entityName,
    required this.currency,
    required this.holderName,
    required this.bankName,
    required this.accountNumber,
    required this.termAndCondition,
    required this.frequencyPayout,
    required this.isRegisteredEntity,
    required this.userIds,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);
  Map<String, dynamic> toJson() => _$BrandToJson(this);

  @override
  String toString() {
    return '$runtimeType: $id $name';
  }

  String get idStr {
    return id.toString();
  }
}
