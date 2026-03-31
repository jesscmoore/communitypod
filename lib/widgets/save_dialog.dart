/// A save options dialog
///
// Time-stamp: <Friday 2025-10-08 18:25:01 +1000 Graham Williams>
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

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:solidui/solidui.dart';

import 'package:communitypod/common/rest_api/file_helper.dart';
import 'package:communitypod/constants/app.dart';
import 'package:communitypod/models/news.dart';

/// A save file dialog providing the user with the options to
/// save or don't save, or cancel their back action.
///
/// Arguments:
/// - [childPage] - child widget to navigate to.
/// - [articleController] - text controller holding text of the article field.
///   [scaffoldController] - Controller for the Solid scaffold.
/// - [formKey] - form key holding text of the file title.
/// - [prevNews] - Optional existing file data object. Required for saving existing file. (Default: null).
/// - [isExternal] - Optional boolean denoting whether file is externally
/// owned. (Default: false).

class SaveDialog extends StatelessWidget {
  final Widget childPage;
  final TextEditingController articleController;
  final SolidScaffoldController scaffoldController;
  final GlobalKey<FormBuilderState> formKey;
  final News? prevNews;
  final bool isExternal;

  /// Only called for existing files
  final bool isExisting = true;

  const SaveDialog({
    super.key,
    required this.childPage,
    required this.articleController,
    required this.scaffoldController,
    required this.formKey,
    this.prevNews,
    this.isExternal = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unsaved changes!'),
      content: const Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: true,
          child: ListBody(
            children: <Widget>[
              Text(ErrMsg.unsavedChanges),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        // Save button
        TextButton(
          child: const Text('Save'),
          onPressed: () async {
            // Save file
            await NewsFileHelper().saveNews(
              context: context,
              articleController: articleController,
              scaffoldController: scaffoldController,
              formKey: formKey,
              prevNews: prevNews,
              isExisting: isExisting,
              isExternal: isExternal,
            );
          },
        ),
        // Don't save button
        TextButton(
          child: const Text('Don\'t Save'),
          onPressed: () {
            scaffoldController.navigateToSubpage(childPage);
          },
        ),
        // Cancel button
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
