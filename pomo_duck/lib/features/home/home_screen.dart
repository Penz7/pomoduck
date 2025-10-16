import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/router_extension.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';

import '../../common/global_bloc/language/language_cubit.dart';
import '../../generated/locale_keys.g.dart';
import 'home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   title: Text(LocaleKeys.home.tr()),
        //   actions: [
        //     // Timer button
        //     IconButton(
        //       icon: const Icon(Icons.timer),
        //       onPressed: () {
        //         context.goWithPath('/settings');
        //       },
        //     ),
        //     // Add button change language
        //     IconButton(
        //       icon: const Icon(Icons.language),
        //       onPressed: () {
        //         final current = context.read<LanguageCubit>().state.locale;
        //         final next = current.languageCode == 'vi'
        //             ? const Locale('en', 'US')
        //             : const Locale('vi', 'VN');
        //         context.setLocale(next);
        //         context.read<LanguageCubit>().setNewLanguage(next);
        //       },
        //     ),
        //   ],
        // ),
        body: BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state.isError && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final data = state.data;
              if (data == null || data.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.images.duck.image(
                      width: 150,
                      height: 150,
                    ),
                  ],
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Assets.images.duck.image(
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.images.duckTag.image(
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        '25:00',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Assets.images.icRight.image(
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        print('Start button tapped');
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Assets.images.borderButton.image(
                            width: 400,
                            height: 50,
                          ),
                          const Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
