/// Functions used to fetch data in future builders.
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2023-11-01 08:26:39 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:communitypod/common/rest_api/file_helper.dart';
import 'package:communitypod/models/call_status.dart';
import 'package:communitypod/models/news.dart';
import 'package:communitypod/models/news_content.dart';
import 'package:communitypod/models/news_call_result.dart';
import 'package:communitypod/models/selected_news.dart';
import 'package:communitypod/utils/turtle/note_serializer.dart';

/// Get the list of user's news objects.
///
/// Example:
/// - `_asyncDataFetch = getOwnNewsList()`
/// - used to define async function in future call to get user's news objects.
///
/// Returns: [NewsCallResult] object comprising:
/// - [news] - list of [News] news objects.
/// - [unparseableNews] - list of [SelectedNews] objects of
/// unparseable news files.

Future<NewsCallResult> getOwnNewsList() async {
  try {
    final startTime = DateTime.now();

    final List<String> fileList;
    final List<News> news = [];
    final List<SelectedNews> unparseableNews = [];

    // Get news file owner
    final String newsOwner = await getWebId() ?? '';

    // Get file list in owner's Pod
    fileList = await NewsFileHelper().scanFileListDirectory();

    // Create a list of future functions for reading pod and
    // getting fileUrl
    List<Future<String>> futuresFileUrl = [];
    List<Future<String>> futuresNewsContentResult = [];
    for (final fileName in fileList) {
      futuresFileUrl.add(
        filenameToResourceUrl(
          fileName: fileName,
        ),
      );
      futuresNewsContentResult.add(
        readPod(fileName),
      );
    }

    // Read news file content and fetch file Urls
    List<String> fileUrls = await Future.wait(futuresFileUrl);
    List<String> newsContentResults =
        await Future.wait(futuresNewsContentResult);

    // Retrieve news file data
    for (int i = 0; i < fileList.length; i++) {
      // Extract ttl data to content data of news object
      if (newsContentResults[i].isNotEmpty) {
        try {
          // Extract news object from news file turtle string
          final NewsContent? content;
          content = TurtleSerializer.newsFromTurtle(
            newsContentResults[i],
          );

          if (content != null) {
            // Add news file content data to news objects list
            // where user = newsOwner
            news.add(
              News(
                newsFileName: fileList[i],
                newsUrl: fileUrls[i],
                newsOwner: newsOwner,
                content: content,
                permissionList: 'append,read,write,control',
              ),
            );
          } else {
            // Found unparseable file content
            // Add news files that failed parsing to bad news list
            unparseableNews.add(
              SelectedNews(
                newsFileName: fileList[i],
                newsUrl: fileUrls[i],
                newsOwner: newsOwner,
              ),
            );
            debugPrint('Found unparseable file: ${fileList[i]}');
          }
        } catch (e) {
          // Error deserializing news file content
          debugPrint(e.toString());
        }
      } else {
        // If empty, add to unparseable file object list
        unparseableNews.add(
          SelectedNews(
            newsFileName: fileList[i],
            newsUrl: fileUrls[i],
            newsOwner: newsOwner,
          ),
        );
        debugPrint('Found empty file: ${fileList[i]}');
      }
    }

    if (unparseableNews.isNotEmpty) {
      debugPrint('Found ${unparseableNews.length} unparseable or empty files');
    } else {
      debugPrint('All owners files parsed successfully!');
    }

    // Fetch permission lists of who each news file is shared with
    try {
      final List<News> fullNews;
      final NewsCallResult results;

      final List<String> fileList =
          news.map((newsPost) => newsPost.newsFileName).toList();

      final Map<dynamic, dynamic> permissionMaps = await readPermissionFileList(
        fileList: fileList,
      );

      fullNews = news.addAuthUserLists(permissionMaps: permissionMaps);

      results = NewsCallResult(
        news: fullNews,
        unparseableNews: unparseableNews,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint('[getOwnNewsList] Load time: ${duration.inMilliseconds} ms');

      return results;
    } catch (e) {
      // Error retrieving permission lists of each news file
      debugPrint(e.toString());
      rethrow;
    }
  } catch (e) {
    // Error finding files
    debugPrint(e.toString());
    rethrow;
  }
}

/// Get data object of externally owned news shared with the user.
///
/// Arguments:
/// - [hasCurrentAccess] - Flag describing whether user has current
/// access (ie. not revoked) to external file. If false, all files
/// which the user has or has previously been granted access will be returned. (Default: true, ie. only returns list of external news
/// that user has current access to.
///
/// Returns: [NewsCallResult] object comprising:
/// - [news] - list of [News] news file objects.
/// - [unparseableNews] - list of [SelectedNews] objects of
/// unparseable news.
/// - [nonExistentNews] - list of non-existent [News] news
/// objects, if external files were deleted by their owner without
/// first revoking access to the user (and other recipients).

Future<NewsCallResult> getExternalNewsList({
  bool hasCurrentAccess = true,
}) async {
  final startTime = DateTime.now();

  final List<News> news = [];
  // Build list of external news shared to user

  final Map<dynamic, dynamic> externalNewsLog;

  externalNewsLog = await NewsFileHelper().scanPermLogFile();

  List<String> unparseableLogRecords = [];

  if (externalNewsLog.isNotEmpty) {
    for (final fileUrl in externalNewsLog.keys) {
      // Each log record of an external file
      final Map<PermissionLogLiteral, dynamic> logRecordOfFile =
          externalNewsLog[fileUrl] as Map<PermissionLogLiteral, dynamic>;

      // Ignore log records of files where access has been
      // revoked
      if (hasCurrentAccess &&
          logRecordOfFile[PermissionLogLiteral.type] == 'revoke') {
        continue;
      }

      // Deserialise external news log record
      try {
        final News? newsPost;

        // Extract log record of each external news file
        // where user currently has access
        // Applies isExternalRes == true to loaded news
        newsPost = NewsFileHelper.extFileDetailsFromLog(
          logRecordOfFile: logRecordOfFile,
          fileUrl: fileUrl,
        );

        if (newsPost != null) {
          // Add log details of news post to ExternalNews objects list
          news.add(newsPost);
        } else {
          // Found unparseable log record
          // Add to unparseable news list
          unparseableLogRecords.add(fileUrl);
        }
      } catch (e) {
        // Error deserializing external news file log record
        debugPrint(e.toString());
      }
    }
  }

  if (unparseableLogRecords.isNotEmpty) {
    debugPrint(
      'Found external files with unparseable log records: $unparseableLogRecords',
    );
  } else {
    debugPrint('All log records of external file parsed successfully!');
  }

  // Fetch and deserialize external news file content
  // or count bad files according to error type
  try {
    final List<News> fullNews = [];
    final List<News> nonExistentNews = [];
    final List<SelectedNews> unparseableNews = [];
    final NewsCallResult results;

    if (news.isNotEmpty) {
      // Create a list of future functions for reading external Pods
      List<Future<dynamic>> futuresExtNewsContentResult = [];
      for (final newsPost in news) {
        futuresExtNewsContentResult.add(
          getExternalNewsContent(
            newsPost: newsPost,
          ),
        );
      }

      List<dynamic> extNewsWithContentResults =
          await Future.wait(futuresExtNewsContentResult);

      // Retrieve news file data
      for (int i = 0; i < news.length; i++) {
        if (extNewsWithContentResults[i] ==
            FileCallStatus.fileAccessForbidden) {
          // Files with access forbidden have news file with default null content
          fullNews.add(news[i]);
        } else if (extNewsWithContentResults[i] == FileCallStatus.parsingFail) {
          unparseableNews.add(
            SelectedNews(
              newsFileName: news[i].newsFileName,
              newsUrl: news[i].newsUrl,
              newsOwner: news[i].newsOwner,
            ),
          );
        } else if (extNewsWithContentResults[i] ==
            FileCallStatus.fileNotExists) {
          nonExistentNews.add(news[i]);
        } else if (extNewsWithContentResults[i] != null) {
          // Add news object content data to news objects list
          fullNews.add(extNewsWithContentResults[i]);
        }
      }
    }

    results = NewsCallResult(
      news: fullNews,
      nonExistentNews: nonExistentNews,
      unparseableNews: unparseableNews,
    );

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    debugPrint(
      '[getExternalNewsList] Load time: ${duration.inMilliseconds} ms',
    );

    return results;
  } catch (e) {
    // Error finding files
    debugPrint(e.toString());
    rethrow;
  }
}

/// Get the content of an externally owned news files shared with the user.
///
/// Arguments:
/// - [newsPost] - The externally owned news data object including metadata.
///
/// Returns: [FileCallStatus] object comprising one of:
/// - [news] - [News] news object containing news content.
/// - [FileCallStatus] - where [FileCallStatus] captures read failures
/// including [FileCallStatus.fileNotExists] and
/// [FileCallStatus.parsingFail].

Future<dynamic> getExternalNewsContent({
  required News newsPost,
}) async {
  try {
    // Check permissions include read
    if (!newsPost.permissionList.contains('read')) {
      return FileCallStatus.fileAccessForbidden;
    }

    // Get decrypted news object content from external file
    final newsContentResult = await readExternalPod(
      newsPost.newsUrl,
    );

    // Extract external news file ttl data to newsContent
    try {
      // Deserialize news file content
      final NewsContent? content;
      content = TurtleSerializer.newsFromTurtle(newsContentResult);

      if (content != null) {
        // Add news file content data to external news object
        newsPost.content = content;
        return newsPost;
      } else {
        // Found external news file with unparseable news content
        return FileCallStatus.parsingFail;
      }
    } catch (e) {
      // Error deserializing news file
      debugPrint(e.toString());
      return FileCallStatus.parsingFail;
    }
  } on ResourceNotExistException catch (e) {
    // File does not exist on the POD
    debugPrint('Resource not found: $e');
    return FileCallStatus.fileNotExists;
  } on Object catch (e) {
    debugPrint('Exception details: $e');
    rethrow;
  }
}
