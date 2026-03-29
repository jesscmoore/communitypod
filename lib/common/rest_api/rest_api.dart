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
import 'package:communitypod/models/note.dart';
import 'package:communitypod/models/note_content.dart';
import 'package:communitypod/models/notes_call_result.dart';
import 'package:communitypod/models/selected_note.dart';
import 'package:communitypod/utils/turtle/note_serializer.dart';

/// Get the list of user's note objects.
///
/// Example:
/// - `_asyncDataFetch = getOwnNewsList()`
/// - used to define async function in future call to get user's notes.
///
/// Returns: [NewsCallResult] object comprising:
/// - [notes] - list of [News] note objects.
/// - [unparseableNews] - list of [SelectedNews] objects of
/// unparseable notes.

Future<NewsCallResult> getOwnNewsList() async {
  try {
    final startTime = DateTime.now();

    final List<String> fileList;
    final List<News> notes = [];
    final List<SelectedNews> unparseableNews = [];

    // Get note owner
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

    // Read note file content and fetch file Urls
    List<String> fileUrls = await Future.wait(futuresFileUrl);
    List<String> newsContentResults =
        await Future.wait(futuresNewsContentResult);

    // Retrieve note data
    for (int i = 0; i < fileList.length; i++) {
      // Extract ttl data to content data of notes object
      if (newsContentResults[i].isNotEmpty) {
        try {
          // Extract note from turtle string
          final NewsContent? content;
          content = TurtleSerializer.noteFromTurtle(
            newsContentResults[i],
          );

          if (content != null) {
            // Add note content data to note objects list
            // where user = newsOwner
            notes.add(
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
            // Add note that failed parsing to bad notes list
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
          // Error deserializing note content
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

    // Fetch permission lists of who each note is shared with
    try {
      final List<News> fullNews;
      final NewsCallResult results;

      final List<String> fileList =
          notes.map((note) => note.newsFileName).toList();

      final Map<dynamic, dynamic> permissionMaps = await readPermissionFileList(
        fileList: fileList,
      );

      fullNews = notes.addAuthUserLists(permissionMaps: permissionMaps);

      results = NewsCallResult(
        news: fullNews,
        unparseableNews: unparseableNews,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint('[getOwnNewsList] Load time: ${duration.inMilliseconds} ms');

      return results;
    } catch (e) {
      // Error retrieving permission lists of each note
      debugPrint(e.toString());
      rethrow;
    }
  } catch (e) {
    // Error finding files
    debugPrint(e.toString());
    rethrow;
  }
}

/// Get data object of externally owned notes shared with the user.
///
/// Arguments:
/// - [hasCurrentAccess] - Flag describing whether user has current
/// access (ie. not revoked) to external file. If false, all files
/// which the user has or has previously been granted access will be returned. (Default: true, ie. only returns list of external notes
/// that user has current access to.
///
/// Returns: [NewsCallResult] object comprising:
/// - [notes] - list of [News] note objects.
/// - [unparseableNews] - list of [SelectedNews] objects of
/// unparseable notes.
/// - [nonExistentNews] - list of non-existent [News] note
/// objects, if external files were deleted by their owner without
/// first revoking access to the user (and other recipients).

Future<NewsCallResult> getExternalNewsList({
  bool hasCurrentAccess = true,
}) async {
  final startTime = DateTime.now();

  final List<News> notes = [];
  // Build list of external notes shared to user

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

      // Deserialise external note log record
      try {
        final News? note;

        // Extract log record of each external note
        // where user currently has access
        // Applies isExternalRes == true to loaded notes
        note = NewsFileHelper.extFileDetailsFromLog(
          logRecordOfFile: logRecordOfFile,
          fileUrl: fileUrl,
        );

        if (note != null) {
          // Add log details of note to ExternalNews objects list
          notes.add(note);
        } else {
          // Found unparseable log record
          // Add to unparseable notes list
          unparseableLogRecords.add(fileUrl);
        }
      } catch (e) {
        // Error deserializing external note log record
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

  // Fetch and deserialize external note content
  // or count bad files according to error type
  try {
    final List<News> fullNews = [];
    final List<News> nonExistentNews = [];
    final List<SelectedNews> unparseableNews = [];
    final NewsCallResult results;

    if (notes.isNotEmpty) {
      // Create a list of future functions for reading external Pods
      List<Future<dynamic>> futuresExtNewsContentResult = [];
      for (final note in notes) {
        futuresExtNewsContentResult.add(
          getExternalNewsContent(
            note: note,
          ),
        );
      }

      List<dynamic> extNewsWithContentResults =
          await Future.wait(futuresExtNewsContentResult);

      // Retrieve note data
      for (int i = 0; i < notes.length; i++) {
        if (extNewsWithContentResults[i] ==
            FileCallStatus.fileAccessForbidden) {
          // Files with access forbidden have note with default null content
          fullNews.add(notes[i]);
        } else if (extNewsWithContentResults[i] == FileCallStatus.parsingFail) {
          unparseableNews.add(
            SelectedNews(
              newsFileName: notes[i].newsFileName,
              newsUrl: notes[i].newsUrl,
              newsOwner: notes[i].newsOwner,
            ),
          );
        } else if (extNewsWithContentResults[i] ==
            FileCallStatus.fileNotExists) {
          nonExistentNews.add(notes[i]);
        } else if (extNewsWithContentResults[i] != null) {
          // Add note content data to note objects list
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

/// Get the content of an externally owned note shared with the user.
///
/// Arguments:
/// - [note] - The externally owned note data object including metadata.
///
/// Returns: [FileCallStatus] object comprising one of:
/// - [note] - [News] note object containing note content.
/// - [FileCallStatus] - where [FileCallStatus] captures read failures
/// including [FileCallStatus.fileNotExists] and
/// [FileCallStatus.parsingFail].

Future<dynamic> getExternalNewsContent({
  required News note,
}) async {
  try {
    // Check permissions include read
    if (!note.permissionList.contains('read')) {
      return FileCallStatus.fileAccessForbidden;
    }

    // Get decrypted note content from external file
    final newsContentResult = await readExternalPod(
      note.newsUrl,
    );

    // Extract external note ttl data to newsContent
    try {
      // Deserialize note content
      final NewsContent? content;
      content = TurtleSerializer.noteFromTurtle(newsContentResult);

      if (content != null) {
        // Add note content data to external notes object
        note.content = content;
        return note;
      } else {
        // Found external note file with unparseable note content
        return FileCallStatus.parsingFail;
      }
    } catch (e) {
      // Error deserializing note
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
