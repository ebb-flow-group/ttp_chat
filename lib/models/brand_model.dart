import 'enum_decode.dart';

enum BrandType {
  home,
  normal,
}

class Brand {
  final int id;
  final BrandType type;

  final String name;

  final String slug;

  final String description;

  final String abbreviation;

  final String about;

  final String username;

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

Brand _$BrandFromJson(Map<String, dynamic> json) => Brand(
      id: json['id'] as int,
      type: $enumDecode(_$BrandTypeEnumMap, json['type']),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      abbreviation: json['abbreviation'] as String? ?? '',
      about: json['about'] as String? ?? '',
      delivery: json['delivery'] as bool,
      dineIn: json['dine_in'] as bool,
      takeAway: json['take_away'] as bool,
      isActive: json['is_active'] as bool,
      minDeliveryTime: json['min_delivery_time'] as int,
      maxDeliveryTime: json['max_delivery_time'] as int,
      username: json['username'] as String? ?? '',
      availability: json['availability'] as String? ?? '',
      pickupWindow: json['pickup_window'] as int?,
      phoneNumber: json['phone_number'] as String?,
      secondaryColour: json['secondary_colour'] as String?,
      backgroundColour: json['background_colour'] as String?,
      foregroundColour: json['foreground_colour'] as String?,
      logo: json['logo'] as String?,
      thumbnail: json['thumbnail'] as String?,
      menuItemPlaceholder: json['menu_item_placeholder'] as String?,
      media: json['media'] as String?,
      openingHours: json['opening_hours'] as String?,
      url: json['url'] as String?,
      contactEmail: json['contact_email'] as String?,
      whatsappAccount: json['whatsapp_account'] as String?,
      instagramAccount: json['instagram_account'] as String?,
      facebookAccount: json['facebook_account'] as String?,
      linkedinAccount: json['linkedin_account'] as String?,
      youtubeAccount: json['youtube_account'] as String?,
      twitterAccount: json['twitter_account'] as String?,
      facebookName: json['facebook_name'] as String?,
      twitterName: json['twitter_name'] as String?,
      linkedinName: json['linkedin_name'] as String?,
      youtubeName: json['youtube_name'] as String?,
      instagramName: json['instagram_name'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$BrandToJson(Brand instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$BrandTypeEnumMap[instance.type],
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'abbreviation': instance.abbreviation,
      'about': instance.about,
      'username': instance.username,
      'availability': instance.availability,
      'delivery': instance.delivery,
      'dine_in': instance.dineIn,
      'take_away': instance.takeAway,
      'is_active': instance.isActive,
      'min_delivery_time': instance.minDeliveryTime,
      'max_delivery_time': instance.maxDeliveryTime,
      'pickup_window': instance.pickupWindow,
      'phone_number': instance.phoneNumber,
      'secondary_colour': instance.secondaryColour,
      'background_colour': instance.backgroundColour,
      'foreground_colour': instance.foregroundColour,
      'logo': instance.logo,
      'thumbnail': instance.thumbnail,
      'menu_item_placeholder': instance.menuItemPlaceholder,
      'media': instance.media,
      'opening_hours': instance.openingHours,
      'url': instance.url,
      'contact_email': instance.contactEmail,
      'whatsapp_account': instance.whatsappAccount,
      'instagram_account': instance.instagramAccount,
      'facebook_account': instance.facebookAccount,
      'linkedin_account': instance.linkedinAccount,
      'youtube_account': instance.youtubeAccount,
      'twitter_account': instance.twitterAccount,
      'facebook_name': instance.facebookName,
      'twitter_name': instance.twitterName,
      'linkedin_name': instance.linkedinName,
      'youtube_name': instance.youtubeName,
      'instagram_name': instance.instagramName,
      'tags': instance.tags,
    };

const _$BrandTypeEnumMap = {
  BrandType.home: 'home',
  BrandType.normal: 'normal',
};
