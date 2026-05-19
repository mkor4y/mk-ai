# MK AI — iPhone 16 Pro Max'e Ücretsiz Yükleme Rehberi

> Bu rehber **Apple Developer Program ($99/yıl) hesabı OLMADAN** uygulamayı kendi iPhone'una yüklemen içindir.

## Akışın Özeti

```
[Codemagic — macOS]                   [Windows PC]                 [iPhone 16 Pro Max]
  flutter build ios   ──►  .ipa  ──►  Sideloadly + Apple ID  ──►  Uygulama yüklendi
  (imzasız)                            (USB ile bağlı iPhone)        (7 gün geçerli)
```

⚠️ **Önemli kısıtlama (Ücretsiz Apple ID kuralı):**
- Yüklenen uygulama **7 gün sonra açılmaz** olur. Aynı işlemi tekrarlayıp yeniden imzalaman gerekir.
- Aynı anda en fazla **3 sideloaded uygulama** kurulu olabilir.
- Bu kısıtları aşmak için **Apple Developer Program ($99/yıl)** gerekir; o zaman 1 yıl geçerli olur ve TestFlight kullanabilirsin.

---

## 1. Codemagic Kurulumu (tek seferlik)

1. https://codemagic.io adresine GitHub/GitLab ile giriş yap.
2. **Add application** → reponu seç (`mymodel`).
3. **Settings → Build configuration → Use codemagic.yaml** (zaten repo'da var).
4. **Workflow** olarak `iOS Unsigned IPA (Sideloadly)` seç.
5. **Start new build** de.

İlk build ~10-15 dakika sürer (pod install + Flutter build).

### Build bittiğinde
- Sağ üstte **Artifacts** kutusunda `MK_AI-unsigned.ipa` görünür → indir.
- İstersen `codemagic.yaml`'da `publishing.email.recipients` listesine e-postanı yazarsan link otomatik gelir.

---

## 2. Sideloadly ile iPhone'a Yükleme (Windows)

### a) Sideloadly Kur
1. https://sideloadly.io → **Download for Windows**.
2. Kurulum sırasında **iTunes** + **iCloud** Apple resmi paketlerini de kurman istenir (henüz yoksa). Mutlaka Microsoft Store sürümünü değil, Apple'ın **classic .exe** sürümlerini kur:
   - iTunes (64-bit): https://www.apple.com/itunes/download/win64
   - iCloud (64-bit): https://support.apple.com/en-us/HT204283

### b) iPhone'u Hazırla
1. iPhone'u USB-C kabloyla bilgisayara bağla.
2. İlk bağlantıda iPhone'da çıkan **"Bu bilgisayara güveniyor musunuz?"** uyarısına **Güven** de.
3. iPhone'un **Ayarlar → Privacy & Security → Developer Mode**'u aktif et (iOS 16+):
   - Toggle'ı aç → iPhone yeniden başlar → açılışta tekrar onayla.

### c) Sideloadly ile İmzala + Yükle
1. Sideloadly'yi aç.
2. **IPA file**: indirdiğin `MK_AI-unsigned.ipa`'yı sürükle.
3. **Apple ID**: kendi Apple ID e-postanı yaz.
4. **Device**: iPhone otomatik algılanır.
5. **Advanced options** (isteğe bağlı):
   - **Custom Bundle ID**: dokunma, `com.mkoray.mkai` olduğu gibi kalsın.
   - **AppSync / dylib**: kapalı kalsın.
6. **Start** bas.
7. Apple ID **şifreni** isteyebilir → bu cihaza özel **app-specific password** kullanmalısın:
   - https://account.apple.com → Sign-In and Security → App-Specific Passwords → "Sideloadly" adlı bir tane oluştur, oradaki 16 karakterli şifreyi gir.
8. Sideloadly ipa'yı imzalayıp telefona yükler (~2 dakika).

### d) iPhone'da Güven (Trust)
1. **Ayarlar → Genel → VPN ve Cihaz Yönetimi**.
2. Kendi Apple ID'nle imzalanmış geliştirici profilini gör → **Trust** (Güven) de.
3. Ana ekranda **MK AI** ikonu çıkar, aç.

---

## 3. Sık Karşılaşılan Sorunlar

| Sorun | Çözüm |
|---|---|
| Sideloadly "Unable to install" hatası | iPhone'u kilidini açık tut, sonra tekrar dene. Kabloyu sağlam bir USB porta tak (USB hub kullanma). |
| Apple ID şifresi reddediliyor | **App-specific password** kullan (yukarıda 2.c.7). Normal şifre 2FA nedeniyle reddedilebilir. |
| iPhone'da "Untrusted Developer" hatası | Ayarlar → Genel → VPN ve Cihaz Yönetimi'nden profili **Trust** etmedin. |
| 7 gün sonra uygulama açılmıyor | Normal. Sideloadly'yi açıp aynı .ipa ile tekrar yükle. Veriler korunur (SharedPreferences) çünkü Bundle ID değişmiyor. |
| "Maximum number of apps for free developer account reached" | Cihazda 3'ten fazla sideloaded uygulama var. Birini sil. |
| Build Codemagic'te `Pods` hatası veriyor | `mobile/ios` altında Podfile yoksa Flutter ilk build'te oluşturur; ikinci build'i dene. |

---

## 4. Codemagic Ücretsiz Kotası

- Ayda **500 build dakikası** ücretsiz (M2 mac instance).
- 1 iOS build ~10-15 dk → ayda **~30-40 build** ücretsiz.
- 7 günde bir imzalama gerektiği için ayda 4-5 build yeter → çok rahat sığarsın.

---

## 5. Apple Developer Program'a Geçersen ($99/yıl)

İleride üye olursan şu değişiklikler:
1. `codemagic.yaml`'a App Store Connect API key ekle, `cocoapods_signing` ve `app_store_connect` publishing block'u ekle.
2. **TestFlight** workflow'una geçeriz → iPhone'a App Store uygulamasından TestFlight ile kurarsın, **1 yıl** geçerli.
3. Bu rehber dosyasını `iOS_TESTFLIGHT.md` olarak güncelleriz.

İstersen söyle, o workflow için de yaml hazırlayayım.

---

## 6. Hızlı Kontrol Listesi

- [ ] Codemagic'te projeyi ekledim, `ios-unsigned` workflow'unu çalıştırdım.
- [ ] Build başarıyla bitti, `MK_AI-unsigned.ipa` indirdim.
- [ ] Windows'a Sideloadly + iTunes + iCloud kurdum.
- [ ] iPhone'da Developer Mode açtım.
- [ ] App-specific password oluşturdum.
- [ ] Sideloadly ile yükledim, iPhone'da Trust ettim.
- [ ] Uygulama açıldı, API bağlantısı çalışıyor (https://m-koray.online/api).

Sorun yaşarsan logu bana gönder, bakalım.
