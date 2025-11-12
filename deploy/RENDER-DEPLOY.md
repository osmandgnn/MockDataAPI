# Render.com Deployment Guide

MockServer'ı Render.com'a deploy ederek internetten erişilebilir hale getirin.

## 📋 Ön Gereksinimler

- GitHub hesabı
- Render.com hesabı (ücretsiz)

---

## 🚀 Deployment Adımları

### Adım 1: GitHub Repository Oluştur

```bash
# MockServer klasörünü Git repository'ye ekle
cd /mnt/c/energy-portal

# Git init (eğer yoksa)
git init

# MockServer dosyalarını ekle
git add mockserver/
git commit -m "Add MockServer configuration for cloud deployment"

# GitHub'a push et
git remote add origin https://github.com/YOUR_USERNAME/energy-portal.git
git push -u origin main
```

### Adım 2: Render.com'a Kaydol

1. https://render.com adresine git
2. "Get Started" → "Sign Up with GitHub"
3. GitHub hesabınla giriş yap

### Adım 3: New Web Service Oluştur

1. Dashboard'da **"New +"** → **"Web Service"**
2. Repository seç: `energy-portal`
3. **"Connect"** butonuna tıkla

### Adım 4: Konfigürasyon

**Basic Settings:**
```
Name: energy-portal-mockserver
Region: Frankfurt (Germany)
Branch: main
Root Directory: mockserver
```

**Build & Deploy:**
```
Runtime: Docker
Dockerfile Path: ./Dockerfile
Docker Command: (boş bırak)
```

**Plan:**
```
Instance Type: Free
```

**Environment Variables:**
```
MOCKSERVER_LOG_LEVEL = INFO
MOCKSERVER_INITIALIZATION_JSON_PATH = /config/mockserver-initialization.json
MOCKSERVER_ENABLE_CORS_FOR_API = true
MOCKSERVER_ENABLE_CORS_FOR_ALL_RESPONSES = true
```

### Adım 5: Deploy

1. **"Create Web Service"** butonuna tıkla
2. Deploy başlayacak (3-5 dakika sürer)
3. URL kopyala: `https://energy-portal-mockserver.onrender.com`

---

## ✅ Test

### Health Check

```bash
curl https://energy-portal-mockserver.onrender.com/mockserver/status
```

### GetStatus Test

```bash
curl -X POST https://energy-portal-mockserver.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/GetStatus" \
  -d '<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetStatus xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <LocaleID>en-us</LocaleID>
    </GetStatus>
  </soap:Body>
</soap:Envelope>'
```

### Read Test

```bash
curl -X POST https://energy-portal-mockserver.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Read xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <ItemList>
        <Items>
          <Items><ItemName>01WEA82943/analog/PwrAct</ItemName></Items>
        </Items>
      </ItemList>
    </Read>
  </soap:Body>
</soap:Envelope>'
```

---

## 🔧 Backend Konfigürasyonu

### application-test.yml

```yaml
# Test ortamı için
spring:
  profiles: test

opc:
  endpoints:
    base-url: https://energy-portal-mockserver.onrender.com/nordex/services/nordex_opc
    timeout: 180000
    locale-id: en-us
```

### Database Update (Test Environment)

```sql
-- Test ortamı veritabanında
UPDATE plants
SET opc_endpoint_url = 'https://energy-portal-mockserver.onrender.com/nordex/services/nordex_opc'
WHERE opc_endpoint_url IS NOT NULL;
```

### Environment Variable (Staging/Production)

```bash
# .env dosyasına ekle
OPC_MOCK_ENABLED=true
OPC_MOCK_BASE_URL=https://energy-portal-mockserver.onrender.com/nordex/services/nordex_opc
```

---

## 📊 Monitoring

### Render Dashboard

1. https://dashboard.render.com
2. Services → energy-portal-mockserver
3. **Logs** sekmesi → Canlı loglar
4. **Metrics** sekmesi → CPU/Memory kullanımı

### MockServer Dashboard

```
https://energy-portal-mockserver.onrender.com/mockserver/dashboard
```

---

## 🌍 Multi-Environment Setup

### Development (Local)
```
http://localhost:1080/nordex/services/nordex_opc
```

### Test (Render.com)
```
https://energy-portal-mockserver.onrender.com/nordex/services/nordex_opc
```

### Staging (Render.com - başka branch)
```
https://energy-portal-mockserver-staging.onrender.com/nordex/services/nordex_opc
```

### Production (Gerçek Nordex sunucuları)
```
http://78.188.16.11:8034/nordex/services/nordex_opc (Silivri)
http://95.9.229.118:8060/nordex/services/nordex_opc (Tokat)
...
```

---

## ⚠️ Önemli Notlar

### Free Tier Sınırlamaları

- **Auto-sleep:** 15 dakika inaktivite sonrası uyur
- **Cold start:** İlk request 30-60 saniye sürebilir
- **750 saat/ay:** Yeterli (24/7 = 720 saat)

### Auto-Sleep Çözümü

**Seçenek 1: Cron Job (UptimeRobot)**
- https://uptimerobot.com (ücretsiz)
- 5 dakikada bir ping at
- MockServer her zaman uyanık kalır

**Seçenek 2: GitHub Actions**
```yaml
# .github/workflows/keep-alive.yml
name: Keep MockServer Alive
on:
  schedule:
    - cron: '*/10 * * * *'  # Her 10 dakika
jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: Ping MockServer
        run: curl https://energy-portal-mockserver.onrender.com/mockserver/status
```

### Custom Domain (Opsiyonel)

1. Render Dashboard → Settings → Custom Domains
2. Domain ekle: `mockserver.yourdomain.com`
3. DNS CNAME ekle
4. SSL otomatik aktif olur

---

## 🔐 Güvenlik

### CORS Ayarları

Zaten environment variable ile açık:
```
MOCKSERVER_ENABLE_CORS_FOR_ALL_RESPONSES=true
```

### IP Whitelisting (Paid plan)

Render Pro plan ile sadece belirli IP'lerden erişime izin verebilirsiniz.

### Authentication (Opsiyonel)

MockServer config'e auth ekleyebilirsiniz:
```json
{
  "httpRequest": {
    "headers": {
      "Authorization": ["Bearer YOUR_SECRET_TOKEN"]
    }
  }
}
```

---

## 💰 Maliyet

**Free Tier:**
- 750 saat/ay (24/7 çalışır)
- Auto-sleep (15 dakika inaktivite)
- 512 MB RAM
- 0.1 CPU

**Starter Plan ($7/ay):**
- Always on (no sleep)
- 512 MB RAM
- 0.5 CPU
- Priority support

**Sizin için Free Tier yeterli!**

---

## 🆘 Sorun Giderme

### Deploy başarısız

```bash
# Logs kontrol et
# Render Dashboard → Logs

# Local test
cd mockserver
docker build -t test-mockserver .
docker run -p 1080:1080 test-mockserver
```

### Cold start çok uzun

- UptimeRobot ile keep-alive setup
- Veya Starter plan'e geç ($7/ay)

### CORS hatası

Environment variable kontrol et:
```
MOCKSERVER_ENABLE_CORS_FOR_ALL_RESPONSES=true
```

---

## 🎯 Sonraki Adımlar

1. ✅ GitHub'a push et
2. ✅ Render.com'a deploy et
3. ✅ URL'i test et
4. ✅ Backend konfigürasyonunu güncelle
5. ✅ Test ortamında dene
6. 📊 Monitoring kur (UptimeRobot)

---

**Render.com URL'iniz hazır olduğunda tüm ortamlarda kullanabilirsiniz!** 🚀
