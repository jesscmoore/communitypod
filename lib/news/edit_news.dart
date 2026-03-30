/// A stateful widget to edit news owned by the user.
///
// Time-stamp: <Wednesday 2025-07-16 14:37:09 +1000 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:solidui/solidui.dart';

import 'package:communitypod/models/news.dart';
import 'package:communitypod/news/view_news.dart';
import 'package:communitypod/widgets/edit_scroll_view.dart';

/// A [StatefulWidget] to edit news owned by the user.
///
/// Arguments:
///   [note] - is the data of that news object.
///   [scaffoldController] - Controller for the Solid scaffold.

class EditNews extends StatefulWidget {
  /// Data object for the selected news post.
  final News newsPost;
  final SolidScaffoldController scaffoldController;

  const EditNews({
    super.key,
    required this.newsPost,
    required this.scaffoldController,
  });

  @override
  EditNewsState createState() => EditNewsState();
}

class EditNewsState extends State<EditNews> {
  final formKey = GlobalKey<FormBuilderState>();

  TextEditingController? _textController;

  /// Scroll controller for single child scroll view.
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Focus node for news title text field.
  late final FocusNode _focusTitle;

  /// Focus node for news content text field.
  late final FocusNode _focusContent;

  /// News
  late final News _newsPost;

  /// News text content
  String data = '';

  @override
  void initState() {
    super.initState();
    _newsPost = widget.newsPost;
    _scaffoldController = widget.scaffoldController;
    // Initialise news content field
    _textController = TextEditingController();
    _textController!.text = _newsPost.content!.newsContent;
    // Start listening to changes.
    _textController!.addListener(_renderMarkdown);
    _scrollController = ScrollController();
    // Focus node for the title text field
    // If 'TAB' key press, move to news content text field
    _focusTitle = FocusNode(
      onKeyEvent: (FocusNode node, KeyEvent evt) {
        if (evt.logicalKey == LogicalKeyboardKey.tab) {
          if (evt is KeyDownEvent) {
            // Move focus
            _focusContent.requestFocus();
          }
          return KeyEventResult.handled;
        } else {
          return KeyEventResult.ignored;
        }
      },
    );
    // Focus node for the news content markdown editor
    _focusContent = FocusNode();
    // To enable the ENTER => SAVE functionality within a news, replace the
    // above line with the following. For now we will stay with current
    // behaviour. (20250714 gjw).
    //
    // _focusNode = FocusNode(
    //   onKeyEvent: (FocusNode node, KeyEvent evt) {
    //     if (!HardwareKeyboard.instance.isShiftPressed &&
    //         evt.logicalKey.keyLabel == 'Enter') {
    //       if (evt is KeyDownEvent) {
    //         // Save news when enter (not shift-enter) pressed
    //         NewsFileHelper().saveNews(context, _textController!, formKey, widget.note);
    //       }
    //       return KeyEventResult.handled;
    //     } else {
    //       return KeyEventResult.ignored;
    //     }
    //   },
    // );
  }

  @override
  void dispose() {
    _textController!.dispose(); // Dispose the TextEditingController
    _scrollController.dispose(); // Dispose the ScrollController
    _focusTitle.dispose(); // Dispose the title focus node
    _focusContent.dispose(); // Dispose the content focus node
    super.dispose();
  }

  void _renderMarkdown() {
    setState(() {
      data = _textController!.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EditScrollView(
      formKey: formKey,
      textController: _textController,
      scrollController: _scrollController,
      scaffoldController: _scaffoldController,
      focusTitle: _focusTitle,
      focusContent: _focusContent,
      childPage: ViewNews(
        newsPost: _newsPost,
        scaffoldController: _scaffoldController,
      ),
      data: data,
      prevNews: _newsPost,
      newsTitle: _newsPost.content!.newsTitle,
      isExisting: true,
      isExternal: _newsPost.isExternalRes,
    );
  }
}
