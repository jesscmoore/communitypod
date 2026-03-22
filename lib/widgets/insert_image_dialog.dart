/// A dialog for inserting an image into the markdown editor.
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:universal_io/io.dart';

import 'package:communitypod/utils/pod_image_uploader.dart';

/// A dialog that allows inserting an image into the markdown note either by
/// entering a URL (URL tab) or by picking a file from the device and uploading
/// it encrypted to the user's Pod (From Device tab).
///
/// The resulting markdown `![alt](url)` is inserted into [noteController] at
/// the current cursor position.

class InsertImageDialog extends StatefulWidget {
  const InsertImageDialog({
    super.key,
    required this.noteController,
    this.isExternal = false,
  });

  final TextEditingController noteController;
  final bool isExternal;

  @override
  State<InsertImageDialog> createState() => _InsertImageDialogState();
}

class _InsertImageDialogState extends State<InsertImageDialog>
    with SingleTickerProviderStateMixin {
  // --- shared ---
  late final TabController _tabController;
  final _altController = TextEditingController();

  // --- URL tab ---
  final _urlController = TextEditingController();
  String? _urlError;
  bool _isValidatingUrl = false;

  // --- Device tab ---
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _uploadedPodUrl;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _altController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Shared: insert markdown snippet into the note at the cursor position.
  // ---------------------------------------------------------------------------

  void _insertSnippet(String url) {
    final alt = _altController.text.trim();
    final snippet = '![${alt.isEmpty ? 'image' : alt}]($url)';

    final controller = widget.noteController;
    final text = controller.text;
    final sel = controller.selection;
    final insertPos = sel.isValid ? sel.baseOffset : text.length;
    final end = sel.isValid
        ? sel.extentOffset.clamp(insertPos, text.length)
        : insertPos;

    controller.value = TextEditingValue(
      text: text.replaceRange(insertPos, end, snippet),
      selection: TextSelection.collapsed(offset: insertPos + snippet.length),
    );

    Navigator.of(context).pop();
  }

  // ---------------------------------------------------------------------------
  // URL tab
  // ---------------------------------------------------------------------------

  Future<void> _onInsertUrl() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() => _urlError = 'Please enter an image URL.');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      setState(
        () => _urlError = 'Please enter a valid URL (e.g. https://...).',
      );
      return;
    }

    // Check that the URL actually serves image content via a HEAD request.
    setState(() {
      _isValidatingUrl = true;
      _urlError = null;
    });

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request =
          await client.headUrl(uri).timeout(const Duration(seconds: 5));
      final response =
          await request.close().timeout(const Duration(seconds: 5));
      await response.drain<void>();
      client.close();

      final contentType = response.headers.value('content-type') ?? '';
      if (!contentType.startsWith('image/')) {
        if (!mounted) return;
        setState(() {
          _urlError =
              'URL does not point to an image (content-type: "$contentType").'
              ' Use a direct image link ending in .jpg, .png, etc.';
          _isValidatingUrl = false;
        });
        return;
      }
    } catch (_) {
      // Network error or CORS on web — skip validation and allow insertion.
    }

    if (!mounted) return;
    setState(() => _isValidatingUrl = false);
    _insertSnippet(url);
  }

  Widget _urlTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _altController,
          decoration: const InputDecoration(
            labelText: 'Alt Text (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        if (_isValidatingUrl)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Checking URL…'),
              ],
            ),
          ),
        if (_urlError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _urlError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Device tab
  // ---------------------------------------------------------------------------

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    setState(() {
      _selectedFilePath = file.path;
      _selectedFileName = file.name;
      _uploadedPodUrl = null;
      _uploadError = null;
    });
  }

  Future<void> _uploadFile() async {
    setState(() {
      _isUploading = true;
      _uploadError = null;
    });
    try {
      final ext = _selectedFileName!.split('.').last.toLowerCase();
      final url = await uploadImageToPod(
        localFilePath: _selectedFilePath!,
        fileExtension: ext,
      );
      setState(() {
        _uploadedPodUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _uploadError = 'Upload failed: $e';
        _isUploading = false;
      });
    }
  }

  Widget _deviceTab() {
    if (widget.isExternal) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Images can only be saved to your own Pod.\n'
          'This note is externally owned — use the URL tab instead.',
        ),
      );
    }

    if (kIsWeb) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Image upload from device is not supported on web.\n'
          'Please use the URL tab instead.',
        ),
      );
    }

    if (_isUploading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Uploading to Pod...'),
          ],
        ),
      );
    }

    if (_uploadedPodUrl != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text('Uploaded: $_selectedFileName')),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _altController,
            decoration: const InputDecoration(
              labelText: 'Alt Text (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }

    if (_selectedFilePath != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected: $_selectedFileName'),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload to Pod'),
            onPressed: _uploadFile,
          ),
          if (_uploadError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _uploadError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      );
    }

    return ElevatedButton.icon(
      icon: const Icon(Icons.folder_open_outlined),
      label: const Text('Pick Image'),
      onPressed: _pickFile,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDeviceTab = _tabController.index == 1;
    final canInsert = isDeviceTab ? _uploadedPodUrl != null : !_isValidatingUrl;

    return AlertDialog(
      title: const Text('Insert Image'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              tabs: const [Tab(text: 'URL'), Tab(text: 'From Device')],
            ),
            const SizedBox(height: 12),
            // Fixed-height container so the dialog doesn't jump between tabs.
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                return _tabController.index == 0 ? _urlTab() : _deviceTab();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return TextButton(
              onPressed: canInsert
                  ? () {
                      if (_tabController.index == 0) {
                        _onInsertUrl();
                      } else {
                        _insertSnippet(_uploadedPodUrl!);
                      }
                    }
                  : null,
              child: const Text('Insert'),
            );
          },
        ),
      ],
    );
  }
}
