/// A stateful widget for creating a new file.
///
// Time-stamp: <Wednesday 2025-07-16 14:43:37 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute
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
/// Authors: Graham Williams, Anushka Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:solidui/solidui.dart';

import 'package:communitypod/news/list_my_news_screen.dart';
import 'package:communitypod/widgets/edit_scroll_view.dart';

/// A [Stateful] widget for creating a new news post file.
///
/// Parameters:
///   [scaffoldController] - Controller for the Solid scaffold.

class NewNewsPost extends StatefulWidget {
  final SolidScaffoldController scaffoldController;

  const NewNewsPost({
    super.key,
    required this.scaffoldController,
  });

  @override
  NewNewsPostState createState() => NewNewsPostState();
}

class NewNewsPostState extends State<NewNewsPost> {
  /// Key for form builder used for title text field
  final formKey = GlobalKey<FormBuilderState>();

  /// Text controller for article text field
  TextEditingController? _articleController;

  /// Scroll controller for single child scroll view.
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Focus node for title text field.
  late final FocusNode _focusTitle;

  /// Focus node for content text field.
  late final FocusNode _focusContent;

  /// Initialise content text string.
  String data = '';

  @override
  void initState() {
    super.initState();
    _articleController = TextEditingController();
    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;

    // Start listening to changes.
    _articleController!.addListener(_renderMarkdown);
    // Focus node for the title text field
    // If 'TAB' key press, move to content text field
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
    // Focus node for the content markdown editor
    _focusContent = FocusNode();
    // To enable the ENTER => SAVE functionality within a file, replace the above
    // line with the following. For now we will stay with current
    // behaviour. (20250714 gjw).
    //
    // _focusContent = FocusNode(
    //   onKeyEvent: (FocusNode node, KeyEvent evt) {
    //     if (!HardwareKeyboard.instance.isShiftPressed &&
    //         evt.logicalKey.keyLabel == 'Enter') {
    //       if (evt is KeyDownEvent) {
    //         // Save when enter (not shift-enter) pressed
    //         NewsFileHelper().saveNews(context, _articleController!, formKey);
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
    _articleController!.dispose(); // Dispose the TextEditingController
    _scrollController.dispose(); // Dispose the ScrollController
    _focusTitle.dispose(); // Dispose the title focus node
    _focusContent.dispose(); // Dispose the content focus node
    super.dispose();
  }

  void _renderMarkdown() {
    setState(() {
      data = _articleController!.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EditScrollView(
      formKey: formKey,
      articleController: _articleController,
      scrollController: _scrollController,
      scaffoldController: _scaffoldController,
      focusTitle: _focusTitle,
      focusContent: _focusContent,
      childPage: ListMyNewsScreen(
        scaffoldController: _scaffoldController,
      ),
      data: data,
    );
  }
}
