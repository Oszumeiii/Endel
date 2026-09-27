import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../shared/widgets/app_text.dart';
import '../cubit/home_cubit.dart';
import 'home_body.dart';

/Users/tranvanhuan/Desktop/super-plan-app
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Home Page'),
      ),
      body: BlocProvider(
        create: (context) => HomeCubit(),
        child: const HomeBody(),
      ),
    );
  }
}
