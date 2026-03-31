/// Data model for a cached image entry.
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

/// A data model pairing an image URL with its fetched and decoded bytes.

class EmbeddedImage {
  const EmbeddedImage({
    required this.imageUrl,
    required this.imageData,
  });

  final String imageUrl;
  final Uint8List imageData;
}
