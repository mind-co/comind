import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color method type
enum ColorMethod {
  splitComplementary,
  complementary,
  triadic,
  analogous,
  monochromatic
}

class ComindColors {
  // Old version
  static const Color primaryColorDefault = Color.fromRGBO(0, 137, 200, 1);
  static const Color secondaryColorDefault = Color.fromRGBO(207, 94, 74, 1);
  static const Color tertiaryColorDefault = Color.fromRGBO(0, 152, 119, 1);

  // New version that intializes the colors to the
  // above but can be modified
  Color primaryColor = primaryColorDefault;
  Color secondaryColor = secondaryColorDefault;
  Color tertiaryColor = tertiaryColorDefault;

  // Handedness
  bool rightHanded = true;

  void toggleHandedness(bool value) {
    rightHanded = value;
  }

  // What public/private mode the user is in
  bool publicMode = true;

  // Dark mode tracker
  bool darkMode = true;

  ColorScheme _lightScheme = const ColorScheme(
    primary: primaryColorDefault,
    secondary: secondaryColorDefault,
    tertiary: tertiaryColorDefault,
    surface: tertiaryColorDefault,
    background: Colors.white,
    error: secondaryColorDefault,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.black,
    brightness: Brightness.light,
    surfaceVariant: Color.fromRGBO(239, 239, 239, 1),
  );

  ColorScheme _darkScheme = const ColorScheme(
    primary: primaryColorDefault,
    secondary: secondaryColorDefault,
    tertiary: tertiaryColorDefault,
    surface: tertiaryColorDefault,
    background: Color.fromRGBO(8, 8, 8, 1),
    error: secondaryColorDefault,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
    surfaceVariant: Color.fromRGBO(52, 52, 52, 1),
  );

  // get _colorScheme => darkMode ? _darkScheme : _lightScheme;
  // ColorScheme get colorScheme => _darkScheme;
  // ColorScheme get colorScheme => _lightScheme;
  ColorScheme get colorScheme => darkMode ? _darkScheme : _lightScheme;
  // ColorScheme get colorScheme => darkMode ? _darkScheme : _lightScheme;

  // Setter
  set colorScheme(ColorScheme newScheme) {
    if (darkMode) {
      _darkScheme = newScheme;
    } else {
      _lightScheme = newScheme;
    }
  }

  get primary => null;
  get secondary => null;
  get tertiary => null;

  // Init method and set the color scheme
  void init(prim, seco, tert) {
    colorScheme = darkMode ? _darkScheme : _lightScheme;
  }

  // Text themes
  // static final bodyStyle = GoogleFonts.hankenGrotesk(
  // static final bodyStyle = GoogleFonts.ibmPlexSans(
  // Ignore formatted
  static final bodyStyle = GoogleFonts.nunito(
      // static final bodyStyle = GoogleFonts.questrial(
      fontWeight: FontWeight.w400,
      height: 1.2);

  static final titleStyle = GoogleFonts.bungee(
    fontWeight: FontWeight.w400,
    fontSize: 20,
  );

  TextTheme textTheme = TextTheme(
    // Nunito is good

    // Body style
    bodySmall: bodyStyle.copyWith(fontSize: 12),
    bodyMedium: bodyStyle.copyWith(fontSize: 14),
    bodyLarge: bodyStyle.copyWith(fontSize: 16),

    // Title style
    titleSmall: titleStyle.copyWith(fontSize: 14),
    titleMedium: titleStyle.copyWith(fontSize: 16),
    titleLarge: titleStyle.copyWith(fontSize: 18),

    // Header style
    headlineLarge: titleStyle.copyWith(fontSize: 20),
    headlineMedium: titleStyle.copyWith(fontSize: 24),
    headlineSmall: titleStyle.copyWith(fontSize: 28),

    // Display style
    displayLarge: titleStyle.copyWith(fontSize: 32),
    displayMedium: titleStyle.copyWith(fontSize: 36),
    displaySmall: titleStyle.copyWith(fontSize: 40),
  );

  static const Color _textColor = Colors.black;
  static const Color _darkTextColor = Color.fromARGB(255, 220, 220, 220);
  get textColor => darkMode ? _darkTextColor : _textColor;

