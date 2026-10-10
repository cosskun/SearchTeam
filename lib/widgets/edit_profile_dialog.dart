import 'package:flutter/material.dart';
import '../models/match_ad.dart';
import '../models/user.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class EditProfileDialog extends StatefulWidget {
  final AppUser user;
  final AppState appState;

  const EditProfileDialog({
    super.key,
    required this.user,
    required this.appState,
  });

  static void show(BuildContext context, AppUser user, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditProfileDialog(user: user, appState: appState),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  late List<PositionType> _tempPreferredPositions;
  late bool _tempIsContactInfoPublic;
  late bool _tempShareContactOnApproval;
  late String _tempAvatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _bioController = TextEditingController(text: widget.user.bio);
    _heightController = TextEditingController(
      text: widget.user.height != null ? widget.user.height!.toInt().toString() : '',
    );
    _weightController = TextEditingController(
      text: widget.user.weight != null ? widget.user.weight!.toInt().toString() : '',
    );

    _tempPreferredPositions = List.from(widget.user.preferredPositions);
    _tempIsContactInfoPublic = widget.user.isContactInfoPublic;
    _tempShareContactOnApproval = widget.user.shareContactOnApproval;
    _tempAvatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _showCustomAvatarDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Galeriden / Özel Fotoğraf Seç', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Fotoğraf URL Bağlantısı veya Yol',
              hintText: 'https://...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _tempAvatarUrl = controller.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Kullan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Profili Düzenle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profil Resmi',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showCustomAvatarDialog,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.backgroundDark,
                            backgroundImage: _tempAvatarUrl.isNotEmpty
                                ? NetworkImage(_tempAvatarUrl)
                                : null,
                            child: _tempAvatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 48, color: AppTheme.textMuted)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.primaryGreen,
                              child: Icon(
                                _tempAvatarUrl.isNotEmpty ? Icons.edit : Icons.add_a_photo,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _showCustomAvatarDialog,
                          icon: const Icon(Icons.photo_library, size: 16),
                          label: Text(
                            _tempAvatarUrl.isNotEmpty ? 'Fotoğrafı Değiştir' : 'Galeriden Fotoğraf Seç',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            side: const BorderSide(color: AppTheme.primaryGreen),
                          ),
                        ),
                        if (_tempAvatarUrl.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _tempAvatarUrl = '';
                              });
                            },
                            icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
                            label: const Text('Kaldır', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefon Numarası'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Hakkımda / Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Boy (cm)', hintText: 'örn. 180'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Kilo (kg)', hintText: 'örn. 75'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Tercih Ettiğim Mevkiler',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Row(
                children: PositionType.values.map((pos) {
                  final isSelected = _tempPreferredPositions.contains(pos);
                  Color chipColor;
                  switch (pos) {
                    case PositionType.kaleci:
                      chipColor = Colors.orangeAccent;
                      break;
                    case PositionType.defans:
                      chipColor = Colors.blueAccent;
                      break;
                    case PositionType.ortaSaha:
                      chipColor = Colors.tealAccent;
                      break;
                    case PositionType.forvet:
                      chipColor = Colors.redAccent;
                      break;
                  }
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _tempPreferredPositions.remove(pos);
                          } else {
                            _tempPreferredPositions.add(pos);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? chipColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? chipColor : Colors.white12,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          pos.displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? chipColor : AppTheme.textLight,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('İletişim Bilgilerimi Herkese Aç', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Diğer kullanıcıların telefon numaramı profilimde görmesine izin ver.', style: TextStyle(fontSize: 11)),
                value: _tempIsContactInfoPublic,
                activeThumbColor: AppTheme.primaryGreen,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _tempIsContactInfoPublic = val;
                  });
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Onaylandığımda Bilgilerimi Paylaş', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Başvurum kabul edildiğinde telefon numaramı otomatik paylaş.', style: TextStyle(fontSize: 11)),
                value: _tempShareContactOnApproval,
                activeThumbColor: AppTheme.primaryGreen,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _tempShareContactOnApproval = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isEmpty ||
                      _phoneController.text.trim().isEmpty ||
                      _bioController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
                    );
                    return;
                  }

                  widget.appState.updateProfile(
                    name: _nameController.text.trim(),
                    phone: _phoneController.text.trim(),
                    bio: _bioController.text.trim(),
                    preferredPositions: _tempPreferredPositions,
                    isContactInfoPublic: _tempIsContactInfoPublic,
                    shareContactOnApproval: _tempShareContactOnApproval,
                    height: double.tryParse(_heightController.text.trim()),
                    weight: double.tryParse(_weightController.text.trim()),
                    avatarUrl: _tempAvatarUrl,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil başarıyla güncellendi!')),
                  );
                },
                child: const Text('Kaydet'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
