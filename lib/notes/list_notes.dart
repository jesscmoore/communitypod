/// A stateful widget to list notes.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
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
/// Authors: Anushka Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:communitypod/constants/app.dart';
import 'package:communitypod/constants/ui.dart';
import 'package:communitypod/models/note.dart';
import 'package:communitypod/models/selected_note.dart';
import 'package:communitypod/notes/list_notes_screen.dart';
import 'package:communitypod/notes/non_readable_note.dart';
import 'package:communitypod/notes/view_note.dart';
import 'package:communitypod/widgets/note_highlight_image.dart';
import 'package:communitypod/widgets/note_item_subtitle.dart';
import 'package:communitypod/widgets/note_item_trailing_buttons.dart';
import 'package:communitypod/widgets/note_list_del_button.dart';

/// A [stateful] widget to list notes accessible to the
/// user.
///
/// Arguments:
/// - [notes] - The notes accessible to the user.
/// - [title] - List title.
/// - [scaffoldController] - Controller for the Solid scaffold.

class ListNews extends StatefulWidget {
  final List<News> notes;
  final String title;
  final SolidScaffoldController scaffoldController;

  const ListNews({
    super.key,
    required this.notes,
    required this.title,
    required this.scaffoldController,
  });

  @override
  State<ListNews> createState() => _ListNewsState();
}

class _ListNewsState extends State<ListNews> {
  /// Filtered map of notes.
  List<News> _foundNews = [];

  /// Selected notes
  final List<SelectedNews> selectedNews = [];

  /// Sort title order
  /// true: ascending (A-Z), false: descending (Z-A)
  /// Initial sort will sort alphabetically
  bool _sortTitleAscending = true;

  /// Sort last modified date order
  /// true: ascending (oldest modified note), false: descending (last modified note)
  /// First button press will change to sort by last modified first
  bool _sortModDateAscending = true;

  /// Initial sort by note filename order.
  bool _sortFilenameAscending = true;

  /// Initial sort by note owner order.
  bool _sortOwnerAscending = true;

  /// Initial sort by note owner order.
  bool _sortPermissionAscending = true;

  /// News selection mode
  /// true: when one or more notes have been selected, false by default
  bool _isSelectionMode = false;

  /// Count of selected notes
  int selectedCount = 0;

  /// Whether selection includes external files
  /// true: when one or more external notes have been selected, false by default
  bool _isExtFileSelected = false;

  /// Count of selected external notes
  int extSelectedCount = 0;

  /// Current note sort method
  /// Initialised to sort by title
  String currSortMethod = '';

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// Boolean describing whether window is wide
  late bool isWide;

  /// Boolean describing whether window is very wide
  late bool isVeryWide;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;

    // By default _foundNews is the full list of notes
    _foundNews = widget.notes;

    // Initial sort by title alphabetically
    _sortByTitle(_sortTitleAscending);

    // Initialise sorting method
    currSortMethod = 'sortByTitle';
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  // Sort alphanumerically on note title field, with null values last
  void _sortByTitle(bool ascending) {
    setState(() {
      _sortTitleAscending = ascending;
      _foundNews.sort((a, b) {
        if (a.content == null && b.content == null) return 0;
        if (a.content == null) return 1;
        if (b.content == null) return -1;
        return _sortTitleAscending
            ? a.content!.newsTitle
                .toLowerCase()
                .compareTo(b.content!.newsTitle.toLowerCase())
            : b.content!.newsTitle
                .toLowerCase()
                .compareTo(a.content!.newsTitle.toLowerCase());
      });

      // Update current sort method
      currSortMethod = 'sortByTitle';
    });
  }

  // Sort numerically on note modified date field, with null values last
  void _sortByModDate(bool ascending) {
    setState(() {
      _sortModDateAscending = ascending;
      _foundNews.sort((a, b) {
        if (a.content == null && b.content == null) return 0;
        if (a.content == null) return 1;
        if (b.content == null) return -1;
        return _sortModDateAscending
            ? a.content!.modifiedDateTime
                .toLowerCase()
                .compareTo(b.content!.modifiedDateTime.toLowerCase())
            : b.content!.modifiedDateTime
                .toLowerCase()
                .compareTo(a.content!.modifiedDateTime.toLowerCase());
      });

      // Update current sort method
      currSortMethod = 'sortByModDate';
    });
  }

  /// Sort alphanumerically on note filename
  void _sortByFilename(bool ascending) {
    setState(() {
      _sortFilenameAscending = ascending;
      _foundNews.sort(
        (a, b) => _sortFilenameAscending
            ? a.newsFileName
                .toLowerCase()
                .compareTo(b.newsFileName.toLowerCase())
            : b.newsFileName
                .toLowerCase()
                .compareTo(a.newsFileName.toLowerCase()),
      );

      // Update current sort method
      currSortMethod = 'sortByFilename';
    });
  }

