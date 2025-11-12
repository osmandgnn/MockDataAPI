# 🚀 Hızlı Test - Render MockServer

URL: https://mockdataapi-28lv.onrender.com

## ✅ HAZIR! Config Yüklendi

API ile config başarıyla yüklendi. Şimdi test edebilirsiniz!

---

## 🧪 Test Komutları

### 1. GetStatus (Sağlık Kontrolü)

```bash
curl -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -d '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetStatus xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
      <LocaleID>en-us</LocaleID>
    </GetStatus>
  </soap:Body>
</soap:Envelope>'
```

**Beklenen Yanıt:**
```xml
<StatusInfo>Server is open for communication</StatusInfo>
<VendorInfo>Nordex Energy GmbH - MockServer (Render.com)</VendorInfo>
<ProductVersion>3.1.2-mock</ProductVersion>
```

---

### 2. Read - Tek Parametre

```bash
curl -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -d '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
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

**Beklenen:** PwrAct = 1850.5 kW

---

### 3. Read - Çoklu Parametre (5 adet)

```bash
curl -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -d '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Read xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
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

**Beklenen:** 23 parametre (tüm parametreler statik değerler döner)

---

### 4. Read - TÜM 23 Parametre

```bash
curl -X POST https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc \
  -H "Content-Type: text/xml" \
  -d '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Read xmlns="http://opcfoundation.org/webservices/XMLDA/1.0/">
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

---

## 📊 Beklenen Değerler

MockServer şu değerleri döndürüyor (statik):

| Parametre | Değer | Birim |
|-----------|-------|-------|
| PwrAct | 1850.5 | kW |
| WSpd | 8.5 | m/s |
| WDir | 245 | ° |
| NacDir | 242 | ° |
| RotSpd | 14.2 | RPM |
| GnSpd | 1500 | RPM |
| TurError | FM0 | - |
| GriVolt1-3 | 690-692 | V |
| GriCurL1-3 | 1545-1552 | A |
| GnBrgBS/AS | 44-45 | °C |
| GnTmpL1/L2 | 51-52 | °C |
| GnTmpInlet | 18.5 | °C |
| GnTmpOutlet | 48.2 | °C |
| AirPres | 1013.25 | hPa |
| ExtTmp | 12.5 | °C |
| COUNT20/21 | 12458962 | kWh |

---

## ⚠️ Önemli Not

**Statik değerler:** Şu anki config statik değerler döndürüyor. Her request aynı değerleri verir.

**Dinamik değerler için:** `Dockerfile.render` ile yeniden deploy edin ve JavaScript template kullanın.

---

## 🔄 Backend Entegrasyonu

```sql
-- Database güncelle
UPDATE plants
SET opc_endpoint_url = 'https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc'
WHERE opc_endpoint_url IS NOT NULL;
```

```bash
# Backend restart
docker restart energy-portal-backend

# Logları izle
docker logs -f energy-portal-backend | grep -i opc
```

---

## 🎯 Sonraki Adımlar

1. ✅ **Şu an çalışıyor** - Statik değerlerle test edin
2. 🔄 **Dinamik değerler için** - Dockerfile.render ile yeniden deploy edin (RENDER-REDEPLOY.md)
3. 📊 **Backend testi** - OPC polling çalışacak

---

**MockServer hazır! Test komutlarını çalıştırabilirsiniz.** 🚀
