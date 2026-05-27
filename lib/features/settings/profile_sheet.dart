import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/features/settings/widgets/profile_avatar.dart';
import 'package:kaku/shared/providers/profile_provider.dart';

class ProfileSheet extends ConsumerStatefulWidget {
  const ProfileSheet({super.key});

  @override
  ConsumerState<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<ProfileSheet> {
  TextEditingController _nameController = TextEditingController();
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    _nameController.text = ref.read(profileProvider).displayName;
    _receiptPath = ref.read(profileProvider).avatarPath;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileAvatar(profile: profile, radius: 45),
                TextButton.icon(
                  onPressed: () {},
                  label: Text('Cambiar foto'),
                  icon: Icon(Icons.camera),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            maxLines: 1,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'Email (Solo Lectura)',
            ),
            controller: TextEditingController(
              text:
                  '${profile.displayName.toLowerCase().replaceAll(' ', '.')}@kaku',
            ),
            enabled: false,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                ref
                    .read(profileProvider.notifier)
                    .setName(_nameController.text);
                if (_receiptPath != null) {
                  ref.read(profileProvider.notifier).setAvatar(_receiptPath!);
                }

                if (context.mounted) {
                  AppSnackbar.success(context, 'Cambios guardados');
                  Navigator.pop(context);
                }
              },
              child: Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
