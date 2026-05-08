# Geliştirme Kuralları (Development Rules) - Versiyon 2.0

Bu proje, Antigravity içerisinde çalışan deterministik bir yazılım üretim hattı olarak yönetilir. Tüm geliştirmeler ANALYZER, BUILDER ve TESTER aşamalarından geçmek zorundadır.

## 1. GLOBAL DİREKTİFLER
- **Determinizm:** Rastgelelikten kaçınılmalı, kurallara sıkı sıkıya bağlı kalınmalıdır.
- **Üretim Kalitesi:** Tüm özellikler mevcut sistemi bozmadan, "production-ready" standartlarında inşa edilmelidir.

## 2. KRİTİK SİSTEM KURALLARI
- **Mevcut Sistemi Koruma:** Mevcut kodun üzerine yazılmamalı, mantık refaktör edilmemelidir (açıkça belirtilmedikçe). Sadece genişletme veya ekleme yapılmalıdır.
- **UI Koruma Modu:** Mevcut arayüz, layout veya stiller değiştirilmemelidir. Sadece izole bileşenler eklenmelidir.
- **Modüler Mimari:** Her özellik (UI, Mantık, Veri) birbirinden ayrılmış ve kendi başına çalışabilir (self-contained) olmalıdır.
- **Deterministik Çıktı:** Birden fazla seçenek veya öneri sunulmamalı, tek ve nihai sonuç verilmelidir.
- **Açıklama Yasağı:** Çıktı sadece nihai sonuçtan oluşmalı; açıklama, muhakeme veya gerekçe içermemelidir.
- **Kapsam Kontrolü:** Sadece talep edilen görev yapılmalı, kapsam dışına çıkılmamalıdır.
- **Format:** Tüm yanıtlar kod bloğu içerisinde olmalı, düz metin içermemelidir.

## 3. İŞ AKIŞI VE GİTHUBA YÜKLEME
- **Anlık Güncelleme:** Yapılan her başarılı değişiklikten (ve analiz kontrolünden) sonra kodlar bekletilmeden GitHub'a yüklenmelidir.
- **Meticulous Code (İnce Ele Sık Doku):** Her geliştirme sonrası kullanılmayan importlar ve ölü kodlar temizlenmelidir.
- **Hata Yönetimi:** Görev belirsizse, en güvenli ve minimal versiyon uygulanmalıdır.

## 4. MULTI-AGENT EXECUTION PIPELINE
1. **ANALYZER:** Gereksinimleri ayrıştırır, kısıtlamaları tespit eder ve minimal kapsamı tanımlar.
2. **BUILDER:** Analyzer planına göre modüler ve izole geliştirmeyi yapar.
3. **TESTER:** Mevcut sistemin bozulmadığını ve UI'ın korunduğunu doğrular.

---
*Bu kurallar projenin stabilitesini ve sürdürülebilirliğini korumak için Antigravity tarafından zorunlu olarak uygulanır.*
