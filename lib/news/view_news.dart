/// A stateful widget to view a news object.
///
// Time-stamp: <Wednesday 2025-07-16 10:18:07 +1000 Graham Williams>
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

import 'package:communitypod/constants/colours.dart';
import 'package:communitypod/constants/ui.dart';
import 'package:communitypod/models/news.dart';
import 'package:communitypod/news/edit_news.dart';
import 'package:communitypod/news/list_notes_screen.dart';
import 'package:communitypod/news/share_news.dart';
import 'package:communitypod/widgets/note_action_button.dart';
import 'package:communitypod/widgets/note_del_button.dart';
import 'package:communitypod/widgets/note_display_markdown.dart';
import 'package:communitypod/widgets/note_display_metadata.dart';

/// A [stateful] widget for viewing a news object.
///
/// Arguments:
/// - [newsPost] - The news data object to view.
/// - [scaffoldController] - Controller for the Solid scaffold.

class ViewNews extends StatefulWidget {
  final News newsPost;
  final SolidScaffoldController scaffoldController;

  const ViewNews({
    super.key,
    required this.newsPost,
    required this.scaffoldController,
  });

  @override
  State<ViewNews> createState() => _ViewNewsState();
}

class _ViewNewsState extends State<ViewNews> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// News data
  late final News _newsPost;

  /// List of user's permissions
  late final List<String> _accessList;

  @override
  void initState() {
    super.initState();
    _newsPost = widget.newsPost;
    _accessList = _newsPost.permissionList.split(',');
    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
                          child: Text(
                            _newsPost.content!.newsTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Display note metadata - show dates and sharing info, but not path info (as only shown on non readable note page)
                  DisplayNewsMetadata(
                    createdDateTime: _newsPost.content!.createdDateTime,
                    modifiedDateTime: _newsPost.content!.modifiedDateTime,
                    newsOwner: _newsPost.newsOwner,
                    permissionGranter: _newsPost.permissionGranter ?? 'N/A',
                    permissionList: _newsPost.permissionList,
                    newsFileName: _newsPost.newsFileName,
                    newsUrl: _newsPost.newsUrl,
                    showDates: true,
                    showFileName: true,
                    showSharing: true,
                    showPathInfo: true,
                  ),
                  // Display markdown note content
                  noteDisplayMarkdown(_newsPost.content!.newsContent),
                ],
              ),
            ),
          ),
        ),
        // Action buttons - always visible
        Column(
          children: <Widget>[
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
                      // Share button if control access
                      if (_accessList.contains('control')) ...[
                        ActionButton(
                          label: ButtonLabel.share,
                          icon: const Icon(Icons.share),
                          backgroundColor: ButtonBackgroundColor.share,
                          childPage: ShareNews(
                            newsUrl: _newsPost.newsUrl,
                            newsOwner: _newsPost.newsOwner,
                            isExternal: _newsPost.isExternalRes,
                            backPage: ViewNews(
                              newsPost: _newsPost,
                              scaffoldController: _scaffoldController,
                            ),
                            scaffoldController: _scaffoldController,
                          ),
                          scaffoldController: _scaffoldController,
                          isNarrow: isNarrow,
                        ),
                      ],
                      // Edit button if write access
                      if (_accessList.contains('write')) ...[
                        ActionButton(
                          label: ButtonLabel.edit,
                          icon: const Icon(Icons.edit),
                          backgroundColor: ButtonBackgroundColor.edit,
                          childPage: EditNews(
                            newsPost: _newsPost,
                            scaffoldController: _scaffoldController,
                          ),
                          scaffoldController: _scaffoldController,
                          isNarrow: isNarrow,
                        ),
                      ],

                      /// Delete button
                      if (!_newsPost.isExternalRes) ...[
                        DelButton(
                          filename: _newsPost.newsFileName,
                          isExternal: false,
                          isNarrow: isNarrow,
                          childPage: ListNewsScreen(
                            scaffoldController: _scaffoldController,
                          ),
                          scaffoldController: _scaffoldController,
                        ),
                      ],
                      // Back button
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
                      // Add space
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }
}
