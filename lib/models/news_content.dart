/// Data models for notes
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Thursday 2026-03-13 17:53:12 +1100 Graham Williams>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Jess Moore

library;

import 'package:solidpod/solidpod.dart';

import 'package:communitypod/constants/turtle_structures.dart';

/// Base data model for the text content object within a news object

class NewsContent {
  final String newsTitle;
  final String createdDateTime;
  final String modifiedDateTime;
  final String newsContent;
  final List<String> authUsers;

  const NewsContent({
    required this.newsTitle,
    required this.createdDateTime,
    required this.modifiedDateTime,
    required this.newsContent,
    this.authUsers = const [],
  });

  /// Method to create NewsContent object from json data map

  factory NewsContent.fromJson(Map<String, dynamic> json) {
    return NewsContent(
      newsTitle: json[newsTitlePred] as String,
      createdDateTime: json[createdDateTimePred] as String,
      modifiedDateTime: json[modifiedDateTimePred] as String,
      newsContent: json[newsContentPred] as String,
      authUsers: (json[authUserPred] as Map).keys.toList().cast<String>(),
    );
  }

  /// Method to export NewsContent object to json data map

  Map<String, dynamic> toJson() => {
        newsTitlePred: newsTitle,
        createdDateTimePred: createdDateTime,
        modifiedDateTimePred: modifiedDateTime,
        newsContentPred: newsContent,
        authUserPred: authUsers,
      };

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  NewsContent copyWith({
    String? newsTitle,
    String? createdDateTime,
    String? modifiedDateTime,
    String? newsContent,
    List<String>? authUsers,
  }) {
    return NewsContent(
      newsTitle: newsTitle ?? this.newsTitle,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      modifiedDateTime: modifiedDateTime ?? this.modifiedDateTime,
      newsContent: newsContent ?? this.newsContent,
      authUsers: authUsers ?? this.authUsers,
    );
  }

  /// Returns the URL of the first markdown image in [newsContent], or null
  /// if the note contains no images.

  String? get highlightImageUrl {
    final match = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(newsContent);
    return match?.group(1);
  }

  /// Returns [newsContent] with all markdown image tags removed,
  /// surrounding whitespace trimmed, and empty lines removed.

  String get contentWithoutImages => newsContent
      .split('\n')
      .map((line) => line.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '').trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
}
