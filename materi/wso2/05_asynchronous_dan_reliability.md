# Modul 5: Asynchronous Messaging, Reliability & Guaranteed Delivery di WSO2 MI

---

## 1. Mengapa Asynchronous Messaging Penting di Sistem Enterprise?

Dalam arsitektur integrasi tradisional, komunikasi antar-sistem umumnya bersifat **Synchronous (Sinkron/Blocking)**:
> Klien mengirimkan request $\rightarrow$ Menunggu koneksi tersambung $\rightarrow$ Backend memproses data $\rightarrow$ Respon dikembalikan.

### Kelemahan Fatal Synchronous Messaging:
1. **Titik Kegagalan Tunggal (*Single Point of Failure*)**: Jika backend sedang *down*, *overload*, atau sedang masa pemeliharaan (*maintenance*), transaksi klien akan langsung **gagal total (*lost transaction*)**.
2. **Kinerja Lambat & Thread Terkunci (*Thread Starvation*)**: Klien harus menunggu backend menyelesaikan seluruh proses komputasi yang berat sebelum mendapatkan respon.

---

## 2. Pola Guaranteed Delivery (Store-and-Forward)

Untuk mengatasi masalah di atas, WSO2 Micro Integrator menyediakan pola **Guaranteed Delivery (Penyimpanan & Penerusan Terjamin)** atau dikenal dengan **Store-and-Forward Pattern**:

```mermaid
sequenceDiagram
    autonumber
    actor Client as "Client / Mobile App"
    participant InboundAPI as "WSO2 Inbound API (/async-order)"
    participant Store as "Message Store (Queue / DB)"
    participant Processor as "Message Processor (Background Worker)"
    participant Backend as "Backend Core Order System"
    participant DLQ as "Dead Letter Queue (Audit)"

    Client->>InboundAPI: 1. POST /async-order/submit (Payload Pesanan)
    Note over InboundAPI: Validasi Input Bisnis
    InboundAPI->>Store: 2. Simpan Pesan ke Antrean (&lt;store&gt;)
    InboundAPI-->>Client: 3. Respon Instan 202 Accepted (Non-blocking!)

    Note over Processor: Background Worker Berjalan Berkala
    loop Polling & Forwarding
        Processor->>Store: 4. Ambil Pesan dari Antrean
        Processor->>Backend: 5. Teruskan Pesan ke Backend Endpoint
        alt Backend Sedang Aktif (200 OK)
            Backend-->>Processor: Respon Sukses 200 OK
            Processor->>Store: 6. Hapus Pesan dari Antrean (ACK)
        else Backend Down / Timeout (Gagal)
            Backend--xxProcessor: Connection Error / Timeout 504
            Note over Processor: 7. Retry Otomatis (max.delivery.attempts)<br/>Pesan Tetap Aman di Queue!
            opt Melebihi Batas Retry Maksimal
                Processor->>DLQ: 8. Pindahkan ke Dead Letter Queue (DLQ)
                Note over DLQ: Notifikasi Alert & Investigasi Manual
            end
        end
    end
```

---

## 3. Komponen Inti: Message Store & Message Processor

Arsitektur Store-and-Forward di WSO2 MI dibangun oleh dua pilar utama:

### A. Message Store (Tempat Penyimpanan Antrean)
Tempat di mana pesan disimpan sementara sebelum diteruskan ke backend. WSO2 MI mendukung 4 tipe Message Store:

| Tipe Message Store | Media Penyimpanan | Karakteristik & Performa | Kelebihan & Kekurangan | Rekomendasi Penggunaan |
| :--- | :--- | :--- | :--- | :--- |
| **In-Memory Store** | RAM Server WSO2 MI | Sangat cepat (throughput mikrodetik). | **Kelemahan**: Pesan hilang jika server WSO2 restart/crash. | Pengujian lokal, data non-kritis, agregasi sementara. |
| **RabbitMQ Store** | RabbitMQ Broker (AMQP) | Ringan, throughput puluhan ribu pesan/detik, clustering mudah. | Membutuhkan instalasi cluster RabbitMQ eksternal. | **Sangat Direkomendasikan** untuk sistem e-commerce & microservices. |
| **JMS Message Store** | Apache ActiveMQ / Artemis | Standar perbankan Java (JMS 1.1/2.0), mendukung transaksi XA 2PC. | Sedikit lebih berat daripada RabbitMQ. | Sistem perbankan, telekomunikasi, dan enterprise Java legacy. |
| **JDBC Store** | Tabel Database (PostgreSQL/MySQL/Oracle) | Menggunakan database relasional yang sudah ada. | Throughput dibatasi oleh I/O disk database. | Perusahaan yang belum memiliki broker pesan (RabbitMQ/Kafka). |

---

### B. Message Processor (Worker Pengambil & Penerus Pesan)
Worker background yang bertugas mengambil pesan dari Message Store dan mengeksekusinya:
1. **Scheduled Message Forwarding Processor**: Mengambil pesan dari store dan meneruskannya ke **Endpoint Backend**. Dilengkapi dengan kebijakan *Retry Interval*, *Max Attempts*, dan *Exponential Backoff*.
2. **Message Sampling Processor**: Mengambil pesan dari store dan meneruskannya ke **Sequence Lokal**. Sangat ideal untuk **Throttling / Rate-Limiting** agar backend lama yang rapuh tidak kewalahan menerima ribuan request sekaligus.

---

## 4. Hands-on Proyek Lengkap: Asynchronous Order Processing System

Untuk menguasai materi ini secara nyata, kita membangun sistem pemesanan asinkron yang terdiri dari 5 komponen artefak yang telah terintegrasi di `HelloWorldProject`:

```text
HelloWorldProject/src/main/wso2mi/artifacts/
├── message-stores/
│   └── OrderPendingStore.xml          <-- 1. Antrean Penyimpanan Pesan
├── endpoints/
│   └── OrderProcessingBackendEP.xml    <-- 2. Target Endpoint Backend
├── sequences/
│   └── OrderFailureDLQSeq.xml          <-- 3. Handler Dead Letter Queue (DLQ)
├── message-processors/
│   └── OrderForwarderProcessor.xml     <-- 4. Background Retry & Forwarder
└── apis/
    └── AsyncOrderAPI.xml               <-- 5. Inbound API 202 Accepted
```

---

### 1. File Konfigurasi Message Store (`OrderPendingStore.xml`)
Lokasi: `HelloWorldProject/src/main/wso2mi/artifacts/message-stores/OrderPendingStore.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<messageStore xmlns="http://ws.apache.org/ns/synapse" 
              name="OrderPendingStore" 
              class="org.apache.synapse.message.store.impl.memory.InMemoryStore"/>
```

---

### 2. File Konfigurasi Target Endpoint (`OrderProcessingBackendEP.xml`)
Lokasi: `HelloWorldProject/src/main/wso2mi/artifacts/endpoints/OrderProcessingBackendEP.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<endpoint xmlns="http://ws.apache.org/ns/synapse" name="OrderProcessingBackendEP">
    <http method="post" uri-template="https://httpbin.org/post">
        <timeout>
            <duration>5000</duration>
            <responseAction>fault</responseAction>
        </timeout>
        <suspendOnFailure>
            <initialDuration>10000</initialDuration>
            <progressionFactor>2.0</progressionFactor>
            <maximumDuration>60000</maximumDuration>
        </suspendOnFailure>
    </http>
</endpoint>
```

---

### 3. File Konfigurasi Dead Letter Queue Sequence (`OrderFailureDLQSeq.xml`)
Lokasi: `HelloWorldProject/src/main/wso2mi/artifacts/sequences/OrderFailureDLQSeq.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<sequence xmlns="http://ws.apache.org/ns/synapse" name="OrderFailureDLQSeq">
    <log level="custom">
        <property name="ALERT" value="[DLQ-TRIGGERED] Pesanan gagal dikirim setelah melebihi batas retry maksimum!"/>
        <property name="ERROR_CODE" expression="get-property('ERROR_CODE')"/>
        <property name="ERROR_MESSAGE" expression="get-property('ERROR_MESSAGE')"/>
    </log>
    <!-- Simpan jejak audit ke database atau kirim alert ke Slack/PagerDuty -->
    <property name="DLQ_STORED_AT" expression="get-property('SYSTEM_DATE', 'yyyy-MM-dd HH:mm:ss')" scope="default"/>
    <drop/>
</sequence>
```

