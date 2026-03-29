/// Data models for result of get news future call.
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Monday 2025-10-06 14:42:01 +1100 Graham Williams>
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

import 'package:communitypod/models/news.dart';
import 'package:communitypod/models/selected_news.dart';

/// Data model for result of get news list future call

class NewsCallResult {
  List<News>? news;
  List<SelectedNews>? unparseableNews;
  List<News>? nonExistentNews;

  NewsCallResult({
    this.news = const [],
    this.unparseableNews = const [],
    this.nonExistentNews = const [],
  });
}

/// Extension class for NewsCallResult objects

extension NewsCallResultExtension on NewsCallResult {
  /// Method to add lists within two NewsCallResults objects.
  ///
  /// Arguments:
  /// - [results] - Second news call results object to add to the first news call results object.

  NewsCallResult addCallResults({required NewsCallResult results}) {
    // Initialise combined results object as this first note call results object.
    NewsCallResult combinedResults = NewsCallResult(
      news: news,
      unparseableNews: unparseableNews,
      nonExistentNews: nonExistentNews,
    );

    // Add news lists
    if (results.news!.isNotEmpty) {
      combinedResults.news!.addAll(results.news!);
    }

    // Add unparseableNews lists
    if (results.unparseableNews!.isNotEmpty) {
      combinedResults.unparseableNews!.addAll(results.unparseableNews!);
    }

    // Add nonExistentNews lists
    if (results.nonExistentNews!.isNotEmpty) {
      combinedResults.nonExistentNews!.addAll(results.nonExistentNews!);
    }

    return combinedResults;
  }
}
