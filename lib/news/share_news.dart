/// A stateful widget for sharing a news file.
///
// Time-stamp: <Friday 2025-10-24 12:01:03 +1100 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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

import 'package:communitypod/widgets/note_back_button.dart';

/// A [StatefulWidget] for sharing a news file.
///
/// Arguments:
/// - [newsUrl] - is the name of the news file to be shared.
/// - [newsOwner] - is the webId of the news file owner.
/// - [backPage] - The widget used by Back button.
/// - [isExternalRes] - Whether the file is externally owned.
/// - [scaffoldController] - Controller for the Solid scaffold.

class ShareNews extends StatefulWidget {
  final String newsUrl;
  final String newsOwner;
  final Widget backPage;
  final bool isExternal;
  final SolidScaffoldController scaffoldController;

  const ShareNews({
    super.key,
    required this.newsUrl,
    required this.newsOwner,
    required this.backPage,
    required this.scaffoldController,
    this.isExternal = false,
  });

  @override
  ShareNewsState createState() => ShareNewsState();
}

class ShareNewsState extends State<ShareNews> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  @override
  void initState() {
    super.initState();
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
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  NewsBackButton(
                    childPage: widget.backPage,
                    scaffoldController: _scaffoldController,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: GrantPermissionUi(
                      showAppBar: false,
                      resourceName: widget.newsUrl,
                      ownerWebId: widget.newsOwner,
                      isExternalRes: widget.isExternal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
