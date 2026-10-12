import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../models/match_ad.dart';
import 'auth_screen.dart';
import '../widgets/custom_rating_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _showCustomAvatarDialog(BuildContext context, Function(String) onUrlEntered) {
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
                  onUrlEntered(controller.text.trim());
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

  void _showEditProfileDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null) return;

    _nameController.text = user.name;
    _phoneController.text = user.phoneNumber;
    _bioController.text = user.bio;
    _heightController.text = user.height != null ? user.height!.toInt().toString() : '';
    _weightController.text = user.weight != null ? user.weight!.toInt().toString() : '';
    List<PositionType> tempPreferredPositions = List.from(user.preferredPositions);
    bool tempIsContactInfoPublic = user.isContactInfoPublic;
    bool tempShareContactOnApproval = user.shareContactOnApproval;
    String tempAvatarUrl = user.avatarUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showCustomAvatarDialog(context, (newUrl) {
                              setModalState(() {
                                tempAvatarUrl = newUrl;
                              });
                            });
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppTheme.backgroundDark,
                                backgroundImage: tempAvatarUrl.isNotEmpty
                                    ? NetworkImage(tempAvatarUrl)
                                    : null,
                                child: tempAvatarUrl.isEmpty
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
                                    tempAvatarUrl.isNotEmpty ? Icons.edit : Icons.add_a_photo,
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
                              onPressed: () {
                                _showCustomAvatarDialog(context, (newUrl) {
                                  setModalState(() {
                                    tempAvatarUrl = newUrl;
                                  });
                                });
                              },
                              icon: const Icon(Icons.photo_library, size: 16),
                              label: Text(
                                tempAvatarUrl.isNotEmpty ? 'Fotoğrafı Değiştir' : 'Galeriden Fotoğraf Seç',
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryGreen,
                                side: const BorderSide(color: AppTheme.primaryGreen),
                              ),
                            ),
                            if (tempAvatarUrl.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    tempAvatarUrl = '';
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
                  );
                },
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
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Row(
                    children: PositionType.values.map((pos) {
                      final isSelected = tempPreferredPositions.contains(pos);
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
                            setModalState(() {
                              if (isSelected) {
                                tempPreferredPositions.remove(pos);
                              } else {
                                tempPreferredPositions.add(pos);
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
                  );
                },
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return SwitchListTile(
                    title: const Text('İletişim Bilgilerimi Herkese Aç', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Diğer kullanıcıların telefon numaramı profilimde görmesine izin ver.', style: TextStyle(fontSize: 11)),
                    value: tempIsContactInfoPublic,
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() {
                        tempIsContactInfoPublic = val;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return SwitchListTile(
                    title: const Text('Onaylandığımda Bilgilerimi Paylaş', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Başvurum kabul edildiğinde telefon numaramı otomatik paylaş.', style: TextStyle(fontSize: 11)),
                    value: tempShareContactOnApproval,
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() {
                        tempShareContactOnApproval = val;
                      });
                    },
                  );
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

                  appState.updateProfile(
                    name: _nameController.text.trim(),
                    phone: _phoneController.text.trim(),
                    bio: _bioController.text.trim(),
                    preferredPositions: tempPreferredPositions,
                    isContactInfoPublic: tempIsContactInfoPublic,
                    shareContactOnApproval: tempShareContactOnApproval,
                    height: double.tryParse(_heightController.text.trim()),
                    weight: double.tryParse(_weightController.text.trim()),
                    avatarUrl: tempAvatarUrl,
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
  },
);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Lütfen giriş yapın.')),
      );
    }

    final userReviews = appState.getReviewsForUser(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
            onPressed: () => _showEditProfileDialog(context),
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              appState.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. User Header card
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      user.avatarUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomRatingIndicator(
                        rating: user.rating,
                        size: 18.0,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${user.rating} (${userReviews.length} yorum)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        user.isContactInfoPublic ? Icons.visibility : Icons.visibility_off,
                        color: user.isContactInfoPublic ? AppTheme.primaryGreen : AppTheme.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.phoneNumber,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.isContactInfoPublic ? '(Herkese Açık)' : '(Gizli)',
                        style: TextStyle(
                          color: user.isContactInfoPublic ? AppTheme.primaryGreen : AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Stats Boxes Row
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.sports_soccer, color: AppTheme.primaryGreen),
                          const SizedBox(height: 6),
                          Text('${user.totalMatchesPlayed}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Oynanan', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.add_circle, color: AppTheme.primaryGreen),
                          const SizedBox(height: 6),
                          Text('${user.totalMatchesHosted}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('İlan', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber),
                          const SizedBox(height: 6),
                          Text('${user.mvpCount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                          const Text('MVP', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Physical Stats Row
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.height, color: AppTheme.primaryGreen),
                          const SizedBox(height: 6),
                          Text(
                            user.height != null ? '${user.height!.toInt()} cm' : 'Belirtilmemiş',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text('Boy', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.scale_outlined, color: AppTheme.primaryGreen),
                          const SizedBox(height: 6),
                          Text(
                            user.weight != null ? '${user.weight!.toInt()} kg' : 'Belirtilmemiş',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text('Kilo', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Achievement Badges Section
            const Text('🏆 Başarım Rozetleri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            const SizedBox(height: 8),
            if (user.earnedBadges.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Henüz rozet kazanılmadı.', style: TextStyle(color: AppTheme.textMuted)),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.earnedBadges.map((badge) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amberAccent),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // 3. Biography Section
            const Text('Hakkımda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            const SizedBox(height: 6),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  user.bio,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tercih Ettiğim Mevkiler
            const Text('Tercih Ettiğim Mevkiler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            const SizedBox(height: 8),
            if (user.preferredPositions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tercih edilen mevki seçilmedi.', style: TextStyle(color: AppTheme.textMuted)),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.preferredPositions.map((pos) {
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
                  return Chip(
                    label: Text(pos.displayName, style: TextStyle(color: chipColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    backgroundColor: chipColor.withOpacity(0.15),
                    side: BorderSide(color: chipColor.withOpacity(0.3)),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // 4. Google Reviews Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Oyuncu Yorumları',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Doğrulanmış Puanlar', style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (userReviews.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'Henüz hakkında yorum yapılmadı.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userReviews.length,
                itemBuilder: (context, idx) {
                  final review = userReviews[idx];
                  final formattedDate = DateFormat('dd.MM.yyyy').format(review.dateTime);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reviewer info & rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.white10,
                                    child: Text(review.reviewerName[0].toUpperCase(), style: const TextStyle(fontSize: 9)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review.reviewerName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Rating bar
                          CustomRatingIndicator(
                            rating: review.rating,
                            size: 14.0,
                          ),
                          const SizedBox(height: 8),

                          // Comment
                          Text(
                            review.comment,
                            style: const TextStyle(fontSize: 13, height: 1.3),
                          ),
                          const SizedBox(height: 8),

                          // Match tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Maç: ${review.matchTitle}',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

