# Codemagic ile iOS Uygulaması Build Etme Rehberi

Bu rehber, AI Agent iOS uygulamasını Codemagic CI/CD platformu kullanarak nasıl build edip yayınlayabileceğinizi adım adım açıklamaktadır.

## Codemagic'e Uygulama Ekleme

1. [Codemagic](https://codemagic.io/)'e giriş yapın
2. Uygulamalar sayfasında **Add application** butonuna tıklayın
3. Birden fazla takımınız varsa, uygulamayı eklemek istediğiniz takımı seçin
4. Kaynak kodunuzun bulunduğu repository'yi bağlayın
5. Repository'nizi listeden seçin ve uygun proje tipini (iOS App) seçin
6. **Finish: Add application** butonuna tıklayın

## codemagic.yaml Dosyası

Codemagic ile build yapılandırması için `codemagic.yaml` dosyasını repository'nizin kök dizinine eklemeniz gerekmektedir. Bu projede hazır bir `codemagic.yaml` dosyası bulunmaktadır.

### codemagic.yaml Dosyasının Yapısı

```yaml
workflows:
  ios-workflow:
    name: iOS AI Agent Workflow
    instance_type: mac_mini_m2
    max_build_duration: 120
    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.example.AIAgent
      vars:
        XCODE_WORKSPACE: "AIAgent.xcworkspace"
        XCODE_SCHEME: "AIAgent"
      xcode: latest
      cocoapods: default
    scripts:
      - name: Set up code signing
        script: |
          # Code signing ayarları
      - name: Increment build number
        script: |
          # Build numarasını artırma
      - name: Build iOS app
        script: |
          # iOS uygulamasını build etme
      - name: Create .ipa
        script: |
          # IPA dosyası oluşturma
    artifacts:
      # Build çıktıları
    publishing:
      # Yayınlama ayarları
```

## Yapılandırma Adımları

### 1. Kod İmzalama (Code Signing) Ayarları

Codemagic'te iOS uygulamanızı imzalamak için iki seçeneğiniz vardır:

- **Otomatik kod imzalama**: App Store Connect API anahtarı kullanarak
- **Manuel kod imzalama**: Sertifikaları ve profilleri manuel olarak yükleme

#### Otomatik Kod İmzalama İçin Gerekli Ortam Değişkenleri

- `APP_STORE_CONNECT_PRIVATE_KEY`
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_ISSUER_ID`

Bu değişkenleri Codemagic UI'da **Environment variables** bölümünden ekleyebilirsiniz.

### 2. Build Numarasını Artırma

Her build için otomatik olarak build numarasını artırmak için `codemagic.yaml` dosyasında bir script bulunmaktadır. Bu script, App Store Connect'ten en son build numarasını alır ve bir artırır.

### 3. Build ve IPA Oluşturma

Xcode build komutları, uygulamanızı derlemek ve IPA dosyası oluşturmak için kullanılır. Bu komutlar `codemagic.yaml` dosyasında tanımlanmıştır.

### 4. App Store'a Yayınlama

Codemagic, uygulamanızı doğrudan App Store Connect'e ve TestFlight'a yükleyebilir. Bunun için App Store Connect API anahtarı gereklidir.

## Build Tetikleme

Codemagic'te build'i tetiklemek için birkaç yöntem vardır:

1. **Manuel tetikleme**: Codemagic UI'dan "Start new build" butonuna tıklayarak
2. **Otomatik tetikleme**: Git olaylarına (push, pull request vb.) bağlı olarak

### Otomatik Tetikleme Ayarları

Codemagic UI'da **Workflow settings** > **Build triggers** bölümünden otomatik tetikleme ayarlarını yapılandırabilirsiniz:

- Hangi branch'lerin build'i tetikleyeceğini seçin (örn. main, release/*)
- Pull request'lerin build'i tetikleyip tetiklemeyeceğini belirleyin
- Tag'lerin build'i tetikleyip tetiklemeyeceğini belirleyin

## Build Durumunu İzleme

Build durumunu Codemagic UI'dan izleyebilirsiniz. Ayrıca, e-posta bildirimleri ve Slack entegrasyonu gibi seçenekler de mevcuttur.

## Sorun Giderme

Build hatalarını gidermek için:

1. Build loglarını kontrol edin
2. Kod imzalama ayarlarını doğrulayın
3. Ortam değişkenlerinin doğru ayarlandığından emin olun
4. Xcode sürümünün projenizle uyumlu olduğunu kontrol edin

## Daha Fazla Bilgi

Daha detaylı bilgi için [Codemagic Dokümantasyonu](https://docs.codemagic.io/)nu inceleyebilirsiniz.