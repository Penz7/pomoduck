import 'dart:ui';

class ConfigHelper {
  ConfigHelper._();
  static final instance = ConfigHelper._();

  String get theme =>  '';
}


enum ThemeEnum {
  normal('', null),
  tet('TET', null);

  final Color? color;
  final String tr;
  const ThemeEnum(this.tr, this.color);
}
