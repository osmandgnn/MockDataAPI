# Fly.io Deployment Guide

Fly.io ile global edge network üzerinde MockServer deploy edin.

## 📋 Ön Gereksinimler

- Fly.io hesabı (ücretsiz)
- Kredi kartı (ücretsiz plan için de gerekli, ama ücret alınmaz)

---

## 🚀 Deployment Adımları

### Adım 1: Fly CLI Kurulumu

```bash
# Linux/WSL
curl -L https://fly.io/install.sh | sh

# Mac (Homebrew)
brew install flyctl

# Windows (PowerShell)
iwr https://fly.io/install.ps1 -useb | iex
```

### Adım 2: Login

```bash
flyctl auth login
```

### Adım 3: Fly.io App Oluştur

```bash
# MockServer dizinine git
cd /mnt/c/energy-portal/mockserver

# Fly app oluştur
flyctl launch

# Sorulara cevap ver:
# App name: energy-portal-mockserver
# Region: fra (Frankfurt)
# Postgres database: No
# Redis: No
```

Fly otomatik `fly.toml` oluşturur.

### Adım 4: fly.toml Düzenle

Fly.toml dosyası oluşturuldu, şimdi düzenleyin:

```toml
# fly.toml
app = "energy-portal-mockserver"
primary_region = "fra"

[build]
  image = "mockserver/mockserver:5.15.0"

[env]
  MOCKSERVER_LOG_LEVEL = "INFO"
  MOCKSERVER_INITIALIZATION_JSON_PATH = "/config/mockserver-initialization.json"
  MOCKSERVER_ENABLE_CORS_FOR_API = "true"
  MOCKSERVER_ENABLE_CORS_FOR_ALL_RESPONSES = "true"

[http_service]
  internal_port = 1080
  force_https = true
  auto_stop_machines = false
  auto_start_machines = true
  min_machines_running = 1

[[services]]
  protocol = "tcp"
  internal_port = 1080

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

  [services.concurrency]
    type = "connections"
    hard_limit = 1000
    soft_limit = 500

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 256
```

### Adım 5: Deploy

```bash
flyctl deploy
```

Deploy tamamlanınca URL alırsınız:
```
https://energy-portal-mockserver.fly.dev
```

---

## ✅ Test

```bash
# Health check
curl https://energy-portal-mockserver.fly.dev/mockserver/status

# GetStatus test
curl -X POST https://energy-portal-mockserver.fly.dev/nordex/services/nordex_opc \
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

## 🌍 Global Edge Deployment

Fly.io birden fazla region'da çalışabilir:

```bash
# Regions listesi
flyctl regions list

# Region ekle (örnek: Istanbul, Amsterdam)
flyctl regions add ist ams

# Şimdi 3 region'da çalışıyor: Frankfurt, Istanbul, Amsterdam
```

**En yakın region otomatik cevap verir!** (Ultra-low latency)

---

## 📊 Monitoring

### Dashboard

```
https://fly.io/dashboard/energy-portal-mockserver
```

### CLI ile Monitoring

```bash
# Logları izle
flyctl logs

# Status kontrol
flyctl status

# Metrics
flyctl metrics
```

### Fly Postgres (Opsiyonel)

```bash
# Eğer MockServer state'i kaydetmek isterseniz
flyctl postgres create --name mockserver-db
flyctl postgres attach mockserver-db
```

---

## 🔧 Scaling

### Vertical Scaling (RAM/CPU)

```bash
# VM boyutunu artır
flyctl scale vm shared-cpu-2x --memory 512

# Seçenekler:
# - shared-cpu-1x (256MB) - Free
# - shared-cpu-2x (512MB) - ~$2/ay
# - shared-cpu-4x (1GB) - ~$4/ay
```

### Horizontal Scaling (Multiple instances)

```bash
# Instance sayısını artır
flyctl scale count 3

# Frankfurt: 1, Istanbul: 1, Amsterdam: 1
```

---

## 🔄 Auto-Deploy from GitHub

### GitHub Actions Setup

`.github/workflows/deploy-mockserver.yml`:

```yaml
name: Deploy MockServer to Fly.io

