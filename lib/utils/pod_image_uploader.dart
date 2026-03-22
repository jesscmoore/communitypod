/// Utilities for uploading images to and identifying images on a Solid Pod.
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

import 'package:solidpod/solidpod.dart';

/// Uploads the file at [localFilePath] to the Pod as an encrypted image.
///
/// The image is stored at `images/img-{timestamp}.[fileExtension]` relative
/// to the app data directory (`notepod/data/`). Returns the full Pod resource
/// URL for embedding in markdown as `![alt](url)`.
Future<String> uploadImageToPod({
  required String localFilePath,
  required String fileExtension,
}) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final remotePath = 'images/img-$timestamp.$fileExtension';

  await writeLargeFile(
    localFilePath: localFilePath,
    remoteFilePath: remotePath,
    encrypted: true,
  );

  // filenameToResourceUrl prepends notepod/data/ automatically, producing
  // a full URL like https://user.pod/notepod/data/images/img-xxx.jpg
  return filenameToResourceUrl(fileName: remotePath);
}

/// Returns `true` if [url] points to an image stored on the user's Pod
/// (i.e. under the `notepod/data/` path).
bool isPodImageUrl(String url) => extractPodImagePath(url) != null;

/// Extracts the `remoteFilePath` (relative to `notepod/data/`) from a full
/// Pod image URL, or returns `null` if [url] is not a Pod image URL.
///
/// Example:
/// `"https://alice.pod/notepod/data/images/img-x.jpg"` → `"images/img-x.jpg"`
String? extractPodImagePath(String url) {
  const marker = '/notepod/data/';
  final idx = url.indexOf(marker);
  if (idx == -1) return null;
  return url.substring(idx + marker.length);
}
