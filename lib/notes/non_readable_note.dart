/// A stateful widget for unreadable externally owned note.
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
import 'package:communitypod/models/note.dart';
import 'package:communitypod/notes/list_notes_screen.dart';
import 'package:communitypod/notes/share_note.dart';
import 'package:communitypod/widgets/msg_card.dart';
import 'package:communitypod/widgets/note_action_button.dart';
import 'package:communitypod/widgets/note_display_metadata.dart';

/// A [stateful] widget for displaying a message when the user tries to view
/// an externally owned widget shared to the user.
///
/// Arguments:
/// - [note] - The externally owned note shared to the user.

class NonReadableNews extends StatefulWidget {
  final News note;
  final SolidScaffoldController scaffoldController;

  const NonReadableNews({
    super.key,
    required this.note,
    required this.scaffoldController,
  });

  @override
  State<NonReadableNews> createState() => _NonReadableNewsState();
}

class _NonReadableNewsState extends State<NonReadableNews> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// News
  late final News _note;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;
    _note = widget.note;
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
            // Display note metadata - show sharing and path info but not dates (as requires newsContent)
            DisplayNewsMetadata(
              newsOwner: _note.newsOwner,
              permissionGranter: _note.permissionGranter!,
              permissionList: _note.permissionList,
              newsFileName: _note.newsFileName,
              newsUrl: _note.newsUrl,
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
                      if (_note.permissionList.contains('control')) ...[
                        ActionButton(
                          label: ButtonLabel.share,
                          icon: const Icon(Icons.share),
                          backgroundColor: ButtonBackgroundColor.share,
                          childPage: ShareNews(
                            newsUrl: _note.newsUrl,
                            newsOwner: _note.newsOwner,
                            isExternal: _note.isExternalRes,
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
                      // /// external note with read-write-control-append access
                      // if (noteMetaData[permissionListPred].contains('write')) ...[
                      //   DelButton(noteData: noteMetaData, isExternal: true),
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
