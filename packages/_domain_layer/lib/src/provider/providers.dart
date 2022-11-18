import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

/// System locales obtained on main()
final systemLocalesProvider = StateProvider<List<Locale>>((ref) => []);
