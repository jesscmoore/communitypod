/// A stateful widget for unreadable externally owned news file.
///
// Time-stamp: <Wednesday 2025-07-16 10:19:02 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025 Software Innovation Institute, ANU
///
/// License: GNU General Public License, Version 3 (the "License")
///
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:communitypod/constants/app.dart';
import 'package:communitypod/constants/colours.dart';
import 'package:communitypod/constants/ui.dart';
import 'package:communitypod/models/news.dart';
import 'package:communitypod/news/list_news_screen.dart';
import 'package:communitypod/news/share_news.dart';
import 'package:communitypod/widgets/action_button.dart';
import 'package:communitypod/widgets/display_metadata.dart';
import 'package:communitypod/widgets/msg_card.dart';

/// A [stateful] widget for displaying a message when the user tries to view
/// an externally owned news file.
///
/// Arguments:
/// - [newsPost] - The externally owned news file object.

class NonReadableNewsPost extends StatefulWidget {
  final News newsPost;
  final SolidScaffoldController scaffoldController;

  const NonReadableNewsPost({
    super.key,
    required this.newsPost,
    required this.scaffoldController,
  });

  @override
  State<NonReadableNewsPost> createState() => _NonReadableNewsPostState();
}

class _NonReadableNewsPostState extends State<NonReadableNewsPost> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// News
  late final News _newsPost;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;
    _newsPost = widget.newsPost;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            // Display metadata - show sharing and path info but not dates (as requires newsContent)
            DisplayMetadata(
              newsOwner: _newsPost.newsOwner,
              permissionGranter: _newsPost.permissionGranter!,
              permissionList: _newsPost.permissionList,
              newsFileName: _newsPost.newsFileName,
              newsUrl: _newsPost.newsUrl,
              showFileName: true,
              showSharing: true,
              showPathInfo: true,
            ),
            // MsgCard style works in light and dark themes
            buildMsgCard(
              context,
              Icons.info,
              Colors.amber,
              'Access Permission!',
              nonReadableNewsMsg,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Derive whether window is narrow
                  isNarrow = WindowSize().isNarrowWindow(constraints);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 5.0,
                    children: [
                      // Share button
                      if (_newsPost.permissionList.contains('control')) ...[
                        ActionButton(
                          label: ButtonLabel.share,
                          icon: const Icon(Icons.share),
                          backgroundColor: ButtonBackgroundColor.share,
                          childPage: ShareNews(
                            newsUrl: _newsPost.newsUrl,
                            newsOwner: _newsPost.newsOwner,
                            isExternal: _newsPost.isExternalRes,
                            newsContent: _newsPost.content,
                            backPage: ListNewsScreen(
                              scaffoldController: _scaffoldController,
                            ),
                            scaffoldController: _scaffoldController,
                          ),
                          scaffoldController: _scaffoldController,
                          isNarrow: isNarrow,
                        ),
                      ],
                      // /// Delete button
                      // /// 20250719 jesscmoore Commented out as also commented out
                      // /// external file with read-write-control-append access
                      // if (MetaData[permissionListPred].contains('write')) ...[
                      //   DelButton(data: metaData, isExternal: true),
                      //   const SizedBox(
                      //     width: 5,
                      //   ),
                      // ],
                      ActionButton(
                        label: ButtonLabel.back,
                        icon: const Icon(Icons.keyboard_backspace),
                        backgroundColor: ButtonBackgroundColor.back,
                        childPage: ListNewsScreen(
                          scaffoldController: _scaffoldController,
                        ),
                        scaffoldController: _scaffoldController,
                        isNarrow: isNarrow,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
