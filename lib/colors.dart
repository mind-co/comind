import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ColorChoice {
  primary,
  secondary,
  tertiary,
}

// Color method type
enum ColorMethod {
  splitComplementary,
  complementary,
  triadic,
  analogous,
  monochromatic
}

// Convert color method to string
extension ColorMethodExtension on ColorMethod {
  String get name {
    switch (this) {
      case ColorMethod.splitComplementary:
        return 'splitComplementary';
      case ColorMethod.complementary:
        return 'complementary';
      case ColorMethod.triadic:
        return 'triadic';
      case ColorMethod.analogous:
        return 'analogous';
      case ColorMethod.monochromatic:
        return 'monochromatic';
      default:
        return 'splitComplementary';
    }
  }
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
    surface: Colors.white,
    background: Color.fromARGB(255, 237, 237, 237),
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
    surface: Color.fromRGBO(43, 43, 43, 1), //Color.fromRGBO(43, 34, 34, 1),
    background: Color.fromRGBO(13, 16, 29, 1),
    error: secondaryColorDefault,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
    surfaceVariant: Color.fromRGBO(40, 40, 40, 1),
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

  get primary => colorScheme.primary;
  get secondary => colorScheme.secondary;
  get tertiary => colorScheme.tertiary;

  // Init method and set the color scheme
  void init(prim, seco, tert) {
    colorScheme = darkMode ? _darkScheme : _lightScheme;

    loadColors();
  }

  // Text themes
  static final bodyStyle = GoogleFonts.ibmPlexSans(
    fontWeight: FontWeight.w300,
    height: 1.2,
  );

  // static final bodyStyle = GoogleFonts.nunito(
  //   fontWeight: FontWeight.w300,
  //   height: 1.2,
  // );

  // static final bodyStyle = GoogleFonts.angkor(
  //   fontWeight: FontWeight.w300,
  //   height: 1.2,
  // );

  static final titleStyle = GoogleFonts.bungee(
    fontWeight: FontWeight.w400,
    fontSize: 20,
  );

  static final labelStyle = GoogleFonts.ibmPlexMono(
    fontWeight: FontWeight.w400,
    fontSize: 20,
  );

  static const fontScalar = 1.4;
  static const double maxWidth = 800;
  static const double bubbleRadius = 10;

  TextTheme textTheme = TextTheme(
    // Nunito is good

    // Label style
    labelSmall: labelStyle.copyWith(fontSize: fontScalar * 8),
    labelMedium: labelStyle.copyWith(fontSize: fontScalar * 10),
    labelLarge: labelStyle.copyWith(fontSize: fontScalar * 12),

    // Body style
    bodySmall: bodyStyle.copyWith(fontSize: fontScalar * 10),
    bodyMedium: bodyStyle.copyWith(fontSize: fontScalar * 12),
    bodyLarge: bodyStyle.copyWith(fontSize: fontScalar * 16),

    // Title style
    titleSmall: titleStyle.copyWith(fontSize: fontScalar * 10),
    titleMedium: titleStyle.copyWith(fontSize: fontScalar * 12),
    titleLarge: titleStyle.copyWith(fontSize: fontScalar * 14),

    // Header style
    headlineLarge: titleStyle.copyWith(fontSize: fontScalar * 20),
    headlineMedium: titleStyle.copyWith(fontSize: fontScalar * 24),
    headlineSmall: titleStyle.copyWith(fontSize: fontScalar * 28),

    // Display style
    displayLarge: titleStyle.copyWith(fontSize: fontScalar * 40),
    displayMedium: titleStyle.copyWith(fontSize: fontScalar * 36),
    displaySmall: titleStyle.copyWith(fontSize: fontScalar * 30),
  );

  static const Color _textColor = Colors.black;
  static const Color _darkTextColor = Color.fromARGB(255, 179, 179, 179);
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

  List<Color> generateComplementaryColors(Color primaryColor) {
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

    // Create a third color, a lighter variation of the primary color
    HSLColor thirdColor = HSLColor.fromAHSL(
      hslPrimary.alpha,
      hslPrimary.hue, // Keep the same hue
      hslPrimary.saturation,
      (hslPrimary.lightness * 1.2).clamp(0, 1), // Increase lightness
    );

    // Convert back to Color objects and return the color scheme
    return [primaryColor, complementary.toColor(), thirdColor.toColor()];
  }

  // Add color scheme generation method
  List<Color> setColorScheme(Color primaryColor) {
    // Calculate complementary colors
    if (colorMethod == ColorMethod.complementary) {
      return generateComplementaryColors(primaryColor);
    }

    // Calculate triadic colors
    if (colorMethod == ColorMethod.triadic) {
      return generateTriadicColors(primaryColor);
    }

    // Calculate analogous colors
    if (colorMethod == ColorMethod.analogous) {
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
        adjustBrightness(primaryColor, 1.5),
        adjustBrightness(primaryColor, 3.0)
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
    final newColors = setColorScheme(primary);
    setColors(newColors[0], newColors[1], newColors[2]);

    // Put it in preferences
    saveColors();
  }

  // Save colors to preferences
  void saveColors() async {
    // Save the colors to preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the colors
    prefs.setInt('primaryColor', primaryColor.value);
    prefs.setInt('secondaryColor', secondaryColor.value);
    prefs.setInt('tertiaryColor', tertiaryColor.value);
    prefs.setInt('colorMethod', colorMethod.index);
  }

  // Load colors from preferences
  void loadColors() async {
    // Load the colors from preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load the colors
    primaryColor =
        Color(prefs.getInt('primaryColor') ?? primaryColorDefault.value);
    secondaryColor =
        Color(prefs.getInt('secondaryColor') ?? secondaryColorDefault.value);
    tertiaryColor =
        Color(prefs.getInt('tertiaryColor') ?? tertiaryColorDefault.value);
    colorMethod = ColorMethod.values[prefs.getInt('colorMethod') ?? 0];
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
  Color get onBackground => colorScheme.onBackground;
  bool get darkMode => currentColors.darkMode;
  TextTheme get textTheme => currentColors.textTheme;

  // whether in public mode
  bool get publicMode => currentColors.publicMode;

  get textStyle => null;

  get colorMethod => currentColors.colorMethod;

  set currentColors(ComindColors newColors) {
    _currentColors = newColors;
    notifyListeners();
  }

  // Toggle public mode
  void togglePublicMode(bool value) {
    _currentColors.publicMode = value;
    notifyListeners();
  }

  void toggleTheme(bool value) {
    _currentColors.darkMode = value;
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

  void setColorMethod(ColorMethod method) {
    _currentColors.colorMethod = method;

    // Modify the colors based on the new method
    modifyColors(_currentColors.primary);

    notifyListeners();
  }

  // Calculate onPrimary, onSecondary, onSurface, onBackground, onError based on
  // primary, secondary, tertiary, and background.
  //
  // If the luminance of the color is greater than 0.5,
  // return dark text color, otherwise return light text color

  // Get onPrimary color.
  Color get onPrimary =>
      this.primary.computeLuminance() < 0.5 ? Colors.white : Colors.black;

  // Get onSecondary color.
  Color get onSecondary =>
      this.secondary.computeLuminance() < 0.5 ? Colors.white : Colors.black;

  // Get onTertiary color.
  Color get onTertiary =>
      this.tertiary.computeLuminance() < 0.5 ? Colors.white : Colors.black;
}
