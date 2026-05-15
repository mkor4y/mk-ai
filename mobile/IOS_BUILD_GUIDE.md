# iOS Build ve Dağıtım Rehberi

## Sorun: Beyaz Ekran + Crash

### Neden Oluyordu?
1. **.env dosyası assets'e eklenmemişti** → `pubspec.yaml` düzeltildi ✅
2. **Podfile eksikti** → `ios/Podfile` oluşturuldu ✅
3. **Google Fonts izin sorunu** → `Info.plist` güncellendi ✅

---

## Codemagic ile Build Alma

### 1. Codemagic'te Environment Variables Ayarla

Codemagic dashboard → App Settings → Environment variables:

```
API_BASE_URL = https://your-production-api.com
```

### 2. Build Workflow

`codemagic.yaml` dosyası otomatik olarak:
- `.env` dosyasını oluşturur
- Flutter paketlerini indirir
- CocoaPods bağımlılıklarını kurar
- iOS IPA dosyasını build eder

### 3. Build Komutu (Manuel)

Eğer Codemagic kullanmıyorsan:

```bash
cd mobile

# 1. .env dosyasını oluştur
echo "API_BASE_URL=https://your-production-api.com" > .env

# 2. Flutter paketlerini indir
flutter pub get

# 3. CocoaPods bağımlılıklarını kur
cd ios
pod install
cd ..

# 4. iOS build
flutter build ipa --release
```

---

## Sideloadly ile Yükleme

### 1. IPA Dosyasını Bul

Build sonrası:
```
mobile/build/ios/ipa/mk_ai_mobile.ipa
```

### 2. Sideloadly Adımları

1. IPA dosyasını Sideloadly'ye sürükle
2. Apple ID'ni gir
3. Bundle ID'yi kontrol et: `com.mkoray.mkai`
4. "Start" butonuna bas
5. iPhone'a yükle

### 3. iPhone'da Güven Ayarı

```
Ayarlar → Genel → VPN ve Cihaz Yönetimi → [Apple ID] → Güven
```

---

## Hata Ayıklama

### Crash Loglarını Görme

iPhone'u Mac'e bağla:

```bash
# Xcode Console
Xcode → Window → Devices and Simulators → [Cihazını seç] → View Device Logs
```

### Yaygın Hatalar

**1. "App crashes immediately"**
- `.env` dosyası build'e dahil mi? → `pubspec.yaml` kontrol et
- CocoaPods kuruldu mu? → `pod install` çalıştır

**2. "White screen then crash"**
- `Info.plist`'te font izinleri var mı?
- API URL doğru mu? → `.env` dosyasını kontrol et

**3. "Provisioning profile error"**
- Bundle ID doğru mu? → `com.mkoray.mkai`
- Apple Developer hesabı aktif mi?

---

## Production Checklist

- [ ] `.env` dosyasında production API URL'i
- [ ] `pubspec.yaml`'da assets bölümü açık
- [ ] `ios/Podfile` mevcut
- [ ] `Info.plist`'te font izinleri var
- [ ] Codemagic'te environment variables ayarlı
- [ ] Bundle ID doğru: `com.mkoray.mkai`

---

## Notlar

- **Sideloadly ile yüklenen uygulamalar 7 günde bir yeniden imzalanmalı** (ücretsiz Apple Developer hesabı)
- **TestFlight kullanmak istersen**: App Store Connect'e yükle
- **Enterprise dağıtım istersen**: Apple Developer Enterprise hesabı gerekli
