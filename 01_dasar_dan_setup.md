# Modul 1: Dasar & Setup Lingkungan Kerja WSO2 Micro Integrator

---

## 1. Persyaratan Sistem (Prerequisites)

Sebelum memulai pengembangan WSO2 Micro Integrator (MI), pastikan perangkat Anda telah terpasang:

1. **Java Development Kit (JDK)**:
   - WSO2 MI 4.x membutuhkan **OpenJDK 11** atau **OpenJDK 17**.
   - Cek instalasi via terminal:
     ```bash
     java -version
     ```
   - Pastikan environment variable `JAVA_HOME` sudah diset dengan benar.

2. **Visual Studio Code**:
   - Download & install [Visual Studio Code](https://code.visualstudio.com/).

3. **WSO2 Micro Integrator for VS Code Extension**:
   - Buka VS Code Extensions Marketplace (`Ctrl+Shift+X`).
   - Cari dan install: **WSO2 Micro Integrator**.

4. **WSO2 Micro Integrator Runtime (Opsional untuk Local Test Standalone)**:
   - Download installer runtime dari [wso2.com/micro-integrator](https://wso2.com/micro-integrator/).

---

## 2. Struktur Proyek WSO2 (Project Anatomy)

Proyek WSO2 MI menggunakan struktur berbasis **Maven Multi-Module**. Saat Anda membuat proyek baru di VS Code, struktur berikut akan terbentuk:

```text
MyIntegrationProject/
├── pom.xml                               # Root POM file
├── MyIntegrationProjectConfigs/           # Modul Konfigurasi Integrasi
│   ├── pom.xml
│   ├── artifact.xml                      # Daftar artefak terdaftar
│   └── src/
│       └── main/
│           └── synapse-config/           # Sumber kode XML Synapse
│               ├── api/                  # REST API definitions
│               ├── proxy-services/       # SOAP / Transport Proxy Services
│               ├── sequences/            # Reusable sequences
│               ├── endpoints/            # Backend endpoints
│               ├── inbound-endpoints/    # JMS/Kafka/File inbound listeners
│               ├── message-stores/       # Message stores (JMS, RabbitMQ, DB)
│               ├── message-processors/   # Store-and-forward processors
│               ├── local-entries/        # Schema, XSLT, static config
│               └── tasks/                # Scheduled cron jobs
└── MyIntegrationProjectCompositeExporter/ # Modul Packaging (.CAR)
    ├── pom.xml
    └── artifact.xml                      # Metadata bundle aplikasi
```

### Penjelasan Bagian Penting:
- **`Configs Module`**: Tempat Anda menulis logika integrasi (API, Mediator, Sequence, Endpoint).
- **`Composite Exporter Module`**: Bertanggung jawab membungkus seluruh artefak menjadi file berekstensi `.car` (**Carbon Application Archive**).
- **`artifact.xml`**: File manifes yang mencatat nama, tipe, dan versi setiap artefak integrasi.

---

## 3. Hands-on: Membuat Proyek Pertama "Hello World API"

Mari kita buat REST API sederhana yang menerima parameter nama via query parameter atau path parameter, lalu mengembalikan response JSON.

### Langkah 1: Buat Proyek di VS Code
1. Buka VS Code, klik ikon **WSO2 Micro Integrator** di sidebar kiri.
2. Klik **Create Integration Project**.
3. Masukkan nama project: `HelloWorldProject`.
4. Pilih lokasi direktori project.

### Langkah 2: Buat REST API Baru
1. Pada menu artefak, klik kanan pada **API** -> **Create API**.
2. Isi form:
   - **API Name**: `HelloAPI`
   - **Context**: `/hello`
3. Tambahkan Resource:
   - **HTTP Method**: `GET`
   - **URI Template**: `/{name}`

### Langkah 3: Konfigurasi Logika Integrasi (Synapse XML)
Buka file `HelloAPI.xml` di dalam folder `src/main/synapse-config/api/` dan sesuaikan kodenya:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<api xmlns="http://ws.apache.org/ns/synapse" name="HelloAPI" context="/hello">
    <resource methods="GET" uri-template="/{name}">
        <inSequence>
            <!-- 1. Log request yang masuk -->
            <log level="custom">
                <property name="INFO" value="Menerima request Hello API"/>
                <property name="TargetName" expression="get-property('uri.var.name')"/>
            </log>

            <!-- 2. Bentuk Response JSON -->
            <payloadFactory media-type="json">
                <format>
                    {
                        "status": "SUCCESS",
                        "message": "Halo, $1! Selamat datang di WSO2 Micro Integrator.",
                        "server_time": "$2"
                    }
                </format>
                <args>
                    <arg evaluator="xml" expression="get-property('uri.var.name')"/>
                    <arg evaluator="xml" expression="get-property('SYSTEM_DATE', 'yyyy-MM-dd HH:mm:ss')"/>
                </args>
            </payloadFactory>

            <!-- 3. Set HTTP Status Header 200 OK -->
            <property name="HTTP_SC" value="200" scope="axis2"/>

            <!-- 4. Kembalikan Response Langsung ke Client -->
            <respond/>
        </inSequence>

        <faultSequence>
            <payloadFactory media-type="json">
                <format>
                    {
                        "status": "ERROR",
                        "message": "Terjadi kesalahan pada sistem."
                    }
                </format>
                <args/>
            </payloadFactory>
            <property name="HTTP_SC" value="500" scope="axis2"/>
            <respond/>
        </faultSequence>
    </resource>
</api>
```

---

## 4. Menjalankan & Menguji API

### Menjalankan via VS Code Extension:
1. Klik tombol **Run / Debug** pada panel WSO2 MI di VS Code.
2. Extension akan mendownload runtime embedded (jika belum ada) dan mendeploy CAR project secara otomatis.
3. Pantau terminal VS Code hingga muncul log:  
   `[WSO2] Micro Integrator server started successfully` (port default HTTP: `8290`, HTTPS: `8253`).

### Menguji dengan cURL / Postman:

Jalankan perintah cURL berikut di terminal:
```bash
curl -X GET http://localhost:8290/hello/Jovan
```

**Expected Response JSON:**
```json
{
  "status": "SUCCESS",
  "message": "Halo, Jovan! Selamat datang di WSO2 Micro Integrator.",
  "server_time": "2026-09-01 14:35:10"
}
```

---

## 5. Ringkasan & Checklist Modul 1

- [x] Memahami kebutuhan Java JDK & VS Code WSO2 Extension.
- [x] Memahami struktur direktori Maven multi-module WSO2.
- [x] Berhasil membuat REST API pertama (`/hello/{name}`).
- [x] Memahami siklus sederhana: `InSequence` -> `PayloadFactory` -> `Respond`.
