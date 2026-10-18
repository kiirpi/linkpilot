# ChooseBrowser for URL

macOS'ta URL/domain bazında açılacak tarayıcıyı seçmenizi sağlayan bir menubar uygulaması.

## Özellikler

- ✅ URL/domain bazında tarayıcı yönlendirme
- ✅ Wildcard desteği (*.google.com gibi)
- ✅ Menubar'dan kolay yönetim
- ✅ Otomatik ayar kaydetme
- ✅ Çoklu tarayıcı desteği (Safari, Chrome, Firefox, Edge, Arc, Brave)
- ✅ Bildirimler ile anlık geri bildirim

## Kurulum

### 1. Projeyi Build Etme

```bash
xcodebuild -project ChooseBrowser.xcodeproj -scheme ChooseBrowser -configuration Release clean build
```

Build edilen uygulama şu dizinde olacak:
```
~/Library/Developer/Xcode/DerivedData/ChooseBrowser-*/Build/Products/Release/ChooseBrowser.app
```

### 2. Uygulamayı Yükleme

Build edilen `.app` dosyasını `/Applications` dizinine kopyalayın:

```bash
cp -R ~/Library/Developer/Xcode/DerivedData/ChooseBrowser-*/Build/Products/Release/ChooseBrowser.app /Applications/
```

### 3. Varsayılan Tarayıcı Olarak Ayarlama

**Sistem Tercihleri → Safari → Varsayılan Tarayıcı** bölümünden ChooseBrowser'ı seçin.

### 4. Uygulamayı Başlatma

ChooseBrowser'ı açın. İlk açılışta menubar'da görünecektir.

## Kullanım

### Kural Ekleme

1. Menubar'daki ChooseBrowser simgesine tıklayın
2. **Settings** butonuna tıklayın
3. **Add Rule** sekmesine geçin
4. Domain ve tarayıcı seçin
5. **Add Rule** butonuna tıklayın

### Kural Formatları

- `google.com` - Sadece google.com ve tüm alt domainleri
- `*.github.com` - Tüm GitHub alt domainleri
- `mail.google.com` - Sadece Gmail

### Kural Yönetimi

- **Toggle**: Kuralı aktif/pasif yap
- **Edit**: Kuralı düzenle
- **Delete**: Kuralı sil

## Desteklenen Tarayıcılar

- Safari
- Google Chrome
- Firefox
- Microsoft Edge
- Arc
- Brave Browser

## Nasıl Çalışıyor?

1. Uygulama macOS'te varsayılan tarayıcı olarak kayıt olur
2. Bir linke tıklandığında, URL ChooseBrowser'a gelir
3. ChooseBrowser, kayıtlı kuralları kontrol eder
4. Eşleşen kural varsa, URL'yi belirtilen tarayıcıda açar
5. Eşleşme yoksa, sistem varsayılan tarayıcısında açar

## Geliştirme

### Gereksinimler

- macOS 13.0+
- Xcode 15.0+
- Swift 5.0+

### Proje Yapısı

```
ChooseBrowser/
├── ChooseBrowserApp.swift      # Ana uygulama ve URL handler
├── Models/
│   ├── BrowserRule.swift       # Kural veri modeli
│   └── RuleManager.swift       # Kural yönetimi ve URL yönlendirme
└── Views/
    ├── MenuBarView.swift       # Menubar arayüzü
    └── SettingsView.swift      # Ayarlar penceresi
```

### Derleme

```bash
xcodebuild -project ChooseBrowser.xcodeproj -scheme ChooseBrowser build
```

## Bilinen Sorunlar

- İlk açılışta güvenlik uyarısı verebilir (Sistem Tercihleri'nden izin verin)
- Bazı uygulamalar varsayılan tarayıcıyı değiştirme izni gerektirebilir

## Gelecek Özellikler

- [ ] URL pattern eşleştirme (regex desteği)
- [ ] Kural import/export
- [ ] Tarayıcı bazında istatistikler
- [ ] Otomatik güncelleme
- [ ] Dark mode desteği

## Lisans

MIT License

## Katkıda Bulunma

Pull request'ler ve issue'lar memnuniyetle karşılanır!