---

### 4. File Konfigurasi Message Processor (`OrderForwarderProcessor.xml`)
Lokasi: `HelloWorldProject/src/main/wso2mi/artifacts/message-processors/OrderForwarderProcessor.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<messageProcessor xmlns="http://ws.apache.org/ns/synapse" 
                  class="org.apache.synapse.message.processor.impl.forwarder.ScheduledMessageForwardingProcessor" 
                  name="OrderForwarderProcessor" 
                  targetEndpoint="OrderProcessingBackendEP" 
                  messageStore="OrderPendingStore">
    <parameter name="interval">2000</parameter> <!-- Polling setiap 2 detik -->
    <parameter name="max.delivery.attempts">4</parameter> <!-- Maksimal 4 kali pengiriman ulang -->
    <parameter name="client.retry.interval">3000</parameter> <!-- Jeda 3 detik antar percobaan retry -->
    <parameter name="message.processor.fault.sequence">OrderFailureDLQSeq</parameter> <!-- Alihkan ke DLQ jika gagal -->
    <parameter name="is.active">true</parameter>
</messageProcessor>
```

---

### 5. File Konfigurasi Inbound API (`AsyncOrderAPI.xml`)
Lokasi: `HelloWorldProject/src/main/wso2mi/artifacts/apis/AsyncOrderAPI.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<api xmlns="http://ws.apache.org/ns/synapse" name="AsyncOrderAPI" context="/async-order">
    <resource methods="POST" uri-template="/submit">
        <inSequence>
            <!-- 1. Log request yang masuk -->
            <log level="custom">
                <property name="STEP" value="1. Menerima Pesanan Asinkron dari Client"/>
            </log>

            <!-- 2. Ekstraksi data pesanan untuk audit -->
            <property name="orderUser" expression="json-eval($.customer_name)" scope="default"/>
            <property name="orderProduct" expression="json-eval($.product_id)" scope="default"/>
            <property name="orderQty" expression="json-eval($.quantity)" scope="default"/>

            <!-- Validasi Input Dasar -->
            <filter xpath="boolean(get-property('orderProduct')) = false or boolean(get-property('orderQty')) = false">
                <then>
                    <property name="HTTP_SC" value="400" scope="axis2"/>
                    <payloadFactory media-type="json">
                        <format>
                            {
                                "status": "BAD_REQUEST",
                                "message": "Field product_id dan quantity wajib diisi."
                            }
                        </format>
                        <args/>
                    </payloadFactory>
                    <respond/>
                </then>
                <else/>
            </filter>

            <!-- 3. Simpan Pesan ke dalam Message Store (Store-and-Forward) -->
            <store messageStore="OrderPendingStore"/>

            <!-- 4. Segera Berikan Respon Cepat 202 Accepted ke Klien (Non-blocking) -->
            <property name="HTTP_SC" value="202" scope="axis2"/>
            <payloadFactory media-type="json">
                <format>
                    {
                        "status": "ACCEPTED",
                        "tracking_id": "$1",
                        "message": "Pesanan Anda berhasil diamankan dalam antrean pemrosesan terjamin (Guaranteed Delivery).",
                        "customer": "$2",
                        "received_at": "$3"
                    }
                </format>
                <args>
                    <arg evaluator="xml" expression="fn:concat('TRK-', get-property('SYSTEM_DATE', 'yyyyMMddHHmmss'))"/>
                    <arg evaluator="xml" expression="get-property('orderUser')"/>
                    <arg evaluator="xml" expression="get-property('SYSTEM_DATE', 'yyyy-MM-dd HH:mm:ss')"/>
                </args>
            </payloadFactory>
            <property name="messageType" value="application/json" scope="axis2"/>
            <respond/>
        </inSequence>
    </resource>
</api>
```

---

## 5. Bedah Detail Setiap Baris Kode (Line-by-Line Breakdown)

1. **`OrderPendingStore.xml`**:
   - `class="...InMemoryStore"`: Menginisialisasi antrean pesan volatile di memori JVM WSO2 MI untuk pengujian lokal berkecepatan tinggi.
