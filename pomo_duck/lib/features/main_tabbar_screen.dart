import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pomo_duck/common/extensions/context_extension.dart';

import '../common/theme/config_helper.dart';

class MainTabBarScreen extends StatefulWidget {
  const MainTabBarScreen({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<MainTabBarScreen> createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBarScreen> {
  ThemeEnum appTheme = ThemeEnum.normal;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   LiveData.mainContext = context;
    // });
    // NotificationHelper.instance.setup(this);
    // LazyStreaming.instance.registerConfigChange(configChanged);
    // ForceUpdating.instance.checkAndUpdateVersion();
    setState(() {
      appTheme = ThemeEnum.values
          .firstWhere((e) => e.tr == ConfigHelper.instance.theme);
    });
  }

  // Future<void> configChanged(dynamic data) async {
  //   //receive config changed.
  //   // LiveData.mainContext.pushWithPath('/maintaining');
  //   final configData = data.data['data'] as List<dynamic>;
  //   final maintaining = configData.firstWhere((element) {
  //     return element['key'] == 'MAINTAINING_STATUS';
  //   });
  //   if (maintaining['value'] == 'true') {
  //     LiveData.mainContext.pushWithPath('/maintaining');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: context.bottomPadding,
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(
                image: 'ic_home',
                index: 0,
              ),
              _buildItem(
                image: 'ic_stats',
                index: 1,
              ),
              _buildItem(
                image: 'ic_time_line',
                index: 2,
              ),
              _buildItem(
                image: 'ic_setting',
                index: 3,
              ),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
    );
  }

  Widget _buildItem({
    required String image,
    required int index,
  }) {
    final selected = widget.navigationShell.currentIndex == index;
    return InkWell(
      onTap: () {
        _onTap(index);
      },
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 80,
                  child: Image.asset(
                    selected
                        ? 'assets/images/navigation/${image}_active.png'
                        : 'assets/images/navigation/$image.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                if (appTheme != ThemeEnum.normal && selected)
                  Positioned(
                    top: 0,
                    left: 8,
                    child: Image.asset(
                      'assets/images/${appTheme.tr}.png',
                      width: 24,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTap(int index) async {
    switch (index) {
      // case 2:
      //   // showToast(message: 'Coming soon');
      //   // if (context.mounted) {
      //   //   final result = await DialogProvider.instance.showCustomDialog(
      //   //     context,
      //   //     dialog: const MealDialog(),
      //   //   );
      //   //   if (result == true) {
      //   //     widget.navigationShell.goBranch(index);
      //   //   }
      //   //   break;
      //   // }
      //   break;
      // case 3:
      //   final login = await LocalStorageManager.instance.checkLogin();
      //   if (!login && context.mounted) {
      //     TempData.prePath = '/profile';
      //     context.pushWithPath('/login');
      //   } else {
      //     widget.navigationShell.goBranch(index);
      //   }
      //   break;
      default:
        widget.navigationShell.goBranch(index);
    }
  }
}
