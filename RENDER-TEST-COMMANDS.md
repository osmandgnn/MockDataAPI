# Render.com Deployment Test Commands

MockServer URL: **https://mockdataapi-28lv.onrender.com**

---

## 🚀 Hızlı Test (Otomatik)

```bash
cd /mnt/c/energy-portal/mockserver
./test-render-deployment.sh
```

Bu script tüm testleri otomatik çalıştırır ve raporlar.

---

## 🧪 Manuel Test Komutları

### 1️⃣ Health Check

```bash
curl https://mockdataapi-28lv.onrender.com/mockserver/status
```

**Beklenen Yanıt:**
```json
{"status": "OK"}
```

---

### 2️⃣ SOAP GetStatus() Test

```bash
curl -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/GetStatus" \
  -d '<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <GetStatus xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <LocaleID>en-us</LocaleID>
      <ClientRequestHandle></ClientRequestHandle>
    </GetStatus>
  </soap:Body>
</soap:Envelope>'
```

**Beklenen Yanıt:**
```xml
<StatusInfo>Server is open for communication</StatusInfo>
<ProductVersion>3.1.2-mock</ProductVersion>
<VendorInfo>Nordex Energy GmbH - MockServer</VendorInfo>
```

---

### 3️⃣ SOAP Read() - Tek Parametre (PwrAct - Aktif Güç)

```bash
curl -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/Read" \
  -d '<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Read xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <Options>
        <ReturnErrorText>true</ReturnErrorText>
        <ReturnItemTime>true</ReturnItemTime>
        <ReturnItemName>true</ReturnItemName>
        <LocaleID>en-us</LocaleID>
      </Options>
      <ItemList>
        <MaxAge>10000</MaxAge>
        <Items>
          <Items><ItemName>01WEA82943/analog/PwrAct</ItemName></Items>
        </Items>
      </ItemList>
    </Read>
  </soap:Body>
</soap:Envelope>'
```

**Beklenen Yanıt:**
```xml
<Items>
  <ItemName>01WEA82943/analog/PwrAct</ItemName>
  <Value>1850.5</Value>
  <Quality><QualityField>14</QualityField></Quality>
  <Timestamp>2025-01-12T14:30:00Z</Timestamp>
</Items>
```

---

### 4️⃣ SOAP Read() - Çoklu Parametre (5 parametre)

```bash
curl -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Read xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <Options>
        <ReturnItemTime>true</ReturnItemTime>
        <ReturnItemName>true</ReturnItemName>
        <LocaleID>en-us</LocaleID>
      </Options>
      <ItemList>
        <Items>
          <Items><ItemName>01WEA82943/analog/PwrAct</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/WSpd</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/TurError</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriVolt1</ItemName></Items>
          <Items><ItemName>01WEA82943/counter/COUNT20</ItemName></Items>
        </Items>
      </ItemList>
    </Read>
  </soap:Body>
</soap:Envelope>'
```

**Beklenen Yanıt:** 5 adet `<Items>` elementi

---

### 5️⃣ SOAP Read() - TÜM 23 Parametre

```bash
curl -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Read xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <Options>
        <ReturnItemTime>true</ReturnItemTime>
        <ReturnItemName>true</ReturnItemName>
        <LocaleID>en-us</LocaleID>
      </Options>
      <ItemList>
        <Items>
          <Items><ItemName>01WEA82943/analog/PwrAct</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/WSpd</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/WDir</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/NacDir</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/RotSpd</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnSpd</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/TurError</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriVolt1</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriVolt2</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriVolt3</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriCurL1</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriCurL2</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GriCurL3</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnBrgBS</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnBrgAS</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnTmpL1</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnTmpL2</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnTmpInlet</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/GnTmpOutlet</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/AirPres</ItemName></Items>
          <Items><ItemName>01WEA82943/analog/ExtTmp</ItemName></Items>
          <Items><ItemName>01WEA82943/counter/COUNT20</ItemName></Items>
          <Items><ItemName>01WEA82943/counter/COUNT21</ItemName></Items>
        </Items>
      </ItemList>
    </Read>
  </soap:Body>
</soap:Envelope>'
```

**Beklenen Yanıt:** 23 adet `<Items>` elementi

---

## 🔍 Dinamik Veri Testi

Aynı request'i iki kez yapın, farklı değerler dönmeli:

```bash
# İlk request
curl -s -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
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
</soap:Envelope>' | grep -oP '(?<=<Value>)[^<]+'

# 2 saniye bekle
sleep 2

# İkinci request (farklı değer dönmeli)
curl -s -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
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
</soap:Envelope>' | grep -oP '(?<=<Value>)[^<]+'
```

---

## 📊 MockServer Dashboard

Tarayıcıda açın:
```
https://mockdataapi-28lv.onrender.com/mockserver/dashboard
```

