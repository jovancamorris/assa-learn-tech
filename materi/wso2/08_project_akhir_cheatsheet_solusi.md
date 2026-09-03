# Modul 8: Proyek Akhir Integrasi (Kunci Jawaban, Solusi Step-by-Step & Cheat Sheet)

---

> [!CAUTION]
> **Dokumen ini adalah Cheat Sheet / Panduan Kunci Jawaban.**  
> Gunakan berkas ini hanya sebagai referensi pembanding jika Anda mengalami kendala atau kebuntuan saat mengerjakan soal di [07_project_akhir_soal.md](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/wso2/07_project_akhir_soal.md).  
> **Jangan langsung menyalin kode tanpa memahami fungsi setiap baris mediatornya!**

---

## 1. Urutan Pengerjaan Step-by-Step

Agar artefak tidak mengalami error dependensi saat dijalankan, buatlah komponen integrasi dengan urutan dari komponen terbawah (dependensi) menuju komponen terluar:

1. **Langkah 1**: Buat Endpoints (`BankPaymentEP.xml` & `WarehouseEP.xml`).
2. **Langkah 2**: Buat Sequence Error Handler (`OrderErrorHandlerSequence.xml`).
3. **Langkah 3**: Buat Message Store (`PendingFulfillmentStore.xml`).
4. **Langkah 4**: Buat Message Forwarding Processor (`FulfillmentForwardingProcessor.xml`).
5. **Langkah 5**: Buat Main Inbound REST API (`OrderProcessingAPI.xml`).
6. **Langkah 6**: Buat Synapse Unit Test (`OrderProcessingAPITestSuite.xml`).
7. **Langkah 7**: Compile & Build `.car` dengan Maven, lalu jalankan pengujian via terminal PowerShell.

---

## 2. Solusi Lengkap Kode Setiap Artefak

---

### Langkah 1: Endpoints

#### A. Backend Bank Payment Gateway (`BankPaymentEP.xml`)
Simpan file ini di: `HelloWorldProject/src/main/wso2mi/artifacts/endpoints/BankPaymentEP.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<endpoint xmlns="http://ws.apache.org/ns/synapse" name="BankPaymentEP">
    <!-- HTTP Endpoint dengan proteksi timeout & circuit breaker -->
    <http method="POST" uri-template="http://localhost:8290/mock/bank-va">
        <timeout>
            <duration>5000</duration> <!-- Timeout 5 detik -->
            <responseAction>fault</responseAction>
        </timeout>
        <suspendOnFailure>
            <initialDuration>10000</initialDuration> <!-- Suspend 10 detik jika gagal -->
            <progressionFactor>1.0</progressionFactor>
            <maximumDuration>30000</maximumDuration>
        </suspendOnFailure>
        <markForSuspension>
            <retriesBeforeSuspension>2</retriesBeforeSuspension>
        </markForSuspension>
    </http>
</endpoint>
```

#### B. Backend Gudang Logistik (`WarehouseEP.xml`)
Simpan file ini di: `HelloWorldProject/src/main/wso2mi/artifacts/endpoints/WarehouseEP.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<endpoint xmlns="http://ws.apache.org/ns/synapse" name="WarehouseEP">
    <http method="POST" uri-template="http://localhost:8290/mock/warehouse-fulfillment">
        <timeout>
            <duration>3000</duration>
            <responseAction>fault</responseAction>
        </timeout>
    </http>
</endpoint>
```

---

### Langkah 2: Error Handling Sequence

