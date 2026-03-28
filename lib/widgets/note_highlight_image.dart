/// A stateless widget to show a highlight image thumbnail for a news item card.
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

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:communitypod/utils/image_helper.dart';

/// A [stateless] widget to show a highlight image thumbnail for a news item
/// card.
///
/// Renders the first image found at [imageUrl]. Pod images (URLs under the app
/// data path) are fetched and decrypted via [readLargeFileAsBytes]; external
/// URLs are rendered with [Image.network]. Shows nothing when [imageUrl] is
/// null or when the image cannot be loaded.
///
/// Arguments:
/// - [imageUrl] - URL of the image to display, or null for no image.
///
class NoteHighlightImage extends StatelessWidget {
  const NoteHighlightImage({
    super.key,
    required String? imageUrl,
  }) : _imageUrl = imageUrl;

  final String? _imageUrl;

  /// Height of the thumbnail strip in logical pixels.

  static const double thumbnailHeight = 150;

  @override
  Widget build(BuildContext context) {
    final url = _imageUrl;
    if (url == null) return const SizedBox.shrink();

    final remotePath = extractPodImagePath(url);
    final Widget imageWidget;

    if (remotePath == null) {
      imageWidget = Image.network(
        url,
        height: thumbnailHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    } else {
      imageWidget = FutureBuilder<Uint8List>(
        future: readLargeFileAsBytes(remoteFilePath: remotePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: thumbnailHeight,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return const SizedBox.shrink();
          }
          return Image.memory(
            snapshot.data!,
            height: thumbnailHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
      child: SizedBox(
        height: thumbnailHeight,
        width: double.infinity,
        child: imageWidget,
      ),
    );
  }
}