on:
  push:
    branches: [main]
    paths:
      - 'mockserver/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: superfly/flyctl-actions/setup-flyctl@master

      - name: Deploy to Fly.io
        run: |
          cd mockserver
          flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

**Setup:**
```bash
# Fly token al
flyctl auth token

# GitHub secrets'a ekle
# Repository → Settings → Secrets → Actions
# Name: FLY_API_TOKEN
# Value: (token'ı yapıştır)
```

---

## 💰 Maliyet

**Free Tier:**
- 3 shared-cpu VMs (256MB RAM)
- 160 GB disk
- Outbound data: 100 GB/ay
- **Yeterli sizin için!**

**Usage-based Pricing:**
- shared-cpu-1x (256MB): Ücretsiz
- shared-cpu-2x (512MB): ~$2/ay
- Outbound data: $0.02/GB (100 GB sonrası)

**Tahmini Maliyet (24/7):**
- 1 VM (256MB): **$0/ay** (Free tier)
- 1 VM (512MB): ~$2/ay
- 3 VMs (256MB, global): **$0/ay** (Free tier)

---

## ⚡ Avantajları

```
✅ Global edge network (ultra-low latency)
✅ Free tier çok cömert
✅ Multiple regions kolay
✅ Auto-scaling
✅ Built-in load balancing
✅ Private networking
✅ Zero-downtime deploys
✅ Instant rollback
```

---

## 🔐 Secrets Management

```bash
# Environment variable ekle (secret)
flyctl secrets set MOCKSERVER_API_KEY=your-secret-key

# List secrets
flyctl secrets list

# Remove secret
flyctl secrets unset MOCKSERVER_API_KEY
```

---

## 🔄 Deployment Stratejileri

### Blue-Green Deployment

```bash
# Version 2 deploy et (downtime yok)
flyctl deploy --strategy bluegreen

# Otomatik traffic shift
```

### Canary Deployment

```bash
# Yeni version'a %10 traffic
flyctl deploy --strategy canary
```

### Rolling Deployment (Default)

```bash
# Instance by instance update
flyctl deploy --strategy rolling
```

---

## 🆘 Sorun Giderme

### Health check başarısız

`fly.toml` içinde health check ekle:

```toml
[checks]
  [checks.mockserver_health]
    grace_period = "30s"
    interval = "15s"
    method = "get"
    path = "/mockserver/status"
    protocol = "http"
    timeout = "5s"
    type = "http"
```

### Out of memory

```bash
# RAM artır
flyctl scale vm shared-cpu-2x --memory 512
```

### Slow cold start

```toml
# fly.toml
[http_service]
  auto_stop_machines = false  # Always on
  min_machines_running = 1
```

---

## 🌐 Custom Domain

```bash
# Domain ekle
flyctl certs add mockserver.yourdomain.com

# DNS'e A/AAAA record ekle
# Fly size IP verir, DNS'e eklersiniz

# SSL otomatik (Let's Encrypt)
```

---

## 📚 Kaynaklar

- [Fly.io Docs](https://fly.io/docs/)
- [Fly.io Pricing](https://fly.io/docs/about/pricing/)
- [Fly.io CLI Reference](https://fly.io/docs/flyctl/)

---

## 🎯 Fly.io vs Diğerleri

| Özellik | Fly.io | Railway | Render |
|---------|--------|---------|--------|
| **Global edge** | ✅ | ❌ | ❌ |
| **Free tier** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Latency** | 🚀 En iyi | ⭐⭐⭐ | ⭐⭐⭐ |
| **Setup** | ⏱️ 10 dk | ⚡ 5 dk | ⏱️ 10 dk |
| **Always on** | ✅ | ✅ | ⚠️ Sleep |

**Fly.io en performanslı, Railway en kolay, Render en ucuz.**

---

**Fly.io ile dünya çapında ultra-hızlı MockServer!** 🌍✨
