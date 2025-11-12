# MockServer - OPC Nordex SOAP Mock Service

Bu dizin, Nordex OPC SOAP servislerini mock etmek için kullanılan MockServer yapılandırmasını içerir.

## 📋 İçindekiler

- [Kurulum](#kurulum)
- [Kullanım](#kullanım)
- [Yapılandırma](#yapılandırma)
- [Test](#test)
- [Özellikler](#özellikler)
- [Sorun Giderme](#sorun-giderme)

---

## 🚀 Kurulum

### Ön Gereksinimler

- Docker ve Docker Compose yüklü olmalı
- `energy-portal-network` Docker network'ü oluşturulmuş olmalı

### Adım 1: Docker Network Oluşturma

```bash
docker network create energy-portal-network
```

### Adım 2: MockServer'ı Başlatma

```bash
cd mockserver
docker-compose -f docker-compose-mockserver.yml up -d
```

### Adım 3: MockServer'ın Çalıştığını Doğrulama

```bash
# Sağlık kontrolü
curl http://localhost:1080/mockserver/status

# Dashboard'u tarayıcıda açın
xdg-open http://localhost:1080/mockserver/dashboard
```

---

## 💻 Kullanım

### Backend Veritabanını Güncelleme

Uygulamanızın MockServer'ı kullanması için veritabanındaki OPC endpoint URL'lerini güncellemeniz gerekiyor:

```bash
# PostgreSQL container'ına bağlanın
docker exec -i energy-portal-postgres psql -U energy_user -d energy_portal < scripts/update-opc-endpoints-to-mockserver.sql
```

Alternatif olarak, manuel güncelleme:

```sql
UPDATE plants
SET opc_endpoint_url = 'http://mockserver:1080/nordex/services/nordex_opc'
WHERE opc_endpoint_url IS NOT NULL;
```

### Backend Servisini Yeniden Başlatma

```bash
docker restart energy-portal-backend
```

### OPC Polling Loglarını İzleme

```bash
# Backend loglarını takip edin
docker logs -f energy-portal-backend | grep -i opc

# Başarılı bir polling cycle örneği:
# INFO  OpcDataCollectionService - Starting OPC polling cycle at 2025-01-12T10:30:00Z
# INFO  OpcDataCollectionService - Polling 8 OPC endpoints in parallel (session: 20250112103000)
# INFO  OpcDataCollectionService - OPC Read() completed for plant Silivri: 23 data points collected
```

---

## ⚙️ Yapılandırma

### Dizin Yapısı

```
mockserver/
├── config/
│   └── mockserver-initialization.json    # Mock expectations
├── js-templates/
│   └── turbine-data-generator.js         # Dinamik veri üretici (opsiyonel)
├── scripts/
│   ├── update-opc-endpoints-to-mockserver.sql
│   └── test-mockserver.sh
├── docker-compose-mockserver.yml
└── README.md
```

### Mock Expectations

MockServer iki tür SOAP isteğini yanıtlar:

#### 1. GetStatus() - Sağlık Kontrolü

**İstek Pattern:**
- Method: POST
- Path: `/nordex/services/nordex_opc`
- Body contains: `GetStatus`

**Yanıt:**
```xml
<GetStatusResponse>
  <StatusInfo>Server is open for communication</StatusInfo>
  <ProductVersion>3.1.2-mock</ProductVersion>
  <ServerState>running</ServerState>
</GetStatusResponse>
```

#### 2. Read() - Dinamik Veri Okuma

**İstek Pattern:**
- Method: POST
- Path: `/nordex/services/nordex_opc`
- Body contains: `<Read`

**Dinamik Yanıt:**
- Her request'te farklı değerler üretilir
- Gerçekçi rüzgar hızı, güç, sıcaklık değerleri
- Quality field her zaman 14 (Good)
- Timestamp anlık olarak üretilir

### Dinamik Veri Üretimi

MockServer JavaScript template kullanarak her parametre için gerçekçi değerler üretir:

| Parametre | Değer Aralığı | Açıklama |
|-----------|---------------|----------|
| `PwrAct` | 0-2000 kW | Rüzgar hızına göre hesaplanır |
| `WSpd` | 0-25 m/s | Rastgele rüzgar hızı |
| `WDir` | 0-360° | Rüzgar yönü |
| `NacDir` | 0-360° | Nacelle yönü |
| `RotSpd` | 0-20 RPM | Rotor hızı |
| `GnSpd` | 1200-1800 RPM | Jeneratör hızı |
| `TurError` | FM0, FM103, FM6, FM105 | Durum kodları |
| `GriVolt1/2/3` | 655-725V | Şebeke voltajı |
| `GriCurL1/2/3` | 0-1600A | Şebeke akımı |
| `GnBrgBS/AS` | 35-60°C | Rulman sıcaklıkları |
| `GnTmpL1/L2` | 45-75°C | Sargı sıcaklıkları |
| `GnTmpInlet` | 10-25°C | Soğutma girişi |
| `GnTmpOutlet` | 35-55°C | Soğutma çıkışı |
| `AirPres` | 1000-1030 hPa | Hava basıncı |
| `ExtTmp` | -10 - 35°C | Dış sıcaklık |
| `COUNT20/21` | 10M-99M | Kümülatif üretim |

### TurError Kodları

Mock servis şu hata kodlarını döndürebilir:

- **FM0** (85%): Normal çalışma
- **FM103** (5%): Düşük rüzgar
- **FM6** (5%): Manuel durdurma
- **FM105** (3%): Yüksek rüzgar
- **FM201** (2%): Şebeke hatası

---

## 🧪 Test

### Otomatik Test Script'i

```bash
cd mockserver
./scripts/test-mockserver.sh
```

Bu script şunları test eder:
1. MockServer sağlık durumu
2. GetStatus() SOAP isteği
3. Read() tek parametre
4. Read() çoklu parametre

### Manuel Test - GetStatus

```bash
curl -X POST http://localhost:1080/nordex/services/nordex_opc \
  -H "Content-Type: text/xml; charset=utf-8" \
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

### Manuel Test - Read (Tek Parametre)

```bash
curl -X POST http://localhost:1080/nordex/services/nordex_opc \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H "SOAPAction: http://opcfoundation.org/webservices/XMLDA/1.0/Read" \
  -d '<?xml version="1.0" encoding="utf-8"?>
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

### MockServer Dashboard

MockServer UI'ye tarayıcıdan erişebilirsiniz:

```
http://localhost:1080/mockserver/dashboard
```

Burada şunları görebilirsiniz:
- Gelen tüm request'ler
- Matching expectations
- Request/response detayları
- Logs

---

## 🎯 Özellikler

### ✅ Mevcut Özellikler

- **SOAP GetStatus()** - Sağlık kontrolü endpoint'i
- **SOAP Read()** - Dinamik veri okuma
- **23 Parametre** - Tüm türbin parametreleri desteklenir
- **Gerçekçi Değerler** - Fiziksel ilişkiler gözetilerek üretilir
- **Dinamik Timestamp** - Her request'te güncel zaman
- **Rastgele Gecikmeler** - 200-700ms arası (gerçekçi network latency)
- **Hata Simülasyonu** - %15 oranında farklı TurError kodları
- **Request Logging** - Tüm istekler loglanır
- **UI Dashboard** - Web arayüzü ile monitoring

### 🔜 Potansiyel İyileştirmeler

- [ ] Türbin bazlı state management (her türbin kendi durumunu hatırlar)
- [ ] Senaryo desteği (rüzgar artışı/azalışı simülasyonu)
- [ ] Scheduled failures (belirli saatte hata oluşturma)
- [ ] Performance testing tools
- [ ] Metrics export (Prometheus/Grafana)

---

## 🐛 Sorun Giderme

### MockServer Başlamıyor

**Hata:** `ERROR: network energy-portal-network not found`

**Çözüm:**
```bash
docker network create energy-portal-network
docker-compose -f docker-compose-mockserver.yml up -d
```

---

### Backend MockServer'a Bağlanamıyor

**Hata:** Backend loglarında `Connection refused` veya `Timeout`

**Kontrol:**
```bash
# MockServer çalışıyor mu?
docker ps | grep mockserver

# Portlar açık mı?
curl http://localhost:1080/mockserver/status

# Network doğru mu?
docker network inspect energy-portal-network | grep mockserver
```

**Çözüm:**
```bash
# Backend ve MockServer aynı network'te olmalı
docker network connect energy-portal-network energy-portal-backend
```

---

### Veri Güncellenmiyor

**Sorun:** Her polling cycle'da aynı değerler geliyor

**Sebep:** JavaScript template çalışmıyor olabilir

**Kontrol:**
```bash
# MockServer loglarını inceleyin
docker logs energy-portal-mockserver

# Manuel test yapın
curl -X POST http://localhost:1080/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -d '<soap:Envelope>...<Read>...</Read>...</soap:Envelope>'
```

---

### Database Endpoint'leri Sıfırlanıyor

**Sorun:** Her database migration'dan sonra endpoint'ler eski haline dönüyor

**Çözüm:**
```bash
# Her migration sonrası update script'ini çalıştırın
docker exec -i energy-portal-postgres psql -U energy_user -d energy_portal \
  < mockserver/scripts/update-opc-endpoints-to-mockserver.sql
```

Veya application.yml'de override ekleyin:
```yaml
# application-dev.yml
opc:
  override-endpoints: true
  default-endpoint: http://mockserver:1080/nordex/services/nordex_opc
```

---

## 📚 Referanslar

- [MockServer Documentation](https://www.mock-server.com/)
- [MockServer JavaScript Templates](https://www.mock-server.com/mock_server/response_templates.html)
- [OPC XML-DA Specification](https://opcfoundation.org/developer-tools/specifications-opc-xml-da)
- [Nordex OPC Integration Guide](../tasks/inputs/nordex-ST-013-soap-client-setup.md)

---

## 📞 Destek

Sorularınız için:
1. MockServer loglarını kontrol edin: `docker logs energy-portal-mockserver`
2. Backend loglarını kontrol edin: `docker logs energy-portal-backend | grep OPC`
3. Dashboard'u inceleyin: http://localhost:1080/mockserver/dashboard
4. Test script'ini çalıştırın: `./scripts/test-mockserver.sh`

---

**Son Güncelleme:** 2025-01-12
**Versiyon:** 1.0.0
**MockServer Image:** mockserver/mockserver:5.15.0
