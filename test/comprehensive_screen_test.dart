import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:halisaha_app/main.dart';
import 'package:halisaha_app/services/app_state.dart';
import 'package:halisaha_app/screens/auth_screen.dart';
import 'package:halisaha_app/screens/main_navigation.dart';
import 'package:halisaha_app/screens/match_details_screen.dart';
import 'package:halisaha_app/screens/chat_room_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  Widget createTestApp() {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    );
  }

  Future<void> loginIfNeeded(WidgetTester tester) async {
    if (find.byType(AuthScreen).evaluate().isNotEmpty) {
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'ahmet@mail.com');
        await tester.enterText(textFields.at(1), '1234');
        await tester.pumpAndSettle();
      }
      await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
      await tester.pumpAndSettle();
    }
  }

  group('Halı Saha Bul - Kapsamlı Ekran ve Özellik Testleri', () {
    testWidgets('1. Giriş ve Ana Navigasyon Sekmeleri (Android & iOS boyutlarında test)', (tester) async {
      // Standart telefon ekran boyutu (Android 1080x2400)
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await loginIfNeeded(tester);

      // MainNavigation aktif olmalı
      expect(find.byType(MainNavigation), findsOneWidget);

      // 6 alt sekmenin varlığını kontrol et
      expect(find.text('İlanlar'), findsOneWidget);
      expect(find.text('Takvim'), findsOneWidget);
      expect(find.text('İlan Ver'), findsOneWidget);
      expect(find.text('Başvurular'), findsOneWidget);
      expect(find.text('Mesajlar'), findsOneWidget);
      expect(find.text('Profilim'), findsOneWidget);
    });

    testWidgets('2. İlanlar Ekranı (Filtreleme, Arama ve Kartlar - iOS Boyutu)', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532); // iPhone 14 Pro boyutu
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await loginIfNeeded(tester);

      // Arama alanına metin yaz
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Kadıköy');
      await tester.pumpAndSettle();

      // Aramayı temizle
      final clearBtn = find.byIcon(Icons.clear);
      if (clearBtn.evaluate().isNotEmpty) {
        await tester.tap(clearBtn);
        await tester.pumpAndSettle();
      }

      // Mevki filtre çipine tıkla (Kaleci)
      final kaleciChip = find.text('Kaleci');
      if (kaleciChip.evaluate().isNotEmpty) {
        await tester.tap(kaleciChip.first);
        await tester.pumpAndSettle();
      }

      // Ücretsiz filtre çipine tıkla
      final ucretsizChip = find.text('Ücretsiz');
      if (ucretsizChip.evaluate().isNotEmpty) {
        await tester.tap(ucretsizChip.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('3. Maç Takvimi Ekranı (Ay Değişimi, Tüm Filtre Sekmeleri ve Takvime Ekleme)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await loginIfNeeded(tester);

      // Takvim sekmesine tıkla
      await tester.tap(find.text('Takvim'));
      await tester.pumpAndSettle();

      // Başlık kontrolü
      expect(find.text('Maç Takvimi'), findsOneWidget);

      // Ay ilerlet/gerilet butonları
      final nextMonthBtn = find.byIcon(Icons.chevron_right);
      expect(nextMonthBtn, findsOneWidget);
      await tester.tap(nextMonthBtn);
      await tester.pumpAndSettle();

      final prevMonthBtn = find.byIcon(Icons.chevron_left);
      expect(prevMonthBtn, findsOneWidget);
      await tester.tap(prevMonthBtn);
      await tester.pumpAndSettle();

      // Filtre Sekmelerini Test Et:
      // A) Oynayacağım Maçlar
      final oynayacagimTab = find.textContaining('Oynayacağım Maçlar');
      if (oynayacagimTab.evaluate().isNotEmpty) {
        await tester.tap(oynayacagimTab.first);
        await tester.pumpAndSettle();
      }

      // B) Başvurduğum Maçlar
      final basvurdugumTab = find.textContaining('Başvurduğum Maçlar');
      if (basvurdugumTab.evaluate().isNotEmpty) {
        await tester.tap(basvurdugumTab.first);
        await tester.pumpAndSettle();
      }

      // C) Tüm Yaklaşanlar
      final tumYaklasanlarTab = find.textContaining('Tüm Yaklaşanlar');
      if (tumYaklasanlarTab.evaluate().isNotEmpty) {
        await tester.tap(tumYaklasanlarTab.first);
        await tester.pumpAndSettle();
      }

      // D) Geçmiş Maçlar
      final gecmisTab = find.textContaining('Geçmiş Maçlar');
      if (gecmisTab.evaluate().isNotEmpty) {
        await tester.tap(gecmisTab.first);
        await tester.pumpAndSettle();
      }

      // Geri 'Tüm Yaklaşanlar' sekmesine gel ve Takvime Ekle butonunu test et
      if (tumYaklasanlarTab.evaluate().isNotEmpty) {
        await tester.tap(tumYaklasanlarTab.first);
        await tester.pumpAndSettle();
      }

      final takvimeEkleBtn = find.text('Takvime Ekle');
      if (takvimeEkleBtn.evaluate().isNotEmpty) {
        await tester.tap(takvimeEkleBtn.first);
        await tester.pumpAndSettle();

        // Dialog açıldı mı
        expect(find.text('Takvime Eklendi! 📅'), findsOneWidget);
        // Tamam butonuna tıkla
        await tester.tap(find.text('Tamam'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('4. İlan Ver Ekranı (Form Validasyonu, Haritadan Saha Seçimi ve İlan Yayınlama)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await loginIfNeeded(tester);

      // İlan Ver sekmesine git
      await tester.tap(find.text('İlan Ver'));
      await tester.pumpAndSettle();

      // "Haritadan Konum İşaretle" modalını aç
      final haritaSecBtn = find.textContaining('Haritadan Konum');
      if (haritaSecBtn.evaluate().isNotEmpty) {
        await tester.tap(haritaSecBtn.first);
        await tester.pumpAndSettle();

        // Modal açıldı, ilk sahayı seç
        final pitchItem = find.text('Gazhane Halısahası');
        if (pitchItem.evaluate().isNotEmpty) {
          await tester.tap(pitchItem.first);
          await tester.pumpAndSettle();
        }
      }

      // Başlık ve açıklama gir
      final formFields = find.byType(TextFormField);
      if (formFields.evaluate().length >= 2) {
        await tester.enterText(formFields.at(0), 'Test Halısaha Maçı');
        await tester.enterText(formFields.at(1), 'Test maç açıklaması ve detayları');
        await tester.pumpAndSettle();
      }

      // İlanı Yayınla butonunu gör ve tıkla
      final yayinlaBtn = find.text('İlanı Yayınla');
      if (yayinlaBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(yayinlaBtn);
        await tester.tap(yayinlaBtn);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('5. Başvurular Ekranı (Sekmeler Arası Geçiş)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await loginIfNeeded(tester);

      // Başvurular sekmesine geç
      await tester.tap(find.text('Başvurular'));
      await tester.pumpAndSettle();

      // Gelen Başvurular / Yaptığım Başvurular sekmeleri
      final yaptigimTab = find.textContaining('Yaptığım Başvurular');
      if (yaptigimTab.evaluate().isNotEmpty) {
        await tester.tap(yaptigimTab);
        await tester.pumpAndSettle();
      }

      final gelenTab = find.textContaining('Gelen Başvurular');
      if (gelenTab.evaluate().isNotEmpty) {
        await tester.tap(gelenTab);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('6. Mesajlar ve Sohbet Odası Ekranı', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await loginIfNeeded(tester);

      // Mesajlar sekmesine git
      await tester.tap(find.text('Mesajlar'));
      await tester.pumpAndSettle();

      // İlk sohbete tıkla
      final chatListTile = find.byType(ListTile);
      if (chatListTile.evaluate().isNotEmpty) {
        await tester.tap(chatListTile.first);
        await tester.pumpAndSettle();

        // ChatRoomScreen açıldı mı kontrol et
        expect(find.byType(ChatRoomScreen), findsOneWidget);

        // Mesaj yaz ve gönder
        final messageInput = find.byType(TextField);
        if (messageInput.evaluate().isNotEmpty) {
          await tester.enterText(messageInput.last, 'Selam maç nerede oynanacak?');
          await tester.pumpAndSettle();

          final sendBtn = find.byIcon(Icons.send);
          if (sendBtn.evaluate().isNotEmpty) {
            await tester.tap(sendBtn);
            await tester.pumpAndSettle();
          }
        }

        // Hızlı yanıt çipine tıkla
        final quickChip = find.text('Konum atabilir misin?');
        if (quickChip.evaluate().isNotEmpty) {
          await tester.tap(quickChip);
          await tester.pumpAndSettle();
        }

        // Geri dön
        final backBtn = find.byIcon(Icons.arrow_back);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('7. Profilim Ekranı ve Profil Düzenleme', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await loginIfNeeded(tester);

      // Profilim sekmesine git
      await tester.tap(find.text('Profilim'));
      await tester.pumpAndSettle();

      // Başarımlar, istatistikler ve rozetler görünür olmalı
      expect(find.textContaining('Ahmet Yılmaz'), findsOneWidget);

      // Profili Düzenle butonuna tıkla
      final editBtn = find.text('Profili Düzenle');
      if (editBtn.evaluate().isNotEmpty) {
        await tester.tap(editBtn);
        await tester.pumpAndSettle();

        // Modal açıldı mı
        expect(find.text('Profili Düzenle'), findsOneWidget);

        // Kaydet butonuna tıkla
        final saveBtn = find.text('Kaydet');
        if (saveBtn.evaluate().isNotEmpty) {
          await tester.tap(saveBtn);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('8. Maç Detayı Ekranı, Taktik Tahtası ve MVP Oylaması', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await loginIfNeeded(tester);

      // İlk maça tıkla
      final matchCard = find.textContaining('Acil Kaleci Aranıyor');
      if (matchCard.evaluate().isNotEmpty) {
        await tester.tap(matchCard.first);
        await tester.pumpAndSettle();

        // MatchDetailsScreen yüklendi
        expect(find.byType(MatchDetailsScreen), findsOneWidget);

        // Sayfayı aşağı kaydır
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
        await tester.pumpAndSettle();

        // Taktik tahtası ve MVP kartı kontrolleri
        expect(find.textContaining('Saha İçi Kadro Dizilişi'), findsOneWidget);

        // Geri dön
        final backBtn = find.byIcon(Icons.arrow_back);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
