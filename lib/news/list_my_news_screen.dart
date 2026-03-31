/// List news screen - fetches user's news files
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

/// A [StatefulWidget] that fetches the user's news files in their app data folder.
///
/// Parameters:
///   [scaffoldController] - Controller for the Solid scaffold.

class ListMyNewsScreen extends StatefulWidget {
  final SolidScaffoldController scaffoldController;

  const ListMyNewsScreen({
    super.key,
    required this.scaffoldController,
  });

  @override
  State<ListMyNewsScreen> createState() => _ListMyNewsScreenState();
}

class _ListMyNewsScreenState extends State<ListMyNewsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Future function to retrieve user's news object list
  static Future? _asyncDataFetch;

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  @override
  void initState() {
    super.initState();
    _scaffoldController = widget.scaffoldController;
    _asyncDataFetch = getOwnNewsList();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  /// Load user's news if news found. If any unparseable news files
  /// found, first navigate to a dialog to delete unparseable
  /// news files.
  ///
  /// Arguments:
  ///   [results] - [NewsCallResult] class containing [news] of
  /// files found in user's app data folder, and [unparseableNews]
  /// list of any unparseable files.

  Widget _loadedNewsScreen(
    NewsCallResult results,
    SolidScaffoldController scaffoldController,
  ) {
    final List<News> news = results.news!;
    final List<SelectedNews> unparseableNews = results.unparseableNews!;

    if (unparseableNews.isNotEmpty) {
      return DelDialog(
        unparseableNews: unparseableNews,
        childPage: ListNews(
          news: news,
          title: '$myNewsTitle ($myNewsExplanation)',
          scaffoldController: scaffoldController,
        ),
        scaffoldController: _scaffoldController,
      );
    } else if (news.isEmpty) {
      return _loadNewNewsPost(scaffoldController);
    } else {
      return ListNews(
        news: news,
        title: '$myNewsTitle ($myNewsExplanation)',
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
            // No files message
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
          future: _asyncDataFetch,
          builder: (context, snapshot) {
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
                  // Successfully returned NewsCallResult
                  return _loadedNewsScreen(
                    snapshot.data as NewsCallResult,
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
