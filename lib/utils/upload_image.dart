/// Upload image to a Solid Pod.
///
// Time-stamp: <Saturday 2026-03-22 21:48:20 +1100 Graham Williams>
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
/// to the app data directory (basePath). Returns the full Pod resource
/// URL for embedding in markdown as `![alt](url)`.
Future<String> uploadImage({
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

  // filenameToResourceUrl prepends basePath automatically, producing
  // a full URL like https://user.pod/communitypod/data/images/img-xxx.jpg
  return filenameToResourceUrl(fileName: remotePath);
}
