import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../models/match_ad.dart';
import '../theme/app_theme.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedDistrict = 'Kadıköy';
  PositionType _selectedPosition = PositionType.kaleci;
  int _spotsNeeded = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isFree = true;
  double? _selectedLat;
  double? _selectedLng;

  void _showMapPickerModal(BuildContext context) {
    final List<Map<String, dynamic>> presetPitches = [
      {'name': 'Gazhane Halısahası', 'district': 'Kadıköy', 'lat': 40.9925, 'lng': 29.0431},
      {'name': 'Kadir Has Spor Tesisleri', 'district': 'Maltepe', 'lat': 40.9312, 'lng': 29.1245},
      {'name': 'Çilekli Spor Kompleksi', 'district': 'Beşiktaş', 'lat': 41.0821, 'lng': 29.0211},
      {'name': 'Üsküdar Spor Tesisleri', 'district': 'Üsküdar', 'lat': 41.0234, 'lng': 29.0189},
      {'name': 'Şişli Belediyesi Halısahası', 'district': 'Şişli', 'lat': 41.0611, 'lng': 28.9880},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.map, color: AppTheme.primaryGreen),
                  SizedBox(width: 8),
                  Text('Haritadan Halısaha Konumu İşaretle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Aşağıdaki halısahalardan birini seçerek harita pimini koyun:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: presetPitches.length,
                  itemBuilder: (context, index) {
                    final pitch = presetPitches[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: Icon(Icons.location_on, color: AppTheme.primaryGreen),
                        ),
                        title: Text(pitch['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${pitch['district']} • Enlem: ${pitch['lat']}, Boylam: ${pitch['lng']}', style: const TextStyle(fontSize: 11)),
                        onTap: () {
                          setState(() {
                            _locationController.text = pitch['name'];
                            _selectedDistrict = pitch['district'];
                            _selectedLat = pitch['lat'];
                            _selectedLng = pitch['lng'];
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${pitch['name']} haritada konumlandı!'), backgroundColor: AppTheme.primaryGreen),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final List<String> _districts = [
    'Kadıköy',
    'Beşiktaş',
    'Üsküdar',
    'Maltepe',
    'Şişli',
    'Kartal',
    'Pendik',
    'Ataşehir',
    'Ümraniye',
    'Bakırköy',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.black,
              surface: AppTheme.cardDark,
              onSurface: AppTheme.textLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.black,
              surface: AppTheme.cardDark,
              onSurface: AppTheme.textLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitAd() {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);

    // Calculate exact DateTime
    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final double price = _isFree ? 0.0 : (double.tryParse(_priceController.text) ?? 0.0);

    appState.createMatchAd(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      locationName: _locationController.text.trim(),
      district: _selectedDistrict,
      dateTime: finalDateTime,
      price: price,
      requiredPosition: _selectedPosition,
      spotsNeeded: _spotsNeeded,
      latitude: _selectedLat,
      longitude: _selectedLng,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İlanınız başarıyla yayınlandı!'),
        backgroundColor: AppTheme.forestGreen,
      ),
    );

    // Reset Form Fields
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _priceController.clear();
    setState(() {
      _selectedPosition = PositionType.kaleci;
      _spotsNeeded = 1;
      _isFree = true;
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = const TimeOfDay(hour: 20, minute: 0);
    });

    // Toggle default navigation tab to Browse Ads or let user click.
    // In our main navigation system, we can't easily change tab index from sub-widgets unless we pass a handler.
    // Let's just pop or show user they succeeded. The state provider notification will refresh list.
  }

  Widget _buildPositionCard(PositionType pos, IconData icon, Color color) {
    final isSelected = _selectedPosition == pos;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPosition = pos;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppTheme.textMuted, size: 22),
            const SizedBox(height: 4),
            Text(
              pos.displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: isSelected ? color : AppTheme.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate);
    final formattedTime = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Maç İlanı Ver', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section title: General Info
              const Text(
                'Genel Maç Bilgileri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 12),

              // Title input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'İlan Başlığı',
                  hintText: 'Örn: Kadıköy Maçına Acil Kaleci Aranıyor',
                ),
                validator: (val) => val == null || val.isEmpty ? 'İlan başlığı giriniz' : null,
              ),
              const SizedBox(height: 16),

              // Description input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Maçın seviyesi, kurallar veya detaylar hakkında yazın...',
                ),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'İlan açıklaması giriniz' : null,
              ),
              const SizedBox(height: 20),

              // Section: Location & Date
              const Text(
                'Konum ve Zaman Planlaması',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 12),

              // District Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'İlçe',
                  prefixIcon: Icon(Icons.location_city, color: AppTheme.textMuted),
                ),
                dropdownColor: AppTheme.cardDark,
                items: _districts.map((district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDistrict = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Location Detail
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Halısaha Adı',
                  prefixIcon: Icon(Icons.map, color: AppTheme.textMuted),
                  hintText: 'Örn: Bostancı Sahil Spor Tesisleri',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Halısaha adı giriniz' : null,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _showMapPickerModal(context),
                icon: const Icon(Icons.my_location, size: 16),
                label: Text(
                  _selectedLat != null
                      ? 'Haritada İşaretlendi (${_selectedLat?.toStringAsFixed(3)}, ${_selectedLng?.toStringAsFixed(3)})'
                      : 'Haritadan Konum İşaretle',
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  foregroundColor: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tarih', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                const SizedBox(height: 2),
                                Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const Icon(Icons.calendar_today, color: AppTheme.primaryGreen, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Saat', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                const SizedBox(height: 2),
                                Text(formattedTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const Icon(Icons.access_time, color: AppTheme.primaryGreen, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section: Player Requirements
              const Text(
                'Aranan Oyuncu Özellikleri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 12),

              // Position Grid
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPositionCard(PositionType.kaleci, Icons.pan_tool, Colors.orangeAccent),
                  _buildPositionCard(PositionType.defans, Icons.shield, Colors.blueAccent),
                  _buildPositionCard(PositionType.ortaSaha, Icons.adjust, Colors.tealAccent),
                  _buildPositionCard(PositionType.forvet, Icons.sports_soccer, Colors.redAccent),
                ],
              ),
              const SizedBox(height: 16),

              // Spots Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Aranan Oyuncu Sayısı:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: AppTheme.primaryGreen),
                          onPressed: () {
                            if (_spotsNeeded > 1) {
                              setState(() => _spotsNeeded--);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '$_spotsNeeded',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppTheme.primaryGreen),
                          onPressed: () {
                            if (_spotsNeeded < 5) {
                              setState(() => _spotsNeeded++);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section: Pricing Policy
              const Text(
                'Ücret Modeli',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 12),

              // Pricing Model Selection Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        value: true,
                        groupValue: _isFree,
                        activeColor: AppTheme.primaryGreen,
                        title: const Text('Ücretsiz Maç', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Oyuncudan saha ücreti talep edilmez, davet eden karşılar.', style: TextStyle(fontSize: 12)),
                        onChanged: (val) {
                          if (val != null) setState(() => _isFree = val);
                        },
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      RadioListTile<bool>(
                        value: false,
                        groupValue: _isFree,
                        activeColor: AppTheme.primaryGreen,
                        title: const Text('Kişi Başı Saha Ücreti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Oyuncunun ödemesi gereken saha payı tutarı.', style: TextStyle(fontSize: 12)),
                        onChanged: (val) {
                          if (val != null) setState(() => _isFree = val);
                        },
                      ),
                      if (!_isFree) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Paylaşım Ücreti (TL)',
                              prefixIcon: Icon(Icons.currency_lira, color: AppTheme.textMuted),
                              hintText: 'Örn: 150',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (_isFree) return null;
                              if (val == null || val.isEmpty) return 'Lütfen ücret tutarı girin';
                              if (double.tryParse(val) == null) return 'Geçersiz tutar';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submitAd,
                child: const Text('İlanı Yayınla'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
