# MockServer Hızlı Başlangıç Kılavuzu

OPC Nordex mock servisini 5 dakikada ayağa kaldırın! 🚀

## 🎯 Adım 1: MockServer'ı Başlatın (2 dakika)

```bash
# 1. MockServer dizinine gidin
cd /mnt/c/energy-portal/mockserver

# 2. Network oluşturun (ilk kez)
docker network create energy-portal-network

# 3. MockServer'ı başlatın
docker-compose -f docker-compose-mockserver.yml up -d

# 4. Sağlık kontrolü yapın
curl http://localhost:1080/mockserver/status

# Başarılı ise görmelisiniz:
# {"status": "OK"}
```

✅ **Kontrol:** http://localhost:1080/mockserver/dashboard adresini tarayıcıda açın

---

## 🗄️ Adım 2: Veritabanını Güncelleyin (1 dakika)

```bash
# PostgreSQL container'ına bağlanın ve endpoint'leri güncelleyin
docker exec -i energy-portal-postgres psql -U energy_user -d energy_portal \
  < scripts/update-opc-endpoints-to-mockserver.sql

# Sonucu kontrol edin
docker exec -i energy-portal-postgres psql -U energy_user -d energy_portal \
  -c "SELECT id, plant_name, opc_endpoint_url FROM plants WHERE opc_endpoint_url IS NOT NULL;"

# Görmelisiniz:
# opc_endpoint_url = 'http://mockserver:1080/nordex/services/nordex_opc'
```

---

## 🔄 Adım 3: Backend'i Yeniden Başlatın (1 dakika)

```bash
# Backend servisini restart edin
docker restart energy-portal-backend

# Logları takip edin
docker logs -f energy-portal-backend | grep -i opc

# 30 saniye sonra görmelisiniz:
# INFO OpcDataCollectionService - Starting OPC polling cycle...
# INFO OpcDataCollectionService - Polling 8 OPC endpoints in parallel
# INFO OpcDataCollectionService - OPC Read() completed for plant Silivri: 23 data points collected
```

---

## ✅ Adım 4: Test Edin (1 dakika)

```bash
# Test script'ini çalıştırın
cd /mnt/c/energy-portal/mockserver
./scripts/test-mockserver.sh

# Tüm testler geçmeli:
# ✓ MockServer is running
# ✓ GetStatus() request successful
# ✓ Read() single parameter request successful
# ✓ Read() multiple parameters request successful
```

---

## 🎉 Tamamlandı!

Artık MockServer çalışıyor ve backend her 10 dakikada bir dinamik veri çekiyor!

### 📊 İzleme

**MockServer Dashboard:**
http://localhost:1080/mockserver/dashboard

**Backend OPC Logs:**
```bash
docker logs -f energy-portal-backend | grep OPC
```

**Database Verilerini Kontrol:**
```sql
-- En son toplanan verileri göster
SELECT
    t.turbine_model,
    tpl.pwr_act,
    tpl.w_spd,
    tpl.tur_error,
    tpl.data_timestamp,
    tpl.collection_time
FROM turbine_production_latest tpl
JOIN turbines t ON t.id = tpl.turbine_id
ORDER BY tpl.collection_time DESC
LIMIT 10;
```

---

## 🔧 Sorun mu var?

### MockServer çalışmıyor
```bash
docker ps | grep mockserver
docker logs energy-portal-mockserver
```

### Backend bağlanamıyor
```bash
# Network kontrolü
docker network inspect energy-portal-network | grep -A 5 mockserver
docker network inspect energy-portal-network | grep -A 5 backend

# Eğer backend network'te değilse:
docker network connect energy-portal-network energy-portal-backend
```

### Veri güncellenmiyor
```bash
# Manuel test
curl -X POST http://localhost:1080/nordex/services/nordex_opc \
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

## 🎨 Dinamik Veriler

Her polling cycle'da farklı değerler üretilir:

- **Rüzgar hızı:** 0-25 m/s (rastgele)
- **Güç çıkışı:** Rüzgar hızına göre hesaplanır (0-2000 kW)
- **TurError:** %85 FM0 (normal), %15 hata kodları
- **Sıcaklıklar:** Gerçekçi aralıklarda
- **Timestamp:** Her request'te güncellenir

**Her 10 dakikada bir yeni veriler gelecek!**

---

## 📚 Daha Fazla Bilgi

- Detaylı dokümantasyon: [README.md](README.md)
- Test script detayları: [scripts/test-mockserver.sh](scripts/test-mockserver.sh)
- Dinamik veri üretici: [js-templates/turbine-data-generator.js](js-templates/turbine-data-generator.js)

---

**Hazır!** Artık gerçek Nordex sunucularına bağlanmadan test yapabilirsiniz! 🎊
