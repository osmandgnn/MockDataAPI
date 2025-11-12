# Render.com Yeniden Deployment Rehberi

MockServer config dosyası ile Render'a yeniden deploy edin.

## 🔧 Sorun

Render'da MockServer başladı ama initialization config dosyası yüklenmedi. Bu yüzden expectations tanımlı değil.

## ✅ Çözüm

Config dosyasını Docker image içine gömeceğiz.

---

## 📋 Adımlar

### 1️⃣ Dockerfile'ı Güncelle

Render dashboard'da:
1. **Settings** → **Build & Deploy**
2. **Dockerfile Path:** `./Dockerfile.render`
3. **Docker Command:** (boş bırakın)

### 2️⃣ Yeni Dockerfile Kullan

`Dockerfile.render` dosyası zaten hazır:
- Config dosyasını image içine kopyalıyor
- Environment variable olarak set ediyor
- MockServer başlatıyorken config'i yüklüyor

### 3️⃣ Basitleştirilmiş Config Kullan

İki seçenek var:

**Seçenek A: Statik Config (Önerilen - Garantili çalışır)**
```bash
# mockserver-initialization-render.json kullan
# Bu dosya statik değerler döndürür, ama garantili çalışır
```

**Seçenek B: Dinamik Config (JavaScript template)**
```bash
# mockserver-initialization.json kullan
# Dinamik değerler döndürür ama Render'da JavaScript desteği olmayabilir
```

### 4️⃣ GitHub'a Push

```bash
cd /mnt/c/energy-portal

# Yeni dosyaları ekle
git add mockserver/Dockerfile.render
git add mockserver/config/mockserver-initialization-render.json
git commit -m "Add Render-optimized Dockerfile and config"
git push origin main
```

### 5️⃣ Render'da Manual Deploy

Render dashboard'da:
1. **Manual Deploy** → **Deploy latest commit**
2. Veya otomatik deploy aktifse, push sonrası otomatik başlayacak
3. Deploy loglarını izleyin

---

## 🧪 Test

Deploy tamamlandıktan sonra:

### GetStatus Test
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

**Beklenen:** `Server is open for communication`

### Read Test
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

**Beklenen:** 23 parametre ile XML response

---

## 🚨 Alternatif: API ile Upload (Hızlı test için)

Eğer yeniden deploy etmek istemiyorsanız, expectations'ı API ile yükleyebilirsiniz:

```bash
# Tüm expectations'ları temizle
curl -X PUT https://mockdataapi-28lv.onrender.com/mockserver/clear

# Yeni expectations yükle
curl -X PUT https://mockdataapi-28lv.onrender.com/mockserver/expectation \
  -H "Content-Type: application/json" \
  -d @mockserver/config/mockserver-initialization-render.json
```

**NOT:** Bu yöntem container restart olduğunda sıfırlanır. Kalıcı olması için Dockerfile ile deploy edin.

---

## 📊 Dockerfile.render İçeriği

```dockerfile
FROM mockserver/mockserver:5.15.0

WORKDIR /app

# Config dosyasını image'e kopyala
COPY config/mockserver-initialization-render.json /app/mockserver-initialization.json

# Environment variables
ENV MOCKSERVER_LOG_LEVEL=INFO \
    MOCKSERVER_INITIALIZATION_JSON_PATH=/app/mockserver-initialization.json \
    MOCKSERVER_ENABLE_CORS_FOR_API=true \
    MOCKSERVER_ENABLE_CORS_FOR_ALL_RESPONSES=true

EXPOSE 1080

HEALTHCHECK CMD curl -f http://localhost:1080/mockserver/status || exit 1

CMD ["-serverPort", "1080", "-logLevel", "INFO"]
```

---

## ✅ Başarı Kriterleri

Deployment başarılıysa:
- ✅ `/mockserver/status` → HTTP 200
- ✅ GetStatus SOAP → "Server is open for communication"
- ✅ Read SOAP → 23 parametre döner
- ✅ Logs'da "loaded 2 expectations" mesajı görünür

---

## 🔄 Deploy Sonrası

```bash
# Backend veritabanını güncelle
docker exec -i energy-portal-postgres psql -U energy_user -d energy_portal <<EOF
UPDATE plants
SET opc_endpoint_url = 'https://mockdataapi-28lv.onrender.com/nordex/services/nordex_opc'
WHERE opc_endpoint_url IS NOT NULL;
EOF

# Backend'i restart et
docker restart energy-portal-backend

# Logları izle
docker logs -f energy-portal-backend | grep -i opc
```

---

**Render'da yeniden deploy ettiğinizde config dosyası yüklenecek ve sorun çözülecek!** 🚀
