void openRazorpayWeb(
  Map<String, dynamic> options,
  Function(String) onSuccess,
  Function(String) onFailure,
) {
  // This stub should technically not be reached if kIsWeb checks are correct,
  // but it satisfies the compiler for non-web platforms.
  onFailure('Razorpay Web not supported on this platform');
}
