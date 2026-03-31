/// Individual's POD content variables.
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

const newsFileNamePrefix = 'news-';

// IRIs (Internationalized Resource Identifiers).
//
// 20251001 gjw Split the string to avoid lychee link check excluded.
//
// 20251001 jess The exclusions could be made as special cases in ci.yaml,
// flutter.mk.
//
// 20251001 gjw But those are tempalted files and checking for special cases
// there is awkward.

String communitypodTerms = 'https://solidcommunity.au/' 'predicates/terms#';

String createdDateTimePred = 'createdDateTime';
String createdDateTimePredErr = 'createdDateERROR';
String modifiedDateTimePred = 'modifiedDateTime';
String newsContentPred = 'newsContent';
String newsTitlePred = 'newsTitle';
//String encNewsContentPred = 'encNewsContent';
String mePred = ':me';
// 20251006 jess Keep meKey as ref, even though mePred is shorthand
// String meKey = '#me';

// All news details
String newsUrlPred = 'newsUrl';
String newsFileNamePred = 'newsFileName';
String newsOwnerPred = 'newsOwner';
String contentPred = 'content';
String isSelectedPred = 'isSelected';

// Shared news details
String sharedTimePred = 'sharedTime';
String permissionGranterPred = 'permissionGranter';
String permissionRecepientPred = 'permissionRecepient';
String permissionTypePred = 'permissionType';
String permissionListPred = 'permissionList';

// Set up encrypted news file content
String genNewsTTLStr(
  String createdTimeStr,
  String updatedTimeStr,
  String newsTitle,
  String newsContent,
) {
  String newsTTLStr = '''@prefix : <#>.
      @prefix foaf: <$foaf>.
      @prefix terms: <$terms>.
      @prefix communitypodTerms: <$communitypodTerms>.
      $mePred
          a foaf:PersonalProfileDocument;
          terms:title "News";
          communitypodTerms:$createdDateTimePred "$createdTimeStr";
          communitypodTerms:$modifiedDateTimePred "$updatedTimeStr";
          communitypodTerms:$newsTitlePred "$newsTitle";
          communitypodTerms:$newsContentPred "$newsContent".''';

  // 20251008 jm: code to generate a corrupt news file
  // for testing purposes only.
  // Generates TTL with incorrect predicate
  String newsTTLStrErr = '';
  // String newsTTLStrErr = '''@prefix : <#>.
  //     @prefix foaf: <$foaf>.
  //     @prefix terms: <$terms>.
  //     @prefix communitypodTerms: <$communitypodTerms>.
  //     $mePred
  //         a foaf:PersonalProfileDocument;
  //         terms:title "News";
  //         communitypodTerms:$createdDateTimePredErr "$createdTimeStr";
  //         communitypodTerms:$modifiedDateTimePred "$updatedTimeStr";
  //         communitypodTerms:$newsTitlePred "$newsTitle";
  //         communitypodTerms:$newsContentPred "$newsContent".''';

  final String chosenTTL;
  // // Choose erroneous TTL
  // chosenTTL = newsTTLStrErr;
  // Choose correct TTL
  chosenTTL = newsTTLStr;

  if (chosenTTL == newsTTLStrErr) {
    debugPrint(
      'Writing news file using incorrect predicate $createdDateTimePredErr',
    );
  } else if (chosenTTL == newsTTLStr) {
    debugPrint('Writing news file using correct predicates');
  }

  return chosenTTL;
  // return newsTTLStr;
}
