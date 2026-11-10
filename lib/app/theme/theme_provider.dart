import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// Manages the app's theme mode (light / dark / system).
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.dark);