  // Add color setting method
  void setColors(Color primary, Color secondary, Color tertiary) {
    primaryColor = primary;
    secondaryColor = secondary;
    tertiaryColor = tertiary;
  }

  // Add color reset method
  void resetColors() {
    primaryColor = primaryColorDefault;
    secondaryColor = secondaryColorDefault;
    tertiaryColor = tertiaryColorDefault;
  }

  // Color generating type
  // NOTE triadic is weird rn
  ColorMethod colorMethod = ColorMethod.splitComplementary;

  // Set color generating type
  void setColorMethod(ColorMethod newMethod) {
    colorMethod = newMethod;
  }

  List<Color> generateSplitComplementaryColors(Color primaryColor) {
    // Convert the color to HSL
    HSLColor hslPrimary = HSLColor.fromColor(primaryColor);

    // Calculate the complementary color
    HSLColor complementary = HSLColor.fromAHSL(
      hslPrimary.alpha,
      (hslPrimary.hue + 180) %
          360, // Add 180 degrees to get the complementary hue
      hslPrimary.saturation,
      hslPrimary.lightness,
    );

    // Calculate the split complementary colors, 30 degrees apart from the complementary
    HSLColor splitComp1 = HSLColor.fromAHSL(
      complementary.alpha,
      (complementary.hue + 30) % 360, // Adjust hue by 30 degrees
      complementary.saturation,
      complementary.lightness,
    );
    HSLColor splitComp2 = HSLColor.fromAHSL(
      complementary.alpha,
      (complementary.hue - 30 + 360) % 360, // Adjust hue by -30 degrees
      complementary.saturation,
      complementary.lightness,
    );

    // Convert back to Color objects
    return [primaryColor, splitComp1.toColor(), splitComp2.toColor()];
  }

  List<Color> generateTriadicColors(Color primaryColor) {
    // Convert the color to HSL
    HSLColor hslPrimary = HSLColor.fromColor(primaryColor);

    // Calculate the two triadic colors, 120 degrees apart from the primary color
    HSLColor triadic1 = HSLColor.fromAHSL(
      hslPrimary.alpha,
      (hslPrimary.hue + 120) %
          360, // Add 120 degrees to get the first triadic color
      hslPrimary.saturation,
      hslPrimary.lightness,
    );
    HSLColor triadic2 = HSLColor.fromAHSL(
      hslPrimary.alpha,
      (hslPrimary.hue + 240) %
          360, // Add 240 degrees to get the second triadic color
      hslPrimary.saturation,
      hslPrimary.lightness,
    );

    // Convert back to Color objects and return the triadic color scheme
    return [primaryColor, triadic1.toColor(), triadic2.toColor()];
  }

  List<Color> generateAnalogousColors(Color primaryColor) {
    // Convert the color to HSL
    HSLColor hslPrimary = HSLColor.fromColor(primaryColor);

    // Calculate the two analogous colors, 30 degrees apart from the primary color
    HSLColor analogous1 = HSLColor.fromAHSL(
      hslPrimary.alpha,
      (hslPrimary.hue + 30) %
          360, // Add 30 degrees to get the first analogous color
      hslPrimary.saturation,
      hslPrimary.lightness,
    );
    HSLColor analogous2 = HSLColor.fromAHSL(
      hslPrimary.alpha,
      (hslPrimary.hue - 30 + 360) %
          360, // Subtract 30 degrees to get the second analogous color
      hslPrimary.saturation,
      hslPrimary.lightness,
    );

    // Convert back to Color objects and return the analogous color scheme
    return [primaryColor, analogous1.toColor(), analogous2.toColor()];
  }

