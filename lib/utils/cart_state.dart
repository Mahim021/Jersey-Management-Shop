import 'package:flutter/foundation.dart';

/// Number of items in the cart, shown as the badge on the bottom-nav Cart
/// icon. Temporary in-memory counter until the Cart section is built.
final ValueNotifier<int> cartItemCount = ValueNotifier<int>(0);
