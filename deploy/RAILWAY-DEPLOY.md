# Railway.app Deployment Guide

Railway.app ile MockServer'ı en hızlı şekilde deploy edin (5 dakika).

## 📋 Ön Gereksinimler

- GitHub hesabı
- Railway.app hesabı

---

## 🚀 Hızlı Deployment (CLI ile - 5 dakika)

### Adım 1: Railway CLI Kurulumu

```bash
# npm ile kurulum
npm install -g @railway/cli

# Veya Homebrew (Mac)
brew install railway

# Veya curl (Linux/WSL)
curl -fsSL https://railway.app/install.sh | sh
```

### Adım 2: Login

```bash
railway login
```

Tarayıcı açılacak, GitHub ile giriş yap.

### Adım 3: Proje Oluştur ve Deploy

```bash
# MockServer dizinine git
cd /mnt/c/energy-portal/mockserver

# Railway projesini başlat
railway init

# Proje adı belirle
# → energy-portal-mockserver

# Deploy et
railway up

# Public URL al
railway domain
```

**5 dakikada hazır!** 🎉

URL: `https://mockserver-production-xxxx.up.railway.app`

---

## 🌐 Web UI ile Deployment (Alternatif)

### Adım 1: Railway Dashboard

1. https://railway.app → "Start a New Project"
2. "Deploy from GitHub repo" seç
3. Repository: `energy-portal`
4. Select root path: `mockserver`

### Adım 2: Konfigürasyon

Railway otomatik Dockerfile'ı algılar!

**Environment Variables:**
```
MOCKSERVER_LOG_LEVEL = INFO
MOCKSERVER_INITIALIZATION_JSON_PATH = /config/mockserver-initialization.json
MOCKSERVER_ENABLE_CORS_FOR_API = true
MOCKSERVER_ENABLE_CORS_FOR_ALL_RESPONSES = true
```

### Adım 3: Generate Domain

1. Settings → Networking
2. "Generate Domain" butonuna tıkla
3. URL kopyala: `https://energy-portal-mockserver.up.railway.app`

---

## ✅ Test

```bash
# Health check
curl https://energy-portal-mockserver.up.railway.app/mockserver/status

# GetStatus test
curl -X POST https://energy-portal-mockserver.up.railway.app/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/GetStatus" \
  -d '<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetStatus xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <LocaleID>en-us</LocaleID>
    </GetStatus>
  </soap:Body>
</soap:Envelope>'
```

---

## 🔧 Backend Konfigürasyonu

### Environment Variables

```bash
# .env veya application.yml
OPC_ENDPOINT_URL=https://energy-portal-mockserver.up.railway.app/nordex/services/nordex_opc
```

### Database Update

```sql
UPDATE plants
SET opc_endpoint_url = 'https://energy-portal-mockserver.up.railway.app/nordex/services/nordex_opc'
WHERE opc_endpoint_url IS NOT NULL;
```

---

## 📊 Monitoring

### Railway Dashboard

```
https://railway.app/project/YOUR_PROJECT_ID
```

- **Deployments:** Deploy geçmişi
- **Metrics:** CPU, Memory, Network
- **Logs:** Canlı loglar
- **Settings:** Domain, env vars

### CLI ile Log İzleme

```bash
# Canlı logları izle
railway logs

# Son 100 satır
railway logs --tail 100
```

---

## 🌍 Multi-Environment Setup

### Development Environment

```bash
railway environment add development
railway environment use development
railway up
```

### Staging Environment

```bash
railway environment add staging
railway environment use staging
railway up
```

Her environment'ın kendi URL'i olur:
- Dev: `https://mockserver-development-xxxx.up.railway.app`
- Staging: `https://mockserver-staging-xxxx.up.railway.app`
- Prod: `https://mockserver-production-xxxx.up.railway.app`

---

## 💰 Maliyet

**Free Trial:**
- $5 ücretsiz kredi
- ~140 saat çalışma
- 512 MB RAM
- 1 GB disk

**Starter Plan ($5/ay):**
- $5 kredi dahil
- Always on
- Shared CPU
- Metrics

**Developer Plan ($20/ay):**
- $20 kredi dahil
- Priority support
- Team collaboration

**Usage-based pricing:**
- $0.000231/GB-hour (RAM)
- $0.000463/vCPU-hour (CPU)

**Tahmini aylık maliyet (24/7):**
- ~$3-5/ay (512 MB RAM + shared CPU)

---

## ⚡ Avantajları

```
✅ En hızlı deployment (5 dakika)
✅ Otomatik Dockerfile detection
✅ GitHub auto-deploy
✅ Built-in monitoring
✅ Multiple environments
✅ CLI çok güçlü
✅ Rollback 1 tık
✅ Metrics dahili
```

---

## 🔄 Auto-Deploy Setup

Railway GitHub'a bağlı olduğunda otomatik deploy olur:

```bash
# Değişiklik yap
echo "# Updated" >> README.md

# Commit + push
git add .
git commit -m "Update MockServer config"
git push

# Railway otomatik deploy eder! 🚀
```

---

## 🔐 Özel Domain

```bash
# CLI ile custom domain ekle
railway domain add mockserver.yourdomain.com

# DNS'e CNAME ekle
# mockserver.yourdomain.com → CNAME → your-app.up.railway.app

# SSL otomatik aktif olur
```

---

## 🆘 Sorun Giderme

### Port problemi

Railway `PORT` environment variable sağlar. Dockerfile'da:
```dockerfile
CMD ["mockserver", "-serverPort", "${PORT:-1080}"]
```

Ama MockServer zaten 1080 kullanıyor, Railway otomatik map eder.

### Deploy hatası

```bash
# Logs kontrol et
railway logs

# Local test
railway run bash
```

### Environment variable eklenemedi

```bash
# CLI ile ekle
railway variables set MOCKSERVER_LOG_LEVEL=DEBUG
```

---

## 🎯 Railway vs Render

| Özellik | Railway | Render |
|---------|---------|--------|
| **Setup hızı** | ⚡ 5 dakika | ⏱️ 10 dakika |
| **Free tier** | $5 kredi | 750 saat |
| **Auto-sleep** | ❌ Yok | ✅ 15 dakika |
| **CLI** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Metrics** | ✅ Built-in | ⚠️ Paid |
| **Maliyet (24/7)** | ~$3-5/ay | Ücretsiz |

**Sonuç:** Railway daha profesyonel, Render daha ucuz.

---

## 📚 Kaynaklar

- [Railway Docs](https://docs.railway.app/)
- [Railway CLI Reference](https://docs.railway.app/develop/cli)
- [Railway Templates](https://railway.app/templates)

---

**Railway.app ile MockServer 5 dakikada hazır!** 🚀
