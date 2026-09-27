import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../../common/extensions/context_x.dart';
import '../cubit/focus_cubit.dart';
import 'focus_body.dart';

@RoutePage()
class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF132522)
          : const Color(0xFFEAF7F4),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF132522),
                      Color(0xFF17332F),
                      Color(0xFF202B43),
                    ]
                  : const [
                      Color(0xFFEAF7F4),
                      Color(0xFFDDF0EC),
                      Color(0xFFE7E8F7),
                    ],
            ),
          ),
          child: BlocProvider(
            create: (_) => FocusCubit(),
            child: const FocusBody(),
          ),
        ),
      ),
    );
  }
}