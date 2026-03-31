/// List news screen - fetches all news
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://opensource.org/license/gpl-3-0
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
/// Authors: Anushka Vidanage, Jess Moore
library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:communitypod/common/rest_api/rest_api.dart';
import 'package:communitypod/constants/app.dart';
import 'package:communitypod/models/news.dart';
import 'package:communitypod/models/news_call_result.dart';
import 'package:communitypod/models/selected_news.dart';
import 'package:communitypod/news/list_news.dart';
import 'package:communitypod/news/new_news_post.dart';
import 'package:communitypod/widgets/err_card.dart';
import 'package:communitypod/widgets/msg_card.dart';
import 'package:communitypod/widgets/list_del_dialog.dart';
import 'package:communitypod/widgets/list_revoke_dialog.dart';

/// A [StatefulWidget] that fetches the all news accessible to the user.
///
/// Parameters:
///   [scaffoldController] - Controller for the Solid scaffold.

class ListNewsScreen extends StatefulWidget {
  final SolidScaffoldController scaffoldController;

  const ListNewsScreen({
    super.key,
    required this.scaffoldController,
  });

  @override
  State<ListNewsScreen> createState() => _ListNewsScreenState();
}

class _ListNewsScreenState extends State<ListNewsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Future function to retrieve user's news list
  // static Future? _fetchOwnNews;
  late Future<NewsCallResult> _fetchOwnNews;

  /// Future function to retrieve externally owned news list
  // static Future? _fetchExternalNews;
  late Future<NewsCallResult> _fetchExternalNews;

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  @override
  void initState() {
    super.initState();
    _scaffoldController = widget.scaffoldController;

    _scrollController = ScrollController();

    // Set future functions to fetch owner's news and external news
    _fetchOwnNews = getOwnNewsList();
    _fetchExternalNews = getExternalNewsList();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  /// Load all news found. If any unparseable news files
  /// found, first navigate to a dialog to delete unparseable
  /// news files.
  ///
  /// Arguments:
  /// - [ownerListResults] - [NewsCallResult] class containing news files owner by the user and unparseable news.
  /// - [extListResults] - [NewsCallResult] class containing news files shared to user and unparseable news.
  /// - [unparseableNews] - list of any unparseable files.

  Widget _loadedNewsScreen(
    NewsCallResult ownerListResults,
    NewsCallResult extListResults,
    SolidScaffoldController scaffoldController,
  ) {
    // Combine the results
    NewsCallResult results =
        ownerListResults.addCallResults(results: extListResults);
    final List<News> news = results.news!;
    final List<SelectedNews> unparseableNews = results.unparseableNews!;
    final List<News> nonExistentNews = results.nonExistentNews!;

    if (unparseableNews.isNotEmpty) {
      // Show dialog to optionally delete any unparseable news files if found
      // These are news files that have been incorrectly written and
      // are unparseable.
      return DelDialog(
        unparseableNews: unparseableNews,
        childPage: ListNews(
          news: news,
          title: '$combinedNewsTitle ($combinedNewsExplanation)',
          scaffoldController: scaffoldController,
        ),
        scaffoldController: _scaffoldController,
      );
    } else if (nonExistentNews.isNotEmpty) {
      // Show dialog to optionally revoke access to any nonexistent news files if found
      // These are news files that were shared to the user and then deleted
      // without revoking access to the user before deleting the news file
      // as such these news files are still in the user's permission log
      // without a revoke entry. The dialog provides an option to
      // revoke the user's access to these now non existent news files.
      return RevokeDialog(
        nonExistentNews: nonExistentNews,
        childPage: ListNews(
          news: news,
          title: '$combinedNewsTitle ($combinedNewsExplanation)',
          scaffoldController: _scaffoldController,
        ),
        scaffoldController: _scaffoldController,
      );
    } else if (news.isEmpty) {
      // If no news files accessible to user, show create new news post widget
      return _loadNewNewsPost(scaffoldController);
    } else {
      return ListNews(
        news: news,
        title: '$combinedNewsTitle ($combinedNewsExplanation)',
        scaffoldController: scaffoldController,
      );
    }
  }

  /// Advises user to create their first news post if no news found.
  ///
  /// Arguments: none.
  Widget _loadNewNewsPost(SolidScaffoldController scaffoldController) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            // MsgCard style works in light and dark themes
            // No news files message
            buildMsgCard(
              context,
              Icons.info,
              Colors.amber,
              NewsListMsg.noNews,
              NewsListMsg.writeFirstNews,
              isSmall: true,
            ),
            NewNewsPost(
              scaffoldController: scaffoldController,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder(
          // future: _asyncFetchOwnNews,
          future: Future.wait([
            // Future result of fetching owner's news list
            _fetchOwnNews,
            // Future result of fetching externally owned news list
            _fetchExternalNews,
          ]),
          builder: (context, snapshot) {
            // if (!snapshot.hasData) {
            //   return Scaffold(body: loadingScreen(normalLoadingScreenHeight));
            // }
            // final PermissionDetails initCurrentPerm =
            //     snapshot.data![0] as PermissionDetails;
            // final List<LogRecord> initPermHistoryList =
            //     snapshot.data![1] as List<LogRecord>;
            // return initCurrentPerm.permissionMap.isEmpty
            //     ? _buildPermPage(context)
            //     : _buildPermPage(context, initCurrentPerm, initPermHistoryList);

            switch (snapshot.connectionState) {
              case (ConnectionState.waiting || ConnectionState.active):
                return loadingScreen(normalLoadingScreenHeight);

              case ConnectionState.done:
                if (snapshot.hasError) {
                  // future failed with error
                  debugPrint('Error: ${snapshot.error.toString()}');
                  return errCard(
                    context,
                    'Error: data loading failed',
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final NewsCallResult ownerNewsListResult = snapshot.data![0];
                  final NewsCallResult extNewsListResult = snapshot.data![1];
                  // Successfully returned NewsCallResult
                  return _loadedNewsScreen(
                    ownerNewsListResult,
                    extNewsListResult,
                    // snapshot.data as NewsCallResult,
                    _scaffoldController,
                  );
                } else if (snapshot.data == null ||
                    snapshot.data.toString() == 'null') {
                  // No files found
                  return _loadNewNewsPost(_scaffoldController);
                } else {
                  // Unknown error
                  return errCard(
                    context,
                    'Unknown error',
                  );
                }

              // Connection none error
              case ConnectionState.none:
                debugPrint('Error: Builder has ConnectionState.none');
                return errCard(
                  context,
                  'Connection error',
                );
            }
          },
        ),
      ),
    );
  }
}
