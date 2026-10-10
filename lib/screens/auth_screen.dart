import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;

  // Form Fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);
    
    if (_isLoginMode) {
      // Login flow
      appState.login(_emailController.text, _passwordController.text);
    } else {
      // Register flow
      appState.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _bioController.text.trim(),
      );
    }

    // Navigate to Main Navigation Shell
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkGreen,
              AppTheme.backgroundDark,
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo Icon & Title
                    Icon(
                      Icons.sports_soccer,
                      size: 72,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'HALISAHA BUL',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            letterSpacing: 2.0,
                            color: AppTheme.primaryGreen,
                          ),
                    ),
                    Text(
                      'Eleman Davet & Maç Arama Platformu',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                    const SizedBox(height: 40),

                    // Auth Form Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Login / Register Selector Chips
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isLoginMode = true),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: _isLoginMode
                                                ? AppTheme.primaryGreen
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Giriş Yap',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _isLoginMode
                                              ? AppTheme.primaryGreen
                                              : AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isLoginMode = false),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: !_isLoginMode
                                                ? AppTheme.primaryGreen
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Kayıt Ol',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: !_isLoginMode
                                              ? AppTheme.primaryGreen
                                              : AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Dynamic inputs depending on login/register mode
                            if (!_isLoginMode) ...[
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Ad Soyad',
                                  prefixIcon: Icon(Icons.person, color: AppTheme.textMuted),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Lütfen adınızı girin' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Telefon Numarası',
                                  prefixIcon: Icon(Icons.phone, color: AppTheme.textMuted),
                                  hintText: '0555 123 4567',
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (val) => val == null || val.isEmpty ? 'Lütfen telefonunuzu girin' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _bioController,
                                decoration: const InputDecoration(
                                  labelText: 'Hakkımda / Mevki / Bio',
                                  prefixIcon: Icon(Icons.info_outline, color: AppTheme.textMuted),
                                  hintText: 'Mevkilerim, haftalık müsaitliklerim...',
                                ),
                                maxLines: 2,
                                validator: (val) => val == null || val.isEmpty ? 'Lütfen kendinizden bahsedin' : null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Common inputs (Email & Password)
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-posta Adresi',
                                prefixIcon: Icon(Icons.email, color: AppTheme.textMuted),
                                hintText: 'ornek@mail.com',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'E-posta boş bırakılamaz';
                                if (!val.contains('@')) return 'Geçersiz e-posta adresi';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: Icon(Icons.lock, color: AppTheme.textMuted),
                              ),
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.length < 4) return 'Şifre en az 4 karakter olmalıdır';
                                return null;
                              },
                            ),
                             const SizedBox(height: 16),
                             if (!_isLoginMode)
                               Container(
                                 padding: const EdgeInsets.all(10),
                                 decoration: BoxDecoration(
                                   color: AppTheme.primaryGreen.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                                 ),
                                 child: const Row(
                                   children: [
                                     Icon(Icons.stars, color: AppTheme.primaryGreen, size: 18),
                                     SizedBox(width: 8),
                                     Expanded(
                                       child: Text(
                                         'Telefon numarası ile kayıt (İleride Premium iletişim özellikleri aktif olacaktır).',
                                         style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             const SizedBox(height: 24),

                             // Submit Button
                             ElevatedButton(
                               onPressed: _submit,
                               child: Text(_isLoginMode ? 'Giriş Yap' : 'Kayıt Ol ve Başla'),
                             ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Text(
                      _isLoginMode
                          ? '* Demo için istediğiniz e-posta ve 4 haneli şifreyle girebilirsiniz. Sistem otomatik hesap oluşturacaktır.'
                          : '* Kaydolduğunuzda profiliniz oluşturulacak ve maçı hemen aramaya başlayabileceksiniz.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
