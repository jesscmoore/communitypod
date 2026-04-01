/// A stateless widget to show the author byline of a news post.
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

import 'package:intl/intl.dart';

import 'package:communitypod/utils/get_id.dart';

/// A [stateless] widget to show the author byline of a news post.
///
/// Arguments:
/// - [newsOwner] - The WebID of the news post owner.
/// - [modifiedDateTime] - ISO 8601 date string of last modification.
/// - [createdDateTime] - ISO 8601 date string of creation.
/// - [isNarrow] - Whether the window is narrower than the narrow threshold.

class AuthorByLine extends StatelessWidget {
  const AuthorByLine({
    super.key,
    required String newsOwner,
    required String modifiedDateTime,
    required String createdDateTime,
    required bool isNarrow,
  })  : _newsOwner = newsOwner,
        _modifiedDateTime = modifiedDateTime,
        _createdDateTime = createdDateTime,
        _isNarrow = isNarrow;

  final String _newsOwner;
  final String _modifiedDateTime;
  final String _createdDateTime;
  final bool _isNarrow;

  /// Derive the date number suffix, eg. 1st
  String _ordinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Format date string with suffix after number, eg 1st
  String _formatDate(String dateTimeStr) {
    final dt = DateTime.parse(dateTimeStr);
    final dayOfWeek = DateFormat('EEEE').format(dt);
    final month = DateFormat('MMMM').format(dt);
    final year = DateFormat('yyyy').format(dt);
    return '$dayOfWeek ${dt.day}${_ordinalSuffix(dt.day)} $month $year';
  }

  @override
  Widget build(BuildContext context) {
    // Append updated string if modified date is after created date
    final isUpdated = DateTime.parse(_modifiedDateTime)
        .isAfter(DateTime.parse(_createdDateTime));
    final updated = isUpdated ? ' (Updated)' : '';
    final byline =
        'By ${getId(_newsOwner)}, ${_formatDate(_modifiedDateTime)}$updated';

    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
            child: Text(
              byline,
              maxLines: (!_isNarrow) ? 1 : 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