#### File: `OrderErrorHandlerSequence.xml`
Simpan file ini di: `HelloWorldProject/src/main/wso2mi/artifacts/sequences/OrderErrorHandlerSequence.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<sequence xmlns="http://ws.apache.org/ns/synapse" name="OrderErrorHandlerSequence" trace="disable">
    <!-- 1. Catat error ke server log untuk audit internal -->
    <log level="custom">
        <property name="ERROR_TYPE" value="[ORDER-ERROR-HANDLER] Kegagalan Backend Terdeteksi"/>
        <property name="ERROR_CODE" expression="get-property('ERROR_CODE')"/>
        <property name="ERROR_MESSAGE" expression="get-property('ERROR_MESSAGE')"/>
        <property name="ORDER_ID" expression="get-property('orderId')"/>
    </log>

    <!-- 2. Tentukan HTTP Status Code berdasarkan Error Code WSO2 Synapse -->
    <!-- 101504 = Connection Timeout, 101503 = Connection Refused -->
    <filter xpath="get-property('ERROR_CODE') = '101504' or get-property('ERROR_CODE') = '101503'">
        <then>
            <property name="HTTP_SC" value="504" scope="axis2"/>
            <property name="ERROR_DESC" value="Koneksi ke Payment Gateway Bank mengalami batas waktu (Timeout)"/>
        </then>
        <else>
            <property name="HTTP_SC" value="500" scope="axis2"/>
            <property name="ERROR_DESC" value="Terjadi kegagalan komunikasi dengan sistem pembayaran perbankan"/>
        </else>
    </filter>

    <!-- 3. Format Response JSON Standard yang Ramah Pengguna -->
    <payloadFactory media-type="json">
        <format>
            {
                "status": "FAILED",
                "orderId": "$1",
                "errorCode": "$2",
                "errorMessage": "$3",
                "timestamp": "$4"
            }
        </format>
        <args>
            <arg evaluator="xml" expression="get-property('orderId')"/>
            <arg evaluator="axis2" expression="$axis2:HTTP_SC"/>
            <arg evaluator="xml" expression="get-property('ERROR_DESC')"/>
            <arg evaluator="xml" expression="get-property('SYSTEM_DATE', 'yyyy-MM-dd HH:mm:ss')"/>
        </args>
    </payloadFactory>

    <!-- 4. Kembalikan Respon ke Client & Hentikan Alur -->
    <respond/>
</sequence>
```

---

### Langkah 3: Message Store (Asynchronous Queue)

#### File: `PendingFulfillmentStore.xml`
Simpan file ini di: `HelloWorldProject/src/main/wso2mi/artifacts/message-stores/PendingFulfillmentStore.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<messageStore xmlns="http://ws.apache.org/ns/synapse" name="PendingFulfillmentStore">
    <!-- Menggunakan In-Memory Store bawaan WSO2 (tanpa dependensi broker luar) -->
    <!-- Catatan: Untuk Production, ganti dengan class org.apache.synapse.message.store.RabbitMQStore -->
</messageStore>
```

---

### Langkah 4: Message Forwarding Processor

#### File: `FulfillmentForwardingProcessor.xml`
Simpan file ini di: `HelloWorldProject/src/main/wso2mi/artifacts/message-processors/FulfillmentForwardingProcessor.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<messageProcessor xmlns="http://ws.apache.org/ns/synapse"
                  class="org.apache.synapse.message.processor.impl.forwarder.ScheduledMessageForwardingProcessor"
                  name="FulfillmentForwardingProcessor"
                  targetEndpoint="WarehouseEP"
                  messageStore="PendingFulfillmentStore">
    <parameter name="interval">1000</parameter>             <!-- Polling setiap 1 detik -->
    <parameter name="client.retry.interval">2000</parameter> <!-- Retry jeda 2 detik jika gagal -->
    <parameter name="max.delivery.attempts">3</parameter>    <!-- Maksimal 3 kali percobaan -->
    <parameter name="is.active">true</parameter>
</messageProcessor>
```

---

### Langkah 5: Main Inbound REST API

