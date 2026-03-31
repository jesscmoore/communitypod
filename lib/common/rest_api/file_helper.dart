/// File assistance class
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Friday 2025-10-03 13:56:10 +1100 Graham Williams>
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

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:communitypod/common/rest_api/operations.dart';
import 'package:communitypod/constants/app.dart';
import 'package:communitypod/constants/paths.dart';
import 'package:communitypod/constants/turtle_structures.dart';
import 'package:communitypod/models/news.dart';
import 'package:communitypod/models/news_content.dart';
import 'package:communitypod/news/list_my_news_screen.dart';
import 'package:communitypod/news/view_news.dart';
import 'package:communitypod/utils/encryption.dart';
import 'package:communitypod/widgets/err_dialogs.dart';
import 'package:communitypod/widgets/loading_animation.dart' as loading;

/// Helper class for news file operations.

class NewsFileHelper with PodOperationsMixin {
  NewsFileHelper();

  /// Scans the app directory in pod for news files.
  ///
  /// Arguments: none.
  /// Returns: list of pod owner's files.

  Future<List<String>> scanFileListDirectory() async {
    try {
      final dirUrl = await getDirUrl(basePath);
      final resources = await getResourcesInContainer(dirUrl);

      return resources.files
          .where((f) => f.startsWith(newsFileNamePrefix) && f.endsWith('.ttl'))
          .toList();
    } catch (e) {
      if (!isFileNotFoundError(e) && !isPermissionError(e)) {
        // Error scanning directory.
      }
      return [];
    }
  }

  /// Safely scans the permission log file to retrieve current log entries of external files shared with the user.
  ///
  /// Arguments:
  /// - [context] - The build context.
  /// - [childPage] - The child widget to return to.
  ///
  /// Returns:
  /// - map of external files with filename as key and details of permissions.

  Future<Map<dynamic, dynamic>> scanPermLogFile() async {
    try {
      // SharedResources() parses log ttl to map

      final latestLogMap = await sharedResources();

      if (latestLogMap == SolidFunctionCallStatus.notLoggedIn) {
        // Return empty map if sharedResources() failed login
        return {};
      }

      return latestLogMap;
    } catch (e) {
      if (!isFileNotFoundError(e) && !isPermissionError(e)) {
        // Error reading permission log
      }
      debugPrint('Error: $e');
      rethrow;
    }
  }

  /// Parses external file details from latest log map
  /// entry for news file.
  ///
  /// Arguments:
  /// - [logRecordOfFile] - Log record of the external
  /// news file shared to user.
  /// - [fileUrl] - URL of external file shared to user.
  ///
  /// Returns: parsed map of details of external news file.

