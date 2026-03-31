/// A widget to display news post metadata.
///
// Time-stamp: <Friday 2025-10-14 14:59:05 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
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
/// Authors: Jess Moore
library;

import 'package:flutter/material.dart';

import 'package:communitypod/widgets/show_access_metadata.dart';
import 'package:communitypod/widgets/show_date_metadata.dart';
import 'package:communitypod/widgets/show_filename_metadata.dart';
import 'package:communitypod/widgets/show_path_metadata.dart';

/// Display the metadata of a news post.
/// showDates requires created and modified date time.
/// showSharing requires owner, premission granter and
/// permission list.
/// showPathInfo requires file name and url.
///
/// Arguments:
/// - [createdDateTime] - post created date time.
/// - [modifiedDateTime] - post last modified data time.
/// - [newsOwner] - webId of news post owner.
/// - [permissionGranter] - webId of entity that shared the news post
/// to the user.
/// - [permissionList] - list of permissions granted to the user.
/// - [newsFileName] - news post file name.
/// - [newsUrl] - url of news post.
/// - [showDates] - flag describing whether to show data metadata of
/// news post.
/// - [showFileName] - flag describing whether to show filename of
/// news post.
/// - [showSharing] - flag describing whether to show sharing
/// metadata of news post.
/// - [showPathInfo] - flag describing whether to show url path of
/// news post.

class DisplayMetadata extends StatelessWidget {
  final String createdDateTime;
  final String modifiedDateTime;
  final String newsOwner;
  final String? permissionGranter;
  final String? permissionList;
  final String newsFileName;
  final String newsUrl;

  final bool isExternal;
  final bool showDates;
  final bool showFileName;
  final bool showSharing;
  final bool showPathInfo;

  const DisplayMetadata({
    super.key,
    this.createdDateTime = '',
    this.modifiedDateTime = '',
    this.newsOwner = '',
    this.permissionGranter,
    this.permissionList,
    this.newsFileName = '',
    this.newsUrl = '',
    this.isExternal = false,
    this.showDates = false,
    this.showFileName = false,
    this.showSharing = false,
    this.showPathInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ShowFileName
          if (showFileName && newsFileName.isNotEmpty)
            ShowFilenameMetadata(filename: newsFileName),
          // ShowDates (created and modified)
          if (showDates &&
              createdDateTime.isNotEmpty &&
              modifiedDateTime.isNotEmpty)
            ShowDateMetadata(
              createdDateTime: createdDateTime,
              modifiedDateTime: modifiedDateTime,
            ),
          // Show sharing info (owner, provider, access list)
          if (showSharing)
            ShowAccessMetadata(
              newsOwner: newsOwner,
              permissionGranter: permissionGranter!,
              permissionList: permissionList!,
            ),
          // Show path info (filename and path)
          if (showPathInfo && newsUrl != '') ShowPathMetadata(fileUrl: newsUrl),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
