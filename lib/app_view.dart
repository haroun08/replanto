import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:replanto/screens/auth/blocs/bloc/sign_in_bloc.dart';
import 'package:replanto/screens/auth/views/welcome_screen.dart';
import 'package:replanto/screens/home/blocs/get_plant_bloc/get_plant_bloc.dart';
import 'package:replanto/screens/home/views/home_screen.dart';


import 'blocs/authentication_bloc/authentication_bloc_bloc.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Replanto',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.light(background: Colors.grey.shade200, onBackground: Colors.black, primary: Colors.blue, onPrimary: Colors.white)),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: ((context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => SignInBloc(context.read<AuthenticationBloc>().userRepository),
                  ),
                  BlocProvider(
                    create: (context) => GetPlantBloc(
                        FirebasePlantRepo()
                    )..add(GetPlant()),
                  ),
                ],
                child: const Homepage(),
              );
            } else {
              return const WelcomeScreen();
            }
          }),
        ));
  }
}