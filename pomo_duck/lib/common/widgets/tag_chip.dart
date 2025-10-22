import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/common/widgets/text.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';
import 'package:pomo_duck/common/global_bloc/config_pomodoro/config_pomodoro_cubit.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TagChip({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      padding: EdgeInsets.zero,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LCText.medium(
            tag,
            color: isSelected ? Colors.white : Colors.black,
          ),
          if (isSelected) ...[
            8.width,
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      onSelected: (_) => onTap(),
      selected: isSelected,
      selectedColor: Colors.black,
      checkmarkColor: isSelected ? Colors.white : Colors.black,
    );
  }
}

class AddTagChip extends StatelessWidget {
  const AddTagChip({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      padding: EdgeInsets.zero,
      label: LCText.medium(LocaleKeys.add_tag),
      onPressed: () async {
        final controller = TextEditingController();
        await showDialog(
          context: context,
          builder: (dCtx) {
            return AlertDialog(
              title: Text(LocaleKeys.add_new_tag.tr()),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: LocaleKeys.enter_tag_name.tr(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dCtx).pop(),
                  child: Text(LocaleKeys.cancel.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    final t = controller.text.trim();
                    if (t.isNotEmpty) {
                      context.read<ConfigPomodoroCubit>().addTag(t);
                    }
                    Navigator.of(dCtx).pop();
                  },
                  child: Text(LocaleKeys.add.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
