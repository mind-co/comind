import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComindColors {
  // Old version
  // static const Color primaryColor = Color.fromRGBO(0, 136, 200, 100);
  // static const Color secondaryColor = Color.fromRGBO(207, 94, 74, 100);
  // static const Color tertiaryColor = Color.fromRGBO(0, 152, 118, 100);

  // New version that intializes the colors to the
  // above but can be modified
  static const Color primaryColor = Color.fromRGBO(0, 136, 200, 1.0);
  static const Color secondaryColor = Color.fromRGBO(207, 94, 74, 1.0);
  static const Color tertiaryColor = Color.fromRGBO(0, 152, 118, 1.0);
  static ColorScheme colorScheme = const ColorScheme(
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: tertiaryColor,
    surface: tertiaryColor,
    background: Colors.white,
    error: secondaryColor,
    onPrimary: textColor,
    onSecondary: textColor,
    onSurface: textColor,
    onBackground: textColor,
    onError: textColor,
    brightness: Brightness.light,
    surfaceVariant: Color.fromRGBO(239, 239, 239, 1),
  );

  static ColorScheme darkColorScheme = const ColorScheme(
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: tertiaryColor,
    surface: tertiaryColor,
    background: Color.fromRGBO(34, 34, 34, 1),
    error: secondaryColor,
    onPrimary: darkTextColor,
    onSecondary: darkTextColor,
    onSurface: darkTextColor,
    onBackground: darkTextColor,
    onError: darkTextColor,
    brightness: Brightness.dark,
    surfaceVariant: Color.fromRGBO(52, 52, 52, 1),
  );

  // Text themes
  // Ignore formatted
  static TextTheme textTheme = TextTheme(
      // Nunito is good

      // bodyMedium: GoogleFonts.assistant(
      // bodyMedium: GoogleFonts.questrial(
      bodyMedium: GoogleFonts.questrial(
    // bodyMedium: GoogleFonts.nunito(
    fontWeight: FontWeight.w400,
    fontSize: 16,
  ));

  static const Color textColor = Colors.black;
  static const Color darkTextColor = Color.fromARGB(255, 220, 220, 220);

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