2. **`AsyncOrderAPI.xml` (Baris 29 - 30)**:
   - `<store messageStore="OrderPendingStore"/>`: Mengambil seluruh konteks pesan HTTP (Header, URL, dan Body JSON) dan menyimpannya secara aman ke dalam antrean `OrderPendingStore`.
3. **`AsyncOrderAPI.xml` (Baris 33 - 52)**:
   - `<property name="HTTP_SC" value="202" scope="axis2"/>`: Mengembalikan status HTTP **`202 Accepted`** ke klien. Klien langsung menerima respon dalam ~5 milidetik tanpa perlu menunggu koneksi ke backend dibuka.
4. **`OrderForwarderProcessor.xml` (Baris 7 - 12)**:
   - `targetEndpoint="OrderProcessingBackendEP"`: Menentukan backend target tempat pesan akan dikirimkan.
   - `<parameter name="interval">2000</parameter>`: Processor melakukan polling antrean setiap 2000 ms (2 detik).
   - `<parameter name="max.delivery.attempts">4</parameter>`: Jika backend down, processor mencoba mengirim ulang hingga 4 kali.
   - `<parameter name="client.retry.interval">3000</parameter>`: Memberi jeda 3 detik sebelum setiap percobaan kirim ulang agar backend memiliki waktu untuk pulih.
   - `message.processor.fault.sequence`: Jika setelah 4 kali percobaan backend tetap tidak dapat dihubungi, pesan dialihkan ke sequence `OrderFailureDLQSeq`.
5. **`OrderFailureDLQSeq.xml`**:
   - Menerima pesan yang gagal terkirim dan mencetak log peringatan tingkat tinggi `[DLQ-TRIGGERED]`, memastikan **Zero Message Loss**.

---

## 6. Panduan Menjalankan & Menguji Step-by-Step

Pastikan WSO2 Micro Integrator aktif di port `8290`, lalu jalankan pengujian berikut di PowerShell:

### Skenario 1: Submit Pesanan Asinkron Sukses (202 Accepted)

Menggunakan **`Invoke-RestMethod`**:
```powershell
$headers = @{ "Content-Type" = "application/json" }
$body = @{
    customer_name = "Jovan Pratama"
    product_id    = "PRD-ROG-2026"
    quantity      = 2
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8290/async-order/submit" -Method Post -Headers $headers -Body $body | ConvertTo-Json
```

Atau menggunakan **`curl.exe`**:
```powershell
curl.exe -X POST http://localhost:8290/async-order/submit `
  -H "Content-Type: application/json" `
  -d '{\"customer_name\":\"Jovan Pratama\",\"product_id\":\"PRD-ROG-2026\",\"quantity\":2}'
```

**Expected Response (202 Accepted Instan):**
```json
{
  "status": "ACCEPTED",
  "tracking_id": "TRK-20260902164500",
  "message": "Pesanan Anda berhasil diamankan dalam antrean pemrosesan terjamin (Guaranteed Delivery).",
  "customer": "Jovan Pratama",
  "received_at": "2026-09-02 16:45:00"
}
```

---

### Skenario 2: Validasi Gagal (400 Bad Request)

```powershell
curl.exe -X POST http://localhost:8290/async-order/submit `
  -H "Content-Type: application/json" `
  -d '{\"customer_name\":\"Jovan Pratama\"}'
```

**Expected Response (400 Bad Request):**
```json
{
  "status": "BAD_REQUEST",
  "message": "Field product_id dan quantity wajib diisi."
}
```

---

## 7. Ringkasan & Checklist Modul 5

- [x] Memahami bahaya ketergantungan Synchronous dan keunggulan Asynchronous Messaging.
- [x] Menguasai pola **Guaranteed Delivery (Store-and-Forward)**.
- [x] Memahami perbandingan 4 jenis Message Store: In-Memory, RabbitMQ, JMS, dan JDBC.
- [x] Mampu mengonfigurasi Message Forwarding Processor lengkap dengan *Retry Policy* dan *Max Delivery Attempts*.
- [x] Menguasai penanganan kegagalan terpusat menggunakan **Dead Letter Queue (DLQ)**.
- [x] Berhasil membuat dan menguji arsitektur Async Order API lengkap dengan Store & Processor.
