import 'package:material_ui/material_ui.dart';

/// Shown for a moment at app start while the stored session is checked.
class SplashPage extends StatelessWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
