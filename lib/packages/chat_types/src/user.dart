import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'util.dart' show getRoleFromString;

/// All possible roles user can have.
enum Role { admin, agent, moderator, user }

/// Extension with one [toShortString] method
extension RoleToShortString on Role {
  /// Converts enum to the string equal to enum's name
  String toShortString() {
    return toString().split('.').last;
  }
}

/// A class that represents user.
@immutable
class User extends Equatable {
  /// Creates a user.
  User({
    this.createdAt,
    this.firstName,
    required this.id,
    this.imageUrl,
    this.lastName,
    this.lastSeen,
    this.metadata,
    this.role,
    this.updatedAt,
  });

  /// Creates user from a map (decoded JSON).
  static User fromJson(dynamic json) {
    try {
      User user = User(
        createdAt: json['createdAt'],
        firstName: json['firstName'] ?? "",
        id: json['id']?.toString() ?? '',
        imageUrl: json['imageUrl'] as String?,
        lastName: json['lastName'] ?? "",
        lastSeen: json['lastSeen'],
        metadata: json['metadata'],
        role: getRoleFromString(json['role'] ?? ""),
        updatedAt: json['updatedAt'],
      );
      return user;
    } catch (e) {
      log("User.fromJson: $e");
      return User(id: "deleted_user", firstName: "Deleted User", lastName: "");
    }
  }

  /// Converts user to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => {
        'createdAt': createdAt?.toString(),
        'firstName': firstName,
        'id': id,
        'imageUrl': imageUrl,
        'lastName': lastName,
        'lastSeen': lastSeen,
        'metadata': metadata,
        'role': role?.toShortString(),
        'updatedAt': updatedAt?.toString(),
      };

  /// Creates a copy of the user with an updated data.
  /// [firstName], [imageUrl], [lastName], [lastSeen], [role] and [updatedAt]
  /// with null values will nullify existing values.
  /// [metadata] with null value will nullify existing metadata, otherwise
  /// both metadatas will be merged into one Map, where keys from a passed
  /// metadata will overwite keys from the previous one.
  User copyWith({
    String? firstName,
    String? imageUrl,
    String? lastName,
    int? lastSeen,
    Map<String, dynamic>? metadata,
    Role? role,
    dynamic updatedAt,
  }) {
    return User(
      firstName: firstName,
      id: id,
      imageUrl: imageUrl,
      lastName: lastName,
      lastSeen: lastSeen,
      metadata: metadata == null
          ? null
          : {
              ...this.metadata ?? {},
              ...metadata,
            },
      role: role,
      updatedAt: updatedAt,
    );
  }

  /// Equatable props
  @override
  List<Object?> get props => [createdAt, firstName, id, imageUrl, lastName, lastSeen, metadata, role, updatedAt];

  /// Created user timestamp, in ms
  final dynamic createdAt;

  /// First name of the user
  final String? firstName;

  /// Unique ID of the user
  String id;

  /// Remote image URL representing user's avatar
  final String? imageUrl;

  /// Last name of the user
  final String? lastName;

  /// Timestamp when user was last visible, in ms
  final dynamic lastSeen;

  /// Additional custom metadata or attributes related to the user
  final Map<String, dynamic>? metadata;

  /// User [Role]
  final Role? role;

  /// Updated user timestamp, in ms
  final dynamic updatedAt;
}
