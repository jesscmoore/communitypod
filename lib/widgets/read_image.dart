/// A custom markdown image builder that handles encrypted Pod images.
///
// Time-stamp: <Saturday 2026-03-21 00:00:00 +1100 Graham Williams>
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

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:markdown_widget/markdown_widget.dart';
import 'package:solidpod/solidpod.dart';

import 'package:communitypod/models/embedded_image.dart';
import 'package:communitypod/utils/image_helper.dart';

/// Returns an [ImgBuilder] for use with [ImgConfig] in a [MarkdownBlock].
///
/// Pod images (URLs under basePath) are fetched and decrypted via
/// [readLargeFileAsBytes] and rendered with [Image.memory]. All other URLs
/// are rendered with [Image.network].
///
/// If [cache] is provided, bytes are read from it on first access and stored
/// in it after fetching, avoiding repeated network/file reads.
ImgBuilder readImage([List<EmbeddedImage>? cache]) {
  return (String url, Map<String, String> attributes) {
    final remotePath = extractPodImagePath(url);
    if (remotePath == null) {
      return Center(
        child: Image.network(
          url,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image_outlined, size: 48),
        ),
      );
    }
    Uint8List? cachedData;
    if (cache != null) {
      for (final img in cache) {
        if (img.imageUrl == url) {
          cachedData = img.imageData;
          break;
        }
      }
    }
    if (cachedData != null) {
      return Center(
        child: Image.memory(
          cachedData,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image_outlined, size: 48),
        ),
      );
    }
    return FutureBuilder<Uint8List>(
      future: readLargeFileAsBytes(remoteFilePath: remotePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 80,
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const Icon(Icons.broken_image_outlined, size: 48);
        }
        cache?.add(EmbeddedImage(imageUrl: url, imageData: snapshot.data!));
        return Center(
          child: Image.memory(
            snapshot.data!,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image_outlined, size: 48),
          ),
        );
      },
    );
  };
}