#### File: `OrderProcessingAPI.xml`
Simpan file ini di: `HelloWorldProject/src/main/wso2mi/artifacts/apis/OrderProcessingAPI.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<api xmlns="http://ws.apache.org/ns/synapse" name="OrderProcessingAPI" context="/ecommerce">
    <resource methods="POST" uri-template="/order">
        <inSequence onError="OrderErrorHandlerSequence">
            
            <!-- ============================================================ -->
            <!-- 1. EKSTRAKSI FIELD PROPERTY & LOGGING (MODUL 1 & 2)           -->
            <!-- ============================================================ -->
            <property name="orderId" expression="json-eval($.orderId)" scope="default"/>
            <property name="customerName" expression="json-eval($.customerName)" scope="default"/>
            <property name="paymentMethod" expression="json-eval($.paymentMethod)" scope="default"/>
            <property name="amount" expression="json-eval($.amount)" scope="default"/>

            <log level="custom">
                <property name="TRACE" value="[ORDER-INBOUND] Menerima request pesanan"/>
                <property name="OrderId" expression="get-property('orderId')"/>
                <property name="Customer" expression="get-property('customerName')"/>
                <property name="Amount" expression="get-property('amount')"/>
                <property name="Method" expression="get-property('paymentMethod')"/>
            </log>

            <!-- ============================================================ -->
            <!-- 2. VALIDASI BISNIS: AMOUNT HARUS > 0 & ORDER_ID TIDAK KOSONG -->
            <!-- ============================================================ -->
            <filter xpath="string-length(get-property('orderId')) = 0 or number(get-property('amount')) &lt;= 0">
                <then>
                    <property name="HTTP_SC" value="400" scope="axis2"/>
                    <payloadFactory media-type="json">
                        <format>
                            {
                                "status": "BAD_REQUEST",
                                "message": "orderId wajib diisi dan nilai amount harus lebih besar dari 0."
                            }
                        </format>
                        <args/>
                    </payloadFactory>
                    <respond/>
                </then>
                <else/>
            </filter>

            <!-- ============================================================ -->
            <!-- 3. SWITCH ROUTING BERDASARKAN PAYMENT METHOD                 -->
            <!-- ============================================================ -->
            <switch source="get-property('paymentMethod')">
                <case regex="VA_BANK">
                    <!-- ======================================================== -->
                    <!-- 4. TRANSFORMASI JSON KE SOAP XML UNTUK BANK (MODUL 3)    -->
                    <!-- ======================================================== -->
                    <payloadFactory media-type="xml">
                        <format>
                            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bank="http://bank.payment.internal/va">
                                <soapenv:Header/>
                                <soapenv:Body>
                                    <bank:PaymentRequest>
                                        <bank:OrderID>$1</bank:OrderID>
                                        <bank:Amount>$2</bank:Amount>
                                        <bank:Customer>$3</bank:Customer>
                                    </bank:PaymentRequest>
                                </soapenv:Body>
                            </soapenv:Envelope>
                        </format>
                        <args>
                            <arg evaluator="xml" expression="get-property('orderId')"/>
                            <arg evaluator="xml" expression="get-property('amount')"/>
                            <arg evaluator="xml" expression="get-property('customerName')"/>
                        </args>
                    </payloadFactory>

                    <!-- Set Header SOAPAction & Content-Type XML -->
                    <header name="Action" value="urn:processPayment" scope="default"/>
                    <property name="messageType" value="text/xml" scope="axis2"/>

                    <!-- 5. CALL BANK ENDPOINT SECARA SINKRON (MODUL 4) -->
                    <!-- Untuk simulasi tanpa backend sungguhan, Call ini dapat diuji via mock -->
                    <call>
                        <endpoint key="BankPaymentEP"/>
                    </call>
                </case>

                <!-- Default jika metode pembayaran selain VA_BANK -->
                <default>
                    <property name="HTTP_SC" value="400" scope="axis2"/>
                    <payloadFactory media-type="json">
                        <format>
                            {
                                "status": "BAD_REQUEST",
                                "message": "Metode pembayaran belum didukung. Harap gunakan VA_BANK."
                            }
                        </format>
                        <args/>
                    </payloadFactory>
                    <respond/>
                </default>
            </switch>

            <!-- ============================================================ -->
            <!-- 6. ASYNCHRONOUS STORE: SIMPAN KE QUEUE GUDANG (MODUL 5)      -->
            <!-- ============================================================ -->
            <!-- Bentuk pesan pesanan yang akan dikirim ke gudang -->
            <payloadFactory media-type="json">
                <format>
                    {
                        "fulfillmentId": "FUL-$1",
                        "orderId": "$2",
                        "customerName": "$3",
                        "orderAmount": $4,
                        "status": "PAID_READY_TO_PACK"
                    }
                </format>
                <args>
                    <arg evaluator="xml" expression="get-property('SYSTEM_DATE', 'yyyyMMddHHmmss')"/>
                    <arg evaluator="xml" expression="get-property('orderId')"/>
                    <arg evaluator="xml" expression="get-property('customerName')"/>
                    <arg evaluator="xml" expression="get-property('amount')"/>
                </args>
            </payloadFactory>

            <!-- Simpan pesan ke antrean store secara asynchronous (Guaranteed Delivery) -->
            <store messageStore="PendingFulfillmentStore"/>

            <!-- ============================================================ -->
            <!-- 7. BERIKAN RESPON INSTAN 200 OK KE CLIENT (NON-BLOCKING)     -->
            <!-- ============================================================ -->
            <property name="HTTP_SC" value="200" scope="axis2"/>
            <payloadFactory media-type="json">
                <format>
                    {
                        "status": "SUCCESS",
                        "orderId": "$1",
                        "message": "Pembayaran berhasil diverifikasi. Pesanan sedang diproses ke gudang logistik.",
                        "processedAt": "$2"
                    }
                </format>
                <args>
                    <arg evaluator="xml" expression="get-property('orderId')"/>
                    <arg evaluator="xml" expression="get-property('SYSTEM_DATE', 'yyyy-MM-dd HH:mm:ss')"/>
                </args>
            </payloadFactory>

            <respond/>
        </inSequence>

        <faultSequence>
            <sequence key="OrderErrorHandlerSequence"/>
        </faultSequence>
    </resource>
</api>
```