  static News? extFileDetailsFromLog({
    required Map logRecordOfFile,
    required String fileUrl,
  }) {
    try {
      String? sharedTime;
      String? newsUrl;
      String? newsFileName;
      String? newsOwner;
      String? permissionGranter;
      String? permissionRecepient;
      String? permissionType;
      String? permissionList;

      // Extract external news file details information

      newsFileName = fileUrl.split('/').last;
      // debugPrint('newsFileName: $newsFileName');

      for (final entry in logRecordOfFile.entries) {
        final predicate = entry.key.toString();
        final value = entry.value.toString();
        // debugPrint('predicate: $predicate, value: $value');

        if (predicate.contains(PermissionLogLiteral.logtime.toString())) {
          sharedTime = value;
        } else if (predicate
            .contains(PermissionLogLiteral.resource.toString())) {
          newsUrl = value;
        } else if (predicate.contains(PermissionLogLiteral.owner.toString())) {
          newsOwner = value;
        } else if (predicate
            .contains(PermissionLogLiteral.granter.toString())) {
          permissionGranter = value;
        } else if (predicate
            .contains(PermissionLogLiteral.recepient.toString())) {
          permissionRecepient = value;
        } else if (predicate.contains(PermissionLogLiteral.type.toString())) {
          permissionType = value;
        } else if (predicate
            .contains(PermissionLogLiteral.permissions.toString())) {
          permissionList = value;
        }
      }

      // Create the external file details object

      return News(
        newsUrl: newsUrl!,
        newsFileName: newsFileName,
        newsOwner: newsOwner!,
        sharedTime: sharedTime!,
        permissionGranter: permissionGranter!,
        permissionRecepient: permissionRecepient!,
        permissionType: permissionType!,
        permissionList: permissionList!,
        isExternalRes: true,
      );
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  /// Safely deletes a news file
  ///
  /// Arguments:
  /// - [context] - The build context.
  /// - [filename] - The news filename. For external news this should be the Url.
  /// - [isExternal] - Boolean describing whether the file is an external file. (Default: false).

  Future<void> deleteNews({
    required BuildContext context,
    required String filename,
    required Widget child,
    bool isExternal = false,
  }) async {
    // Delete file
    if (isExternal) {
      try {
        // Delete external file
        await deleteExternalFile(filename);
      } catch (e) {
        // Error deleting external file
        debugPrint('Error deleting to external file: $e');
        rethrow;
      }
    } else {
      try {
        // Resolve the relative path to a full POD URL before calling
        // deleteFile, which expects an absolute URL.

        final fileUrl = await getFileUrl('$basePath/$filename');
        await deleteFile(fileUrl: fileUrl);
      } catch (e) {
        debugPrint('Error deleting user\'s file: $e');
        rethrow;
      }
    }
  }

  /// Function that starts a waiting indicator, calls steps to save file,
  /// and then navigates to the appropriate return page.
  ///
  /// Examples:
  /// - `await saveNews(context: context, articleController: articleController, formKey: formKey, prevOwnNews: news, isExisting: true)` - to save news file
  /// owned by the user.
  /// - `await saveNews(context: context, articleController: articleController, formKey: formKey, prevExternalNews: news, isExisting: true, isExternal: true)`
  /// - to save an externally owned news file.
  ///
  /// - [context] - The build context.
  /// - [articleController] - Text controller of the news text content editor.
  /// - [formKey] - Key of the form to edit news metadata.
  ///   [scaffoldController] - Controller for the Solid scaffold.
  /// - [prevNews] - Optional existing news data object. Required if isExisting is true.
  /// - [isExternal] - Optional boolean denoting whether news is externally
  /// owned. (Default: false).
  /// - [isExisting] - Optional boolean denoting whether news already
  /// exists. (Default: false).

  Future<void> saveNews({
    required BuildContext context,
    required TextEditingController articleController,
    required GlobalKey<FormBuilderState> formKey,
    required SolidScaffoldController scaffoldController,
    News? prevNews,
    bool isExternal = false,
    bool isExisting = false,
  }) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      // Compares to prevNewsData if previous news data provided
      // Adds sharing metadata if shared==true

      Map formData = formKey.currentState?.value as Map;
      String newsText = articleController.text;
      final String prevNewsTitle;
      final String prevNewsContent;
      final News updatedNews;
      final NewsContent updatedContent;

      // News title need to be spaceless as we are using that name
      // to create a .acl file. And the acl file url cannot have spaces
      String newsTitle = formData[newsTitlePred].replaceAll('\n', '');

      // Get current datetimestamp for mod time and/or creation time
      String modifiedDateTimeStr =
          DateFormat('yyyyMMddTHHmmss').format(DateTime.now()).toString();

      if (isExisting) {
        // Retrieve existing title and content for comparison
        prevNewsTitle = prevNews!.content!.newsTitle;
        prevNewsContent = prevNews.content!.newsContent;
        // Compare updated title and content to existing
        // title and content
        if (newsTitle == prevNewsTitle && newsText == prevNewsContent) {
          showErrDialog(context, ErrMsg.noChanges);
        } else {
          // Loading animation
          loading.showAnimationDialog(
            context,
            Msg.savingNews,
            false,
          );

          // Update content
          try {
            updatedContent = prevNews.content!.copyWith(
              modifiedDateTime: modifiedDateTimeStr,
              newsTitle: newsTitle,
              newsContent: newsText,
            );
            updatedNews = prevNews.copyWith(content: updatedContent);
          } on Exception catch (e) {
            debugPrint(
              'Exception (formatting update to existing news file):\n $e',
            );
            rethrow;
          }

          if (isExternal) {
            // Save external
            try {
              if (!context.mounted) return;

              debugPrint('save external file:');
              debugPrint('newsUrl: ${prevNews.newsUrl}');
              debugPrint('newsFileName: ${prevNews.newsFileName}');
              debugPrint('newsOwner: ${prevNews.newsOwner}');

              // External
              // Encrypt, create TTL, update file in POD
              await saveNewsToPod(
                context: context,
                // Use existing file url
                newsUrl: prevNews.newsUrl,
                newsOwner: prevNews.newsOwner,
                data: updatedContent,
                childPage: ViewNews(
                  newsPost: updatedNews,
                  scaffoldController: scaffoldController,
                ),
                scaffoldController: scaffoldController,
                isExternal: isExternal,
              );
            } on Exception catch (e) {
              debugPrint('Exception (saving existing external file):\n $e');
            }
          } else {
            // Save my news post
            try {
              if (!context.mounted) return;

              // Edited my file
              // Encrypt, create TTL, update file in POD
              await saveNewsToPod(
                context: context,
                // Use existing filename
                newsFileName: prevNews.newsFileName,
                data: updatedContent,
                overwrite: true,
                childPage: ViewNews(
                  newsPost: updatedNews,
                  scaffoldController: scaffoldController,
                ),
                scaffoldController: scaffoldController,
              );
            } on Exception catch (e) {
              debugPrint('Exception (saving existing file owned by me):\n $e');
            }
          }
        }
      } else {
        // Newly created (not editing previous file)

        // Check content is not empty
        if (newsText.trim() != '') {
          try {
            // Loading animation
            loading.showAnimationDialog(
              context,
              Msg.savingNews,
              false,
            );

            // Create new news content data structure
            final newContent = NewsContent(
              createdDateTime: modifiedDateTimeStr,
              modifiedDateTime: modifiedDateTimeStr,
              newsTitle: newsTitle,
              newsContent: newsText,
            );

            // Encrypt, create TTL and write to file in POD
            if (!context.mounted) return;

            await saveNewsToPod(
              context: context,
              // Create filename
              newsFileName: '$newsFileNamePrefix$modifiedDateTimeStr.ttl',
              data: newContent,
              childPage: ListMyNewsScreen(
                scaffoldController: scaffoldController,
              ),
              scaffoldController: scaffoldController,
            );
          } on Exception catch (e) {
            debugPrint('Exception (saving new file owned by me):\n $e');
          }
        } else {
          // No content message
          showErrDialog(context, ErrMsg.noContent);
        }
      }
    } else {
      showErrDialog(
        context,
        ErrMsg.invalidName,
      );
    }
  }

