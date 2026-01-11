// Mascot States
enum MascotState {
  idle,
  typing,
  coveringEyes,
  loading,
  success,
  failed,
}

// Animation Durations (in milliseconds)
class AnimationDurations {
  static const int pageLoadFade = 800;
  static const int formSlide = 600;
  static const int buttonScale = 400;
  static const int mascotFloat = 2000;
  static const int mascotBlink = 150;
  static const int stateTransition = 300;
  static const int successHold = 1500;
  static const int failedHold = 2000;
  static const int bounceAnimation = 800;
}

// Animation Curves
class AnimationCurves {
  static const pageFade = 'easeIn';
  static const formSlide = 'easeOutCubic';
  static const buttonScale = 'elasticOut';
  static const mascotFloat = 'easeInOut';
  static const stateTransition = 'easeInOut';
}

// Color Schemes for States
class StateColors {
  // Idle state
  static const idleLight = 'Colors.blue.shade50';
  static const idleDark = 'Colors.white';
  static const idleMascotLight = 'Colors.blue.shade400';
  static const idleMascotDark = 'Colors.blue.shade700';

  // Loading state
  static const loadingLight = 'Colors.orange.shade100';
  static const loadingDark = 'Colors.orange.shade50';
  static const loadingMascotLight = 'Colors.orange.shade400';
  static const loadingMascotDark = 'Colors.orange.shade700';

  // Success state
  static const successLight = 'Colors.green.shade100';
  static const successDark = 'Colors.green.shade50';
  static const successMascotLight = 'Colors.green.shade400';
  static const successMascotDark = 'Colors.green.shade700';

  // Failed state
  static const failedLight = 'Colors.red.shade100';
  static const failedDark = 'Colors.red.shade50';
  static const failedMascotLight = 'Colors.red.shade400';
  static const failedMascotDark = 'Colors.red.shade700';
}

// Loading Animation Types
enum LoadingAnimationType {
  threeBounce,
  fadingCircle,
  rotatingCircle,
  wave,
  pulse,
}
