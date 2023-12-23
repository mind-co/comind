import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Dark mode tracker
  bool darkMode = true;

  final ColorScheme _lightScheme = const ColorScheme(
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

  final ColorScheme _darkScheme = const ColorScheme(
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

  ColorScheme colorScheme = const ColorScheme(
    primary: primaryColorDefault,
    secondary: secondaryColorDefault,
    tertiary: tertiaryColorDefault,
    surface: tertiaryColorDefault,
    background: Colors.blue,
    error: secondaryColorDefault,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.black,
    brightness: Brightness.light,
    surfaceVariant: Color.fromRGBO(239, 239, 239, 1),
  );

  get _colorScheme => darkMode ? _darkScheme : _lightScheme;

  get primary => null;
  get secondary => null;
  get tertiary => null;

  // Init method and set the color scheme
  void init(prim, seco, tert) {
    colorScheme = ColorScheme(
      primary: prim,
      secondary: seco,
      tertiary: tert,
      surface: tertiaryColor,
      background: Colors.white,
      error: secondaryColor,
      onPrimary: textColor,
      onSecondary: textColor,
      onSurface: textColor,
      onBackground: textColor,
      onError: textColor,
      brightness: Brightness.light,
      surfaceVariant: const Color.fromRGBO(239, 239, 239, 1),
    );
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

  // Add color scheme generation method
  static List<Color> generateSplitComplementaryColors(Color primaryColor) {
    // Extract RGB values from the primaryColor
    int primaryRed = primaryColor.red;
    int primaryGreen = primaryColor.green;
    int primaryBlue = primaryColor.blue;

    // Calculate split-complementary colors
    // Color secondaryColor1 = Color.fromRGBO(
    //     primaryRed, (primaryGreen + 128) % 256, (primaryBlue + 128) % 256, 1.0);
    // Color secondaryColor2 = Color.fromRGBO(
    //     (primaryRed + 128) % 256, primaryGreen, (primaryBlue + 128) % 256, 1.0);

    // Calculate complementary colors
    // Color secondaryColor1 = Color.fromRGBO(
    //     (primaryRed + 128) % 256, (primaryGreen + 128) % 256, primaryBlue, 1.0);
    // Color secondaryColor2 = Color.fromRGBO(
    //     primaryRed, (primaryGreen + 128) % 256, (primaryBlue + 128) % 256, 1.0);

    // Calculate triadic colors
    // Color secondaryColor1 = Color.fromRGBO(
    //     (primaryRed + 128) % 256, (primaryGreen + 128) % 256, primaryBlue, 1.0);
    // Color secondaryColor2 = Color.fromRGBO(
    //     (primaryRed + 128) % 256, primaryGreen, (primaryBlue + 128) % 256, 1.0);

    // Calculate analogous colors
    Color secondaryColor1 = Color.fromRGBO(
        (primaryRed + 128) % 256, (primaryGreen + 128) % 256, primaryBlue, 1.0);
    Color secondaryColor2 = Color.fromRGBO(
        primaryRed, (primaryGreen + 128) % 256, (primaryBlue + 128) % 256, 1.0);

    return [primaryColor, secondaryColor1, secondaryColor2];
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

  ComindColors get currentText => _currentColors;
  ComindColors get currentColors => _currentColors;
  // ColorScheme get colorScheme => _currentColors.colorScheme;
  // If the dark mode is enabled, return the dark color scheme,
  // otherwise return the normal color scheme
  ColorScheme get colorScheme => currentColors._colorScheme;
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

  set currentColors(ComindColors newColors) {
    print("New colors. Primary is ${newColors.primaryColor}");
    _currentColors = newColors;
    notifyListeners();
  }

  void toggleTheme(bool value) {
    print("Toggling theme");
    print("Current is ${_currentColors.darkMode}, new is ${value}");

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