  /// Write news to file in Pod and navigate to return page or display error dialog
  /// if write to Pod failed to return a successful SolidCallFunctionStatus.
  ///
  /// Examples:
  /// - `await saveNewsToPod(context: context, data: updatedContent, newsFileName: newsFileName, childPage: ListMyNewsScreen(), scaffoldController: scaffoldController)` - to
  /// save a news file owned by the user.
  /// - `await saveNewsToPod(context: context, data: updatedContent,
  /// childPage: ListMyNewsScreen(), newsUrl: newsUrl, newsOwner: newsOwner,
  /// isExternal: true, scaffoldController: scaffoldController)` - to save an externally owned news file.
  ///
  /// - [context] - The build context.
  /// - [data] - The news content data to be encrypted and written to file in Pod.
  /// - [childPage] - The destination widget to navigate to after news file is saved.
  ///   [scaffoldController] - Controller for the Solid scaffold.
  /// - [newsFileName] - Optional filename. Required for saving user's own news file.
  /// - [newsUrl] - Optional news file url. Required for saving news files
  /// that are externally owned.
  /// - [newsOwner] - Optional news owner webId. Required for saving news
  /// that are externally owned.
  /// - [overwrite] - Optional boolean defining whether updating an existing owner's news file.
  /// - [isExternal] - Optional boolean defining whether writing an external news file.

  Future<void> saveNewsToPod({
    required BuildContext context,
    required NewsContent data,
    required Widget childPage,
    required SolidScaffoldController scaffoldController,
    String newsFileName = '',
    String newsUrl = '',
    String newsOwner = '',
    bool overwrite = false,
    bool isExternal = false,
  }) async {
    try {
      // Encrypt text using created time as the key
      // av: 20250519 - We need to encrypt the text because
      // at the moment rdflib cannot parse multiline text with
      // # (hash) values in them.
      String encNewsText = encryptVal(
        plainText: data.newsContent,
        encKey: data.createdDateTime,
      );

      // Create TTL body
      final newsTTLStr = genNewsTTLStr(
        data.createdDateTime,
        data.modifiedDateTime,
        data.newsTitle,
        encNewsText,
      );

      if (isExternal && newsUrl != '' && newsOwner != '') {
        debugPrint('newsUrl: $newsUrl');
        debugPrint('newsOwner: $newsOwner');

        // createNewsStatus = await writeExternalPod(
        await writeExternalPod(
          newsUrl,
          newsTTLStr,
          newsOwner,
        );
      } else {
        // Write file to POD
        await writePod(
          newsFileName,
          newsTTLStr,
          overwrite: overwrite,
        );
      }

      if (!context.mounted) return;

      Navigator.of(context, rootNavigator: true)
          .pop(); // Dismiss the saving dialog

      scaffoldController.navigateToSubpage(childPage);

      if (!context.mounted) {
        throw Exception('Context not found');
      }
    } on Exception catch (e) {
      debugPrint(
        'Exception (encrypting and saving news file, and navigating to return page):\n $e',
      );
    }
  }
}
