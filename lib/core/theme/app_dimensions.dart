/// Spacing and radius tokens on a 4px grid.
/// Mirrors shadcn/ui spacing scale applied to Flutter.
class AppDimensions {
  AppDimensions._();

  // ── Raw spacing scale (4px grid) ──
  static const double sp0 = 0;
  static const double sp1 = 4;
  static const double sp2 = 8;
  static const double sp3 = 12;
  static const double sp4 = 16;
  static const double sp5 = 20;
  static const double sp6 = 24;
  static const double sp8 = 32;
  static const double sp10 = 40;
  static const double sp12 = 48;
  static const double sp16 = 64;

  // ── Semantic spacing ──
  static const double pageH = sp5;       // Horizontal page padding
  static const double pageV = sp4;       // Top page padding
  static const double sectionGap = sp6;  // Between major sections
  static const double elementGap = sp4;  // Between related elements
  static const double insetGap = sp3;    // Inside a card/group
  static const double tightGap = sp2;    // Between tightly related items
  static const double cardPaddingH = sp4; // Card horizontal padding
  static const double cardPaddingV = sp4; // Card vertical padding

  // ── Border radius ──
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 999;
}
