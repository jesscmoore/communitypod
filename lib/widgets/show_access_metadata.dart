/// Widget for display of access metadata for a file.
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

import 'package:communitypod/constants/app.dart';

/// Display sharing metadata of a file, ie. comprising
/// owner, webId that shared the file to the user, and
/// the permissions granted to the user.
///
/// Arguments:
/// - [newsOwner] - File owner.
/// - [permissionGranter] - User that shared the file to
/// the user.
/// - [permissionList] - List of permissions granted to the user.

class ShowAccessMetadata extends StatelessWidget {
  final String newsOwner;
  final String? permissionGranter;
  final String permissionList;

  const ShowAccessMetadata({
    super.key,
    required this.newsOwner,
    this.permissionGranter,
    required this.permissionList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: metadataPadding,
                  child: Text(
                    'Owner: $newsOwner',
                    style: metadataTextStyle,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: metadataPadding,
                  child: Text(
                    'Shared by: ${permissionGranter ?? 'N/A'}',
                    style: metadataTextStyle,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: metadataPadding,
                  child: Text(
                    'Permissions: $permissionList',
                    style: metadataTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
