/// A stateful widget to display a news post card.
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

import 'package:solidui/solidui.dart';

import 'package:communitypod/constants/app.dart';
import 'package:communitypod/models/news.dart';
import 'package:communitypod/news/non_readable_news_post.dart';
import 'package:communitypod/news/view_news.dart';
import 'package:communitypod/widgets/highlight_image.dart';
import 'package:communitypod/widgets/item_subtitle.dart';
import 'package:communitypod/widgets/item_title.dart';
import 'package:communitypod/widgets/item_trailing_buttons.dart';

/// A [stateful] widget to display a news post card.
///
/// Arguments:
/// - [item] - The news post to display.
/// - [isNarrow] - Whether the window is narrower than the narrow threshold.
/// - [scaffoldController] - Controller for the Solid scaffold.
/// - [onSelectPressed] - Callback invoked when the select button is pressed.

class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.isNarrow,
    required this.scaffoldController,
    required this.onSelectPressed,
  });

  final News item;
  final bool isNarrow;
  final SolidScaffoldController scaffoldController;
  final VoidCallback onSelectPressed;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HighlightImage(
            imageUrl: widget.item.permissionList.contains('read')
                ? widget.item.content?.highlightImageUrl
                : null,
          ),
          Center(
            child: Container(
              decoration: widget.item.isSelected
                  ? BoxDecoration(
                      color: theme.colorScheme.onInverseSurface,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                    )
                  : const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
              child: ListTile(
                leading: SizedBox(
                  width: NewsIconSize.width,
                  child: Center(
                    child: Ink(
                      decoration: buttonShapeList,
                      child: IconButton(
                        icon: widget.item.isSelected
                            ? const Icon(Icons.done)
                            : const Icon(Icons.edit_document),
                        onPressed: widget.onSelectPressed,
                      ),
                    ),
                  ),
                ),
                title: ItemTitle(
                  item: widget.item,
                  isNarrow: widget.isNarrow,
                ),
                subtitle: ItemSubtitle(
                  item: widget.item,
                  isNarrow: widget.isNarrow,
                ),
                trailing: SizedBox(
                  height: 60,
                  width: 120,
                  child: ItemTrailingButtons(
                    item: widget.item,
                    scaffoldController: widget.scaffoldController,
                  ),
                ),
                onTap: () {
                  final access = widget.item.permissionList;
                  if (access.contains('read')) {
                    widget.scaffoldController.navigateToSubpage(
                      ViewNews(
                        newsPost: widget.item,
                        scaffoldController: widget.scaffoldController,
                      ),
                    );
                  } else {
                    widget.scaffoldController.navigateToSubpage(
                      NonReadableNewsPost(
                        newsPost: widget.item,
                        scaffoldController: widget.scaffoldController,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
