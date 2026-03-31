/// App-wide constants.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2023-11-01 08:26:39 +1100 Graham Williams>
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

const String applicationRepo = 'https://github.com/jesscmoore/communitypod';
const String appChangeLog =
    'https://github.com/jesscmoore/communitypod/blob/dev/CHANGELOG.md';
const String defWebID = 'https://pods.solidcommunity.au';
const String topBarTitle = 'Community Pod';
const String shortTitle = 'News';
const String longTitle = 'CommunityPod\nPrivate and Shareable News';

const String appOwner = '''© 2026 Software Innovation Institute''';

const String aboutText =
    '''The communitypod app is an example of a Solid Pods app written in Flutter to read, write, and share encrypted news stories stored on your personal online data store (Pod) hosted on a Solid Server.''';

const String appDir = 'communitypod';

// const AssetImage backgroundImg =
//     AssetImage('assets/images/communitypod-background.jpg');
const AssetImage backgroundImg =
    AssetImage('assets/images/Hands-AdobeStock_435501233.jpeg');
const AssetImage logoImg = AssetImage('assets/images/app_icon.png');

//const kDefaultPadding = 20.0;
//const double buttonBorderRadius = 5;
//const double standardSpace = 20.0;
const double badListItemHeight = 68.0;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
//double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

const nonReadableNewsMsg =
    'You do not have read access to this news file and therefore cannot view the file. However, you can delete it or share it with others.';

//const noNewsMsg = 'You do not have any news files yet!';

// SizedBox standardHeight() {
//   return const SizedBox(
//     height: standardSpace / 2,
//   );
// }

const double desktopWidthThreshold = 960;

// Text style of page titles
const titleStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

// Text style for metadata
const metadataTextStyle = TextStyle(
  fontSize: 12,
);

// Text style for advice
const adviceStyle = TextStyle(
  fontSize: 13,
);

// Titles for nav widgets to pages
// New news
const String newNewsPostTitle = 'New Post';
const String newNewsToolTip = 'Create a new news post';
// My news
const String myNewsTitle = 'My Posts';
const String myNewsExplanation = 'created by me';
const String myNewsToolTip = 'Go to news owned by me';

// All news
const String combinedNewsTitle = 'News';
const String combinedNewsExplanation = 'accessible to me';
const String combinedNewsToolTip = 'Go to news accessible to me';

/// News list messages
class NewsListMsg {
  /// Message displayed when corrupt files found
  static const String badFilesFound = 'Corrupt news files present';

  /// Message displayed when non existent files found
  static const String nonExistentNewsFound =
      'Non-existent news files found in the log without a \'revoke\' entry in the log';

  /// Message displayed when no news file found in user's Pod
  static const String noNews = 'No news yet!';

  /// Advises user to write their first news post
  static const String writeFirstNews = 'Write your first news file';
}

/// News action messages
class Msg {
  /// News saving message
  static const String savingNews = 'Saving the news file!';

  /// News deleting message
  static const String deletingNews = 'Deleting the news file!';

  /// Confirm delete message
  static const String confirmDelete =
      'Are you sure you want to delete this news file?';

  /// Confirm delete multiple news files message
  static const String confirmDeleteMultiple =
      'Are you sure you want to delete these news files?';

  /// News deleting message
  static const String revokingNews = 'Revoking access!';

  /// Confirm message to revoke access to news file
  static const String confirmRevoke =
      'Are you sure you want to revoke access to this news file?';

  /// Confirm revoke access to multiple news files message
  static const String confirmRevokeMultiple =
      'Are you sure you want to revoke access to these new files?';

  /// Please confirm message
  static const String plsConfirm = 'Please Confirm';
}

/// Error messages for errors occuring on news post actions
class ErrMsg {
  /// No changes to news post error.
  static const String noChanges = 'You have no new changes!';

  /// No news post content.
  static const String noContent = 'Please enter some news post content.';

  /// Invalid news name.
  static const String invalidName =
      'News name validation failed! Try using a different name.';

  /// Error message when fails to save news file to POD
  static const String saveFailed =
      'Failed to store the news file in your POD. Try again!';

  /// Unsaved changes found
  static const String unsavedChanges = 'Unsaved changed found!';
}

class NewsIconSize {
  static const double width = 50;
  static const double height = 50;
  static const double twoIconWidth = (width * 2) + gap;
  static const double gap = 15;
}

// EdgeInsets for metadata block
const EdgeInsets metadataPadding = EdgeInsets.fromLTRB(15, 5, 10, 0);

/// Button shape decoration for list pages
ShapeDecoration buttonShapeList =
    const ShapeDecoration(color: Colors.grey, shape: CircleBorder());
