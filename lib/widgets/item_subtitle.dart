/// A stateless widget to show subtitle of a list item.
///
/// Copyright (C) 2026 Software Innovation Institute, Australian National University
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:communitypod/models/news.dart';
import 'package:communitypod/utils/get_id.dart';
import 'package:communitypod/utils/misc.dart';

/// A [stateless] widget to show subtitle of a list item.
///
/// Arguments:
/// - [item] - A list item.
/// - [isNarrow] - Flag describing whether window is narrower than
/// narrow threshold.
///
class ItemSubtitle extends StatelessWidget {
  const ItemSubtitle({
    super.key,
    required News item,
    required bool isNarrow,
  })  : _item = item,
        _isNarrow = isNarrow;

  final News _item;
  final bool _isNarrow;

  @override
  Widget build(BuildContext context) {
    return Text(
      (!_item.isExternalRes)
          ? 'Owner: ${getId(_item.newsOwner)} \n'
              'Created: ${getDateTimeStr(_item.content!.createdDateTime)}, Modified: ${getDateTimeStr(_item.content!.modifiedDateTime)}\n\n'
              '${_item.content!.contentWithoutImages}'
          : (_item.permissionList.contains('read'))
              ? 'Owner: ${getId(_item.newsOwner)} \n'
                  'Created: ${getDateTimeStr(_item.content!.createdDateTime)}, Modified: ${getDateTimeStr(_item.content!.modifiedDateTime)} \n\n'
                  '${_item.content!.contentWithoutImages}'
              : 'Filename: ${_item.newsFileName} \n'
                  'Owner: ${getId(_item.newsOwner)} \n'
                  'Permissions: ${_item.permissionList}',
      maxLines: (!_isNarrow) ? 6 : 12, // Limit lines
      overflow: TextOverflow.ellipsis,
    );
  }
}