---

### Langkah 6: Synapse Unit Test Suite (Modul 6)

#### File: `OrderProcessingAPITestSuite.xml`
Simpan di: `HelloWorldProject/src/test/resources/unit-test-suites/OrderProcessingAPITestSuite.xml`

```xml
<unit-test-suite>
    <artifact>
        <test-artifact>
            <artifact-type>synapse-api</artifact-type>
            <artifact-name>OrderProcessingAPI</artifact-name>
        </test-artifact>
    </artifact>
    <test-cases>
        <!-- Test Case: Validasi Input Amount = 0 Menghasilkan 400 Bad Request -->
        <test-case name="TestCase_Amount_Zero_Should_Fail_400">
            <input>
                <protocol>http</protocol>
                <path>/ecommerce/order</path>
                <request-method>POST</request-method>
                <request-payload>
                    {
                        "orderId": "ORD-INVALID-01",
                        "customerName": "Budi",
                        "paymentMethod": "VA_BANK",
                        "amount": 0
                    }
                </request-payload>
            </input>
            <assertions>
                <assert-equals>
                    <actual>$statusCode</actual>
                    <expected>400</expected>
                    <message>Status code harus bernilai 400 Bad Request</message>
                </assert-equals>
                <assert-equals>
                    <actual>json-eval($.status)</actual>
                    <expected>BAD_REQUEST</expected>
                    <message>Status payload harus bernilai BAD_REQUEST</message>
                </assert-equals>
            </assertions>
        </test-case>
    </test-cases>
</unit-test-suite>
```

---

## 3. Cara Build & Validasi via Terminal PowerShell

### 1. Build Proyek Menjadi Berkas `.car`
Buka terminal PowerShell pada direktori root:
```powershell
cd C:\Users\eksad\OneDrive\Documents\assa\selfLearning\HelloWorldProject
mvn clean install
```
*Pastikan terminal menampilkan:* `BUILD SUCCESS`.

---

### 2. Pengujian Skenario 1: Negative Test (Amount 0)
```powershell
$body = @{
    orderId = "ORD-TEST-001"
    customerName = "Budi Santoso"
    paymentMethod = "VA_BANK"
    amount = 0
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8290/ecommerce/order" -Method Post -Body $body -ContentType "application/json"
```

**Hasil Response yang Diharapkan (HTTP 400):**
```json
{
  "status": "BAD_REQUEST",
  "message": "orderId wajib diisi dan nilai amount harus lebih besar dari 0."
}
```

---

### 3. Pengujian Skenario 2: Metode Pembayaran Tidak Didukung
```powershell
$body = @{
    orderId = "ORD-TEST-002"
    customerName = "Budi Santoso"
    paymentMethod = "CRYPTO_PAY"
    amount = 500000
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8290/ecommerce/order" -Method Post -Body $body -ContentType "application/json"
```

**Hasil Response yang Diharapkan (HTTP 400):**
```json
{
  "status": "BAD_REQUEST",
  "message": "Metode pembayaran belum didukung. Harap gunakan VA_BANK."
}
```

---

### 4. Pengujian Skenario 3: Health Probe (Modul 6)
```powershell
Invoke-RestMethod -Uri "http://localhost:9164/healthz" -Method Get
```

**Hasil Response yang Diharapkan:**
```json
{
  "status": "healthy"
}
```

---

## 4. Tips Arsitektural untuk Integrator Handal

1. **Kenapa `<property name="HTTP_SC" ... scope="axis2"/>`?**  
   Di WSO2 MI, status HTTP balasan dikontrol melalui transport Axis2. Jika Anda tidak menentukan `scope="axis2"`, WSO2 akan secara default mengembalikan HTTP `200 OK` meskipun payload Anda berisi pesan error.

2. **Kenapa Pola Asynchronous `<store>` Lebih Baik daripada Memanggil Gudang Langsung?**  
   Jika sistem gudang mengalami maintenance selama 1 jam, pelanggan tidak akan terganggu. Transaksi pembayaran tetap sukses, dan pesanan akan otomatis dikirim ulang oleh `Message Forwarding Processor` saat sistem gudang kembali aktif tanpa ada data pesanan yang hilang (*Guaranteed Delivery*).
