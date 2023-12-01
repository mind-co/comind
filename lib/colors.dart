import 'package:flutter/material.dart';

class ComindColors {
  // Old version
  // static const Color primaryColor = Color.fromRGBO(0, 136, 200, 100);
  // static const Color secondaryColor = Color.fromRGBO(207, 94, 74, 100);
  // static const Color tertiaryColor = Color.fromRGBO(0, 152, 118, 100);

  // New version that intializes the colors to the
  // above but can be modified
  static const Color primaryColor = const Color.fromRGBO(0, 136, 200, 1.0);
  static const Color secondaryColor = const Color.fromRGBO(207, 94, 74, 1.0);
  static const Color tertiaryColor = const Color.fromRGBO(0, 152, 118, 1.0);
  static ColorScheme colorScheme = ColorScheme(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: tertiaryColor,
    background: Colors.white,
    error: secondaryColor,
    onPrimary: textColor,
    onSecondary: textColor,
    onSurface: textColor,
    onBackground: textColor,
    onError: textColor,
    brightness: Brightness.light,
  );

  static ColorScheme darkColorScheme = ColorScheme(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: tertiaryColor,
    background: const Color.fromRGBO(34, 34, 34, 1),
    error: secondaryColor,
    onPrimary: darkTextColor,
    onSecondary: darkTextColor,
    onSurface: darkTextColor,
    onBackground: darkTextColor,
    onError: darkTextColor,
    brightness: Brightness.dark,
  );

  static const Color textColor = Colors.black;
  static const Color darkTextColor = Colors.white;

  // Add color setting method
  // static void setColors(Color primary, Color secondary, Color tertiary) {
  //   primaryColor = primary;
  //   secondaryColor = secondary;
  //   tertiaryColor = tertiary;
  // }

  // Add color reset method
  // static void resetColors() {
  //   primaryColor = const Color.fromRGBO(0, 136, 200, 1.0);
  //   secondaryColor = const Color.fromRGBO(207, 94, 74, 1.0);
  //   tertiaryColor = const Color.fromRGBO(0, 152, 118, 1.0);
  // }

  // Add color scheme generation method
  static List<Color> generateSplitComplementaryColors(Color primaryColor) {
    // Extract RGB values from the primaryColor
    int primaryRed = primaryColor.red;
    int primaryGreen = primaryColor.green;
    int primaryBlue = primaryColor.blue;

    // Calculate split-complementary colors
    Color secondaryColor1 = Color.fromRGBO(
        primaryRed, (primaryGreen + 128) % 256, (primaryBlue + 128) % 256, 1.0);
    Color secondaryColor2 = Color.fromRGBO(
        (primaryRed + 128) % 256, primaryGreen, (primaryBlue + 128) % 256, 1.0);

    return [primaryColor, secondaryColor1, secondaryColor2];
  }

  // Method to get text color based on current background
  static Color getTextColorBasedOnBackground(Color backgroundColor) {
    // Calculate the luminance of the background color
    double luminance = backgroundColor.computeLuminance();

    // If the luminance is greater than 0.5, return dark text color
    if (luminance < 0.5) {
      return darkTextColor;
    } else {
      return textColor;
    }
  }
}
