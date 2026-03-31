/// The save file button.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2025-07-16 08:32:47 +1100 Jess Moore>
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

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:solidui/solidui.dart';

import 'package:communitypod/common/rest_api/file_helper.dart';
import 'package:communitypod/constants/colours.dart';
import 'package:communitypod/models/news.dart';

/// A stylised save button widget which on click saves the content to a file in a
/// Pod. External news posts are written to the owner's Pod. News created
/// by the user are written to the user's Pod.
///
/// Arguments:
///
/// - [articleController] - Text controller of the article text content editor.
/// - [formKey] - Key of the form to edit the metadata.
///   [scaffoldController] - Controller for the Solid scaffold.
/// - [prevNews] - Optional existing file data object. Required for saving existing file. (Default: null).
/// - [isExternal] - Optional boolean denoting whether file is externally
/// owned. (Default: false).
/// - [isExisting] - Optional boolean denoting whether file already
/// exists. (Default: false).

class NewsSaveButton extends StatelessWidget {
  final TextEditingController articleController;
  final GlobalKey<FormBuilderState> formKey;
  final SolidScaffoldController scaffoldController;
  final News? prevNews;
  final bool isExisting;
  final bool isExternal;

  const NewsSaveButton({
    super.key,
    required this.articleController,
    required this.formKey,
    required this.scaffoldController,
    this.prevNews,
    this.isExisting = false,
    this.isExternal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color and padding
      icon: const Icon(
        Icons.save,
      ),
      onPressed: () async {
        // Save file and redirect to view file page
        await NewsFileHelper().saveNews(
          context: context,
          articleController: articleController,
          formKey: formKey,
          scaffoldController: scaffoldController,
          prevNews: prevNews,
          isExisting: isExisting,
          isExternal: isExternal,
        );
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.save),
            // Larger edgeinsets to emphasise save button
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
      label: const Text(
        'SAVE',
      ),
    );
  }
}