Burada görebilirsiniz:
- Tüm gelen request'ler
- Request/Response detayları
- Matched expectations
- Logs

---

## 🗄️ Backend Veritabanını Güncelleme

### SQL Script ile:

```sql
-- Test ortamı veritabanında
UPDATE plants
SET opc_endpoint_url = 'https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc',
    opc_timeout_ms = 180000,
    opc_locale_id = 'en-us',
    opc_is_active = true,
    updated_at = CURRENT_TIMESTAMP
WHERE opc_endpoint_url IS NOT NULL
  AND is_deleted = false;
```

### Docker ile çalıştırma:

```bash
docker exec -i energy-portal-postgres psql -U energy_user -d energy_portal <<EOF
UPDATE plants
SET opc_endpoint_url = 'https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc'
WHERE opc_endpoint_url IS NOT NULL;
EOF
```

---

## 🔧 Backend application.yml Güncelleme

### Test ortamı için:

```yaml
# application-test.yml
spring:
  profiles: test

opc:
  endpoints:
    base-url: https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc
    timeout: 180000
    locale-id: en-us
```

### Environment Variable ile:

```bash
# .env dosyasına ekle
OPC_MOCK_ENABLED=true
OPC_MOCK_BASE_URL=https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc
```

---

## ✅ Doğrulama Checklist

Backend'i yeniden başlattıktan sonra:

- [ ] Health check başarılı (HTTP 200)
- [ ] GetStatus() "Server is open for communication" döndü
- [ ] Read() tek parametre başarılı
- [ ] Read() çoklu parametre başarılı (23 adet)
- [ ] Her request farklı değerler döndürüyor
- [ ] Quality field = 14 (Good)
- [ ] Timestamp güncel
- [ ] Backend OPC polling logları başarılı
- [ ] Veritabanına veri kaydedildi

---

## 🚨 Sorun Giderme

### 1. Health check başarısız

**Sorun:** `curl https://mockdataapi-28lv.onrender.com/mockserver/status` hata veriyor

**Çözüm:**
```bash
# Render dashboard'da logs kontrol et
# Container starting up olabilir (30-60 saniye bekle)

# Deployment logs:
# https://dashboard.render.com/web/YOUR_SERVICE_ID/logs
```

### 2. SOAP response boş

**Sorun:** SOAP request yanıt vermiyor

**Çözüm:**
```bash
# Initialization config kontrol et
# Render environment variables doğru mu?

# MOCKSERVER_INITIALIZATION_JSON_PATH=/config/mockserver-initialization.json
```

### 3. Backend bağlanamıyor

**Sorun:** Backend "Connection refused" hatası

**Çözüm:**
```bash
# URL'de https:// var mı kontrol et
# Backend loglarında tam hata mesajı:
docker logs energy-portal-backend | grep -i opc | tail -20
```

### 4. Cold start uzun sürüyor

**Sorun:** İlk request 30-60 saniye sürüyor

**Neden:** Render free tier 15 dakika inaktivite sonrası sleep'e geçer

**Çözüm:**
- UptimeRobot ile keep-alive (https://uptimerobot.com)
- 5 dakikada bir ping at
- Veya Render Starter plan ($7/ay) - always on

---

## 🎯 Backend Test Komutu

Backend restart ettikten sonra OPC polling loglarını izleyin:

```bash
# Backend loglarını izle
docker logs -f energy-portal-backend | grep -i opc

# Başarılı polling örneği:
# INFO  OpcDataCollectionService - Starting OPC polling cycle...
# INFO  OpcDataCollectionService - Polling 8 OPC endpoints in parallel
# INFO  OpcClientService - Executing Read() for endpoint: https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc
# INFO  OpcDataCollectionService - OPC Read() completed: 23 data points collected
# INFO  OpcPersistenceService - UPSERT completed: 8 turbines updated
```

---

## 📈 Performans Metrikleri

**Response Times (Render Free Tier):**
- Health check: ~200-300ms
- GetStatus(): ~300-500ms
- Read (1 param): ~400-600ms
- Read (23 params): ~600-1000ms
- Cold start: 30-60 saniye

**Availability:**
- Uptime: 99%+ (sleep after 15 min inactive)
- Geographic location: Frankfurt (Europe)
- SSL/TLS: Yes (automatic)

---

## 🌍 Multi-Environment URLs

Farklı ortamlar için:

| Environment | URL |
|-------------|-----|
| **Local Dev** | http://localhost:1080/nordex/services/nordex_opc |
| **Test (Render)** | https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc |
| **Staging** | https://mockdataapi-staging-xxxx.onrender.com/nordex/services/nordex_opc |
| **Production** | Gerçek Nordex sunucuları |

---

**Render deployment'ınız hazır! Tüm testleri çalıştırın ve backend'i güncelleyin.** 🚀
