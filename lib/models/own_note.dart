/// Data models for user's news
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Thursday 2025-10-02 17:53:12 +1100 Graham Williams>
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
import 'package:communitypod/models/note_content.dart';

/// Data model for user's note

class OwnNews {
  final String newsFileName;
  final String newsUrl;
  final String newsOwner;
  NewsContent? content;
  final Map<dynamic, dynamic>? authUserList;

  OwnNews({
    required this.newsFileName,
    required this.newsUrl,
    required this.newsOwner,
    this.content,
    this.authUserList,
  });

  factory OwnNews.fromJson(Map<String, dynamic> json) {
    return OwnNews(
      newsFileName: json[newsFileNamePred],
      newsUrl: json[newsUrlPred],
      newsOwner: json[newsOwnerPred],
      content: json[contentPred],
      authUserList: json[authUserPred],
    );
  }

  Map<String, dynamic> toJson() => {
        newsFileNamePred: newsFileName,
        newsUrlPred: newsUrl,
        newsOwnerPred: newsOwner,
        contentPred: content,
        authUserPred: authUserList,
      };

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  OwnNews copyWith({
    String? newsFileName,
    String? newsUrl,
    String? newsOwner,
    NewsContent? content,
    Map<dynamic, dynamic>? authUserList,
  }) {
    return OwnNews(
      newsFileName: newsFileName ?? this.newsFileName,
      newsUrl: newsUrl ?? this.newsUrl,
      newsOwner: newsOwner ?? this.newsOwner,
      content: content ?? this.content,
      authUserList: authUserList ?? this.authUserList,
    );
  }
}
