# Uygulama_Geliştirme

> Bu dosya her oturumda otomatik yüklenir. Kısa ve güncel tutulur; uygulama
> seçildikçe "Stack" ve "Komutlar" bölümleri doldurulur.

## Proje

- Durum: henüz uygulama seçilmedi (boş depo).
- Platform: Windows 11, PowerShell birincil kabuk; Git Bash de mevcut.
- Depo: git (`master`), henüz commit yok.

## Stack

_(Uygulama başlarken doldurulacak: dil, framework, veritabanı, paket yöneticisi.)_

## Komutlar

_(Uygulama başlarken doldurulacak.)_

| Amaç      | Komut |
| --------- | ----- |
| Kurulum   | —     |
| Geliştirme| —     |
| Test      | —     |
| Build     | —     |
| Lint      | —     |

## Çalışma kuralları

- **Yanıtlar Türkçe ve kısa.** Kod ve sonuç odaklı; uzun özet/gerekçe yazma.
- **Geniş aramalarda Explore alt-ajanı kullanılır** — ham dosya dökümleri ana
  bağlamı şişirmesin diye.
- **Kütüphane/API dokümantasyonu context7 ile çekilir**, ezberden API yazılmaz.
- **Büyük dosyalar parça parça okunur** (tüm dosya değil, ilgili satır aralığı).
- **Model:** varsayılan Sonnet 5; mimari tasarım, zor debug ve kod incelemesi
  için Opus'a geçilir (`/model`).

## Otomasyon

- `.claude/hooks/format.mjs` — Write/Edit sonrası, `package.json` varsa
  `npx prettier --write` ile değişen dosyayı biçimlendirir; prettier veya
  `package.json` yoksa sessizce çıkar.
- `.claude/settings.json` — yaygın read-only ve build komutları için izin
  listesi (onay istemlerini azaltır).
- Kurulu eklentiler: `frontend-design`, `context7`, `superpowers`.