  /// Sort alphanumerically on note owner
  void _sortByOwner(bool ascending) {
    setState(() {
      _sortOwnerAscending = ascending;

      _foundNews.sort(
        (a, b) => _sortOwnerAscending
            ? a.newsOwner.toLowerCase().compareTo(b.newsOwner.toLowerCase())
            : b.newsOwner.toLowerCase().compareTo(a.newsOwner.toLowerCase()),
      );

      // Update current sort method
      currSortMethod = 'sortByOwner';
    });
  }

  /// Sort alphanumerically on note permissions
  void _sortByPermission(bool ascending) {
    setState(() {
      _sortPermissionAscending = ascending;

      _foundNews.sort(
        (a, b) => _sortPermissionAscending
            ? a.permissionList
                .toLowerCase()
                .compareTo(b.permissionList.toLowerCase())
            : b.permissionList
                .toLowerCase()
                .compareTo(a.permissionList.toLowerCase()),
      );

      // Update current sort method
      currSortMethod = 'sortByPermission';
    });
  }

  /// Search notes
  void _searchNews(String enteredKeyword) {
    List<News> results = [];
    if (enteredKeyword.isEmpty) {
      // Display all notes if no search string
      results = widget.notes;
    } else {
      // Search for matches in filename, owner, permission granter or permission list
      results = widget.notes.where((note) {
        return (note.content?.newsTitle ?? 'unknown')
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            (note.content?.newsContent ?? 'unknown')
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.newsFileName
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.newsOwner
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            (note.permissionGranter ?? 'n/a')
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.permissionList
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    // Refresh the UI
    setState(() {
      _foundNews = results;

      // // Sort results by filename
      // _sortByFilename(_sortFilenameAscending);
    });

    // Sort by current sort method and polarity
    switch (currSortMethod) {
      case 'sortByTitle':
        _sortByTitle(_sortTitleAscending);
      case 'sortByModDate':
        _sortByModDate(_sortModDateAscending);
      case 'sortByFilename':
        _sortByFilename(_sortFilenameAscending);
      case 'sortByOwner':
        _sortByOwner(_sortOwnerAscending);
      case 'sortByPermission':
        _sortByPermission(_sortPermissionAscending);
    }
  }

  /// Update selected status and count of selected and add/remove note from
  /// selected notes list
  void updateSelected(int index) {
    setState(() {
      if (_foundNews[index].isSelected) {
        // Decrement selected count
        selectedCount--;
        if (_foundNews[index].isExternalRes) {
          extSelectedCount--;
        }

        // Remove note from selected notes list
        selectedNews.removeWhere(
          (item) => item.newsFileName == _foundNews[index].newsFileName,
        );
      } else {
        // Increment count
        selectedCount++;
        if (_foundNews[index].isExternalRes) {
          extSelectedCount++;
        }
        // Add note to selected notes list
        selectedNews.add(
          SelectedNews(
            newsFileName: _foundNews[index].newsFileName,
            newsUrl: _foundNews[index].newsUrl,
            newsOwner: _foundNews[index].newsOwner,
          ),
        );
      }
      // Swap selected status of file
      _foundNews[index].isSelected = !_foundNews[index].isSelected;

      debugPrint('Selected notes:');
      for (final SelectedNews selectedNewsPost in selectedNews) {
        debugPrint(selectedNewsPost.newsFileName);
      }
    });
  }

  /// Update multiple note selection mode
  void updateSelectionMode(bool selectionMode, int index) {
    setState(() {
      debugPrint(
        '_isSelectionMode before: $selectionMode, selectedCount: ${selectedCount.toString()}, extSelectedCount: ${extSelectedCount.toString()} isSelected: ${_foundNews[index].isSelected}',
      );

      // Turn off selection mode if deselected only selected note
      // else turn on selection mode
      if (_foundNews[index].isSelected && selectedCount == 1) {
        _isSelectionMode = false;
      } else {
        _isSelectionMode = true;
      }

      // Turn on external file selected
      if (_foundNews[index].isSelected &&
          _foundNews[index].isExternalRes &&
          extSelectedCount == 1) {
        // Turn off if the last selected external file has been deselected
        _isExtFileSelected = false;
      } else if (_isSelectionMode && _foundNews[index].isExternalRes) {
        // Ensure on if any external file is selected
        _isExtFileSelected = true;
      }
      debugPrint('_isSelectionMode after: $_isSelectionMode');
      debugPrint('_isExtFileSelected after: $_isExtFileSelected');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reduce calls to of(context).
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Derive whether window is narrow
        isNarrow = WindowSize().isNarrowWindow(constraints);
        // Derive whether window wide
        isWide = DisplayHelpers.isWideScreen(
          context,
        );
        // Derive whether window very wide
        isVeryWide = DisplayHelpers.isVeryWideScreen(
          context,
        );
        return SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) => _searchNews(value),
                      decoration: const InputDecoration(
                        labelText: 'Search news',
                        hintText:
                            'Enter text to match title, content, or properties of news post files',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Count statement
                        // Match color scheme of sorting TextButtons
                        selectedCount > 0
                            ? Text(
                                selectedCount > 1
                                    ? 'Selected: $selectedCount news posts'
                                    : 'Selected: $selectedCount news post',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : _foundNews.length > 1 || _foundNews.isEmpty
                                ? Text(
                                    'Found ${_foundNews.length} news posts',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : Text(
                                    'Found ${_foundNews.length} news post',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: (!isNarrow) ? 3.0 : 0,
                          children: [
                            // Multiple note delete button
                            // Only display multi note delete
                            // button when notes are selected causing
                            // isSelectionMode=true
                            // icon shows as inactive if _isExtFileSelect=true
                            if (_isSelectionMode) ...[
                              // Multi note delete button
                              NewsListDelButton(
                                selectedNews: selectedNews,
                                // Reload list after note deletion
                                childPage: ListNewsScreen(
                                  scaffoldController: _scaffoldController,
                                ),
                                scaffoldController: _scaffoldController,
                                isSelectionMode: _isSelectionMode,
                                isExtFileSelected: _isExtFileSelected,
                              ),
                            ],
                            // Title Sort Label and Button
                            TextButton.icon(
                              onPressed: () {
                                _sortByTitle(!_sortTitleAscending);
                              },
                              icon: Icon(
                                _sortTitleAscending
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                              ),
                              label: const Text(
                                'Title',
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            // Date Sort Label and Button
                            TextButton.icon(
                              onPressed: () {
                                _sortByModDate(!_sortModDateAscending);
                              },
                              icon: Icon(
                                _sortModDateAscending
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                              ),
                              label: Text(
                                (!isNarrow) ? 'Date Modified' : 'Date',
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            // Filename Sort Label and Button
                            // Only display filename sort
                            // when window is not narrow
                            if (!isNarrow) ...[
                              TextButton.icon(
                                onPressed: () {
                                  _sortByFilename(!_sortFilenameAscending);
                                },
                                icon: Icon(
                                  _sortFilenameAscending
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                ),
                                label: const Text(
                                  'Filename',
                                ),
                                iconAlignment: IconAlignment.end,
                              ),
                            ],
                            if (isWide || isVeryWide) ...[
                              // Owner Sort Label and Button
                              TextButton.icon(
                                onPressed: () {
                                  _sortByOwner(!_sortOwnerAscending);
                                },
                                icon: Icon(
                                  _sortOwnerAscending
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                ),
                                label: const Text(
                                  'Owner',
                                ),
                                iconAlignment: IconAlignment.end,
                              ),
                            ],
                            // Only display permissions sort
                            // when window is not narrow
                            if (isVeryWide) ...[
                              // Permission Sort Label and Button
                              TextButton.icon(
                                onPressed: () {
                                  _sortByPermission(!_sortPermissionAscending);
                                },
                                icon: Icon(
                                  _sortPermissionAscending
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                ),
                                label: const Text(
                                  'Permission',
                                ),
                                iconAlignment: IconAlignment.end,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: _foundNews.length,
                    itemBuilder: (context, index) => Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HighlightImage(
                            imageUrl: _foundNews[index]
                                    .permissionList
                                    .contains('read')
                                ? _foundNews[index].content?.highlightImageUrl
                                : null,
                          ),
                          Center(
                            child: Container(
                              // Show color decoration when selected
                              decoration: _foundNews[index].isSelected
                                  ? BoxDecoration(
                                      color: theme.colorScheme.onInverseSurface,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    )
                                  : const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                              child: ListTile(
                                // Select and count selected notes, including whether
                                // an externally owned note is selected
                                leading: SizedBox(
                                  width: NewsIconSize.width,
                                  child: Center(
                                    child: Ink(
                                      decoration: buttonShapeList,
                                      child: IconButton(
                                        icon: _foundNews[index].isSelected
                                            ? const Icon(Icons.done)
                                            : const Icon(Icons.edit_document),
                                        onPressed: () {
                                          updateSelectionMode(
                                            _isSelectionMode,
                                            index,
                                          );
                                          updateSelected(index);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                // News post info
                                title: (_foundNews[index]
                                        .permissionList
                                        .contains('read'))
                                    ? Text(
                                        _foundNews[index].content!.newsTitle,
                                        maxLines:
                                            (!isNarrow) ? 1 : 3, // Limit lines
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : const Text(''),
                                // News post item subtitle
                                subtitle: ItemSubtitle(
                                  note: _foundNews[index],
                                  isNarrow: isNarrow,
                                ),
                                // Define width to avoid consuming full width
                                trailing: SizedBox(
                                  height: 60,
                                  width: 120,
                                  child: ItemTrailingButtons(
                                    note: _foundNews[index],
                                    scaffoldController: _scaffoldController,
                                  ),
                                ),

                                onTap: () {
                                  // Open note if read in permissions
                                  String access =
                                      _foundNews[index].permissionList;
                                  if (access.contains('read')) {
                                    _scaffoldController.navigateToSubpage(
                                      ViewNews(
                                        note: _foundNews[index],
                                        scaffoldController: _scaffoldController,
                                      ),
                                    );
                                  } else {
                                    _scaffoldController.navigateToSubpage(
                                      NonReadableNews(
                                        note: _foundNews[index],
                                        scaffoldController: _scaffoldController,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
