import 'package:flutter/material.dart';

const kRoboto = 'Roboto';
const kPlayfairDisplay = 'PlayfairDisplay';

const kColorWhite = Color(0xFFFFFFFF);
const kColorDarkerWhite = Color(0xFFF7F7F7);
const kColorGrey = Color(0xFF424549);
const kColorLighterGrey = Color(0xFF555555);
const kColorYellow = Color(0xFFFFCC00);

const kEmptyPreviewText = TextStyle(
  fontFamily: kRoboto,
  color: kColorWhite,
);

const kResultText = TextStyle(
  fontFamily: kPlayfairDisplay,
  fontWeight: FontWeight.bold,
  fontSize: 35.0,
);

const kResultRating = TextStyle(
  fontFamily: kRoboto,
  fontSize: 18.0,
);

const kResultDetail = TextStyle(
  fontFamily: kRoboto,
  color: kColorLighterGrey,
);

const kPickImageButton = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll(kColorYellow),
);

const kPickImageButtonText = TextStyle(
  fontFamily: kRoboto,
  fontSize: 18.0,
);