/// A stylised back button widget.
///
// Time-stamp: <Wednesday 2025-07-16 09:08:27 +1000 Graham Williams>
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
/// Authors: Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:solidui/solidui.dart';

import 'package:communitypod/constants/colours.dart';
import 'package:communitypod/constants/turtle_structures.dart';
import 'package:communitypod/models/note.dart';
import 'package:communitypod/widgets/save_dialog.dart';

/// A stylised back button widget for news posts. On click it checks if edited data exists, if found it asks if the user wants to save or not save or cancel the back action. Then it navigates to the provided child page.
///
/// Arguments:
/// - [childPage] - The child page to navigate back to.
///   [scaffoldController] - Controller for the Solid scaffold.
/// - [textController] - Optional text controller if back is being called from note editor.
/// - [formKey] - Key of the form to edit news post metadata
/// - [prevNews] - Optional existing user's news data object. Required
/// for saving existing news posts. (Default: null).
/// - [isExternal] - Optional boolean denoting whether news post is externally
/// owned. (Default: false).
/// - [isExisting] - Optional boolean denoting whether news post already
/// exists. (Default: false).

class NewsBackButton extends StatelessWidget {
  const NewsBackButton({
    super.key,
    required this.childPage,
    required this.scaffoldController,
    this.textController,
    this.formKey,
    this.prevNews,
    this.isExternal = false,
    this.isExisting = false,
  });

  final Widget childPage;
  final SolidScaffoldController scaffoldController;
  final TextEditingController? textController;
  final GlobalKey<FormBuilderState>? formKey;
  final News? prevNews;
  final bool isExternal;
  final bool isExisting;

  @override
  Widget build(BuildContext context) {
    String? prevNewsTitle;
    String? prevNewsContent;
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color
      icon: const Icon(
        Icons.keyboard_backspace,
      ),
      onPressed: () {
        if (formKey?.currentState?.saveAndValidate() ?? false) {
          if (textController != null) {
            String noteText = textController!.text;
            Map formData = formKey?.currentState?.value as Map;
            String newsTitle = formData[newsTitlePred].replaceAll('\n', '');

            if (isExisting) {
              // Get previous title and content
              prevNewsTitle = prevNews!.content!.newsTitle;
              prevNewsContent = prevNews!.content!.newsContent;
              // Check if title or content changed
              if (newsTitle != prevNewsTitle || noteText != prevNewsContent) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    // Call save/don't save/cancel dialog
                    return SaveDialog(
                      childPage: childPage,
                      scaffoldController: scaffoldController,
                      textController: textController!,
                      formKey: formKey!,
                      prevNews: prevNews,
                      isExternal: isExternal,
                    );
                  },
                );
              } else {
                debugPrint('No unsaved changes found');
                scaffoldController.navigateToSubpage(childPage);
              }
            }
          }
        } else {
          scaffoldController.navigateToSubpage(childPage);
        }
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.back),
          ),
      label: const Text(
        'BACK',
      ),
    );
  }
}
