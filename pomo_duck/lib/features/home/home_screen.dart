import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/global_bloc/language/language_cubit.dart';
import '../../generated/locale_keys.g.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(LocaleKeys.home.tr()),
        actions: [
          // Add button change language
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final current = context.read<LanguageCubit>().state.locale;
              final next = current.languageCode == 'vi'
                  ? const Locale('en', 'US')
                  : const Locale('vi', 'VN');
              context.setLocale(next);
              context.read<LanguageCubit>().setNewLanguage(next);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(LocaleKeys.home.tr()),
      ),
    );
  }
}