  // Add color scheme generation method
  List<Color> setColorScheme(Color primaryColor) {
    // Calculate complementary colors
    // if (colorMethod == ColorMethod.complementary) {
    //   print("Complementary");
    //   return generateComplementaryColors(primaryColor);
    // }

    // Calculate triadic colors
    if (colorMethod == ColorMethod.triadic) {
      print("Triadic");
      return generateTriadicColors(primaryColor);
    }

    // Calculate analogous colors
    if (colorMethod == ColorMethod.analogous) {
      print("Analogous");
      return generateAnalogousColors(primaryColor);
    }

    // Calculate split-complementary colors
    if (colorMethod == ColorMethod.splitComplementary) {
      return generateSplitComplementaryColors(primaryColor);
    }

    // Calculate monocromatic colors
    if (colorMethod == ColorMethod.monochromatic) {
      Color adjustBrightness(Color color, double factor) {
        return Color.fromRGBO(
          (color.red * factor).clamp(0, 255).toInt(),
          (color.green * factor).clamp(0, 255).toInt(),
          (color.blue * factor).clamp(0, 255).toInt(),
          1,
        );
      }

      // Return the list of colors
      return [
        primaryColor,
        adjustBrightness(primaryColor, 2.0),
        adjustBrightness(primaryColor, 2.5)
      ];
    }

    return [
      ComindColors.primaryColorDefault,
      ComindColors.secondaryColorDefault,
      ComindColors.tertiaryColorDefault
    ];
  }

  // Method to get text color based on current background
  // static Color getTextColorBasedOnBackground(Color backgroundColor) {
  //   // Calculate the luminance of the background color
  //   double luminance = backgroundColor.computeLuminance();

  //   // If the luminance is greater than 0.5, return dark text color
  //   if (luminance < 0.5) {
  //     return darkTextColor;
  //   } else {
  //     return textColor;
  //   }
  // }

  // Default constructor for ComindColors
  ComindColors() {
    init(primaryColorDefault, secondaryColorDefault, tertiaryColorDefault);
  }

  // Constructor for ComindColors that takes in a primary color
  ComindColors.fromPrimary(Color primary) {
    final newColors = generateSplitComplementaryColors(primary);
    init(newColors[0], newColors[1], newColors[2]);
  }

  // Modify existing colors with from primar
  void modifyColors(Color primary) {
    final newColors = generateSplitComplementaryColors(primary);
    setColors(newColors[0], newColors[1], newColors[2]);
  }
}

// Notifyer
class ComindColorsNotifier extends ChangeNotifier {
  ComindColors _currentColors = ComindColors();

  // Handedness because why not, also I ain't making a new provider for this shit
  bool get rightHanded => _currentColors.rightHanded;

  ComindColors get currentColors => _currentColors;
  // ColorScheme get colorScheme => _currentColors.colorScheme;
  // If the dark mode is enabled, return the dark color scheme,
  // otherwise return the normal color scheme
  ColorScheme get colorScheme => currentColors.colorScheme;
  Color get background => colorScheme.background;
  Color get primary => colorScheme.primary;
  Color get secondary => colorScheme.secondary;
  Color get tertiary => colorScheme.tertiary;
  Color get surface => colorScheme.surface;
  Color get error => colorScheme.error;
  Color get onPrimary => colorScheme.onPrimary;
  Color get onSecondary => colorScheme.onSecondary;
  Color get onSurface => colorScheme.onSurface;
  Color get onBackground => colorScheme.onBackground;
  Color get onError => colorScheme.onError;
  bool get darkMode => currentColors.darkMode;
  TextTheme get textTheme => currentColors.textTheme;

  // whether in public mode
  bool get publicMode => currentColors.publicMode;

  get textStyle => null;

  set currentColors(ComindColors newColors) {
    print("New colors. Primary is ${newColors.primaryColor}");
    _currentColors = newColors;
    notifyListeners();
  }

  void toggleTheme(bool value) {
    print("Toggling theme");
    print("Current is ${_currentColors.darkMode}, new is ${value}");
    print("The prior text color is ${_currentColors.textColor}");

    _currentColors.darkMode = value;

    print("Now is ${_currentColors.darkMode}");
    print("The text color is ${_currentColors.textColor}");
    notifyListeners();
  }

  void toggleHandedness(bool value) {
    _currentColors.toggleHandedness(value);
    notifyListeners();
  }

  void modifyColors(Color primary) {
    _currentColors.modifyColors(primary);
    notifyListeners();
  }

  void shiftColors() {
    _currentColors = ComindColors.fromPrimary(_currentColors.secondary);
    notifyListeners();
  }
}
