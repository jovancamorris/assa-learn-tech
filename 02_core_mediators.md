# Modul 2: Core Mediators & Manipulasi Konteks (Context Manipulation)

---

## 1. Konsep Synapse Message Context & Scope

Dalam WSO2 Integrator, setiap pesan yang masuk berjalan dalam sebuah **Message Context (MC)**. Data dan variabel dapat disimpan di berbagai tingkatan (*scopes*):

```mermaid
flowchart TD
    Req[Incoming HTTP Request] --> MC[Synapse Message Context]
    subgraph Scopes [Scoping Architecture]
        DefaultScope["default scope: Variabel Synapse internal (get-property('varName'))"]
        Axis2Scope["axis2 scope: Konfigurasi Transport/Engine (misal: HTTP_SC, messageType)"]
        TransportScope["transport scope: HTTP Headers (misal: Authorization, Content-Type)"]
    end
    MC --> DefaultScope
    MC --> Axis2Scope
    MC --> TransportScope
```

### Penjelasan Scope Variabel:
| Scope | Fungsi & Penggunaan | Contoh Pengambilan |
| :--- | :--- | :--- |
| `default` | Variabel lokal selama pemrosesan pesan di dalam alur Synapse. | `get-property('myVar')` atau `$ctx:myVar` |
| `axis2` | Properti internal engine Axis2 (HTTP Status Code, timeout). | `get-property('axis2', 'HTTP_SC')` atau `$axis2:HTTP_SC` |
| `transport` | Header HTTP dari request masuk atau untuk request keluar. | `get-property('transport', 'Authorization')` atau `$trp:Authorization` |

---

## 2. Mediators Utama yang Wajib Dikuasai

### 1. Property Mediator
Digunakan untuk membuat, mengubah, atau menghapus variabel dalam konteks pesan.

```xml
<!-- Menyimpan nilai statis -->
<property name="serviceName" value="PaymentService" scope="default" type="STRING"/>

<!-- Mengambil nilai dari JSON body request (menggunakan json-eval) -->
<property name="userId" expression="json-eval($.user.id)" scope="default" type="STRING"/>

<!-- Mengambil nilai dari Query Parameter / Path Parameter -->
<property name="queryCategory" expression="get-property('query.param.category')" scope="default" type="STRING"/>

<!-- Menghapus properti -->
<property name="tempToken" action="remove" scope="default"/>
```

---

### 2. Log Mediator
Digunakan untuk mencetak informasi ke dalam terminal/log file (`wso2carbon.log`).

```xml
<!-- Log Level Custom (Hanya mencetak properti yang didefinisikan) -->
<log level="custom">
    <property name="EVENT" value="INCOMING_TRANSACTION"/>
    <property name="USER_ID" expression="get-property('userId')"/>
    <property name="TOTAL_AMOUNT" expression="json-eval($.amount)"/>
</log>

<!-- Log Level Full (Mencetak seluruh payload dan seluruh header HTTP) -->
<log level="full"/>
```

---

### 3. PayloadFactory Mediator
Mediator terpenting untuk memanipulasi, menyusun, dan mengubah format data request/response.

```xml
<payloadFactory media-type="json">
    <format>
        {
            "transaction_id": "$1",
            "account_number": "$2",
            "details": {
                "amount": $3,
                "currency": "IDR",
                "status": "PENDING"
            }
        }
    </format>
    <args>
        <arg evaluator="xml" expression="get-property('txId')"/>
        <arg evaluator="json" expression="$.accountNo"/>
        <arg evaluator="json" expression="$.totalPay"/>
    </args>
</payloadFactory>
```

> [!TIP]
> Perhatikan tanda kutip pada argumen `$1` (string) dan `$3` (number/numeric). Di JSON, jika nilai berupa angka, jangan gunakan tanda petik ganda (`"$3"` akan menjadi string `"50000"`, sedangkan `$3` akan menjadi angka `50000`).

---

### 4. Header Mediator
Digunakan untuk membaca, menambahkan, atau menghapus HTTP Transport Headers.

```xml
<!-- Menambahkan HTTP Header Authorization ke backend -->
<header name="Authorization" expression="fn:concat('Bearer ', get-property('jwtToken'))" scope="transport"/>

<!-- Menambahkan Custom Header -->
<header name="X-Correlation-ID" expression="get-property('MESSAGE_ID')" scope="transport"/>

<!-- Menghapus HTTP Header tertentu sebelum dikirim -->
<header name="Cookie" action="remove" scope="transport"/>
```

---

### 5. Filter Mediator (Percabangan If-Else)
Mengevaluasi kondisi berdasarkan regex atau ekspresi boolean XPath/JSONPath.

```xml
<!-- Contoh Filter dengan Regex pada Properti -->
<filter source="get-property('userId')" regex="^VIP.*">
    <then>
        <!-- Blok IF: User VIP -->
        <log level="custom">
            <property name="ROUTE" value="Direct to High Priority Queue"/>
        </log>
    </then>
    <else>
        <!-- Blok ELSE: User Regular -->
        <log level="custom">
            <property name="ROUTE" value="Direct to Standard Queue"/>
        </log>
    </else>
</filter>
```

---

### 6. Switch Mediator (Percabangan Multi-Kondisi)
Mirip struktur `switch-case` dalam bahasa pemrograman.

```xml
<switch source="json-eval($.paymentMethod)">
    <case regex="BANK_TRANSFER">
        <property name="fee" value="4000" scope="default"/>
    </case>
    <case regex="E_WALLET">
        <property name="fee" value="1500" scope="default"/>
    </case>
    <case regex="CREDIT_CARD">
        <property name="fee" value="2.5%" scope="default"/>
    </case>
    <default>
        <property name="fee" value="0" scope="default"/>
    </default>
</switch>
```

---

### 7. Call vs Send vs Respond vs Drop

| Mediator | Karakteristik & Perbedaan |
| :--- | :--- |
| `<call>` | **Synchronous / Blocking**: Mengirim pesan ke endpoint dan **menunggu response** di tempat sebelum melanjutkan ke mediator berikutnya dalam urutan yang sama. |
| `<send>` | **Asynchronous / Non-Blocking**: Meneruskan pesan ke endpoint dan mengarahkan response yang kembali ke `outSequence`. |
| `<respond>` | Menghentikan alur mediasi saat itu juga dan **langsung mengembalikan pesan saat ini sebagai HTTP Response** ke client. |
| `<drop>` | Menghentikan alur pemrosesan pesan dan **membuang pesan** (tidak mengembalikan apa-apa ke client). |

---

## 3. Hands-on: Menggabungkan Core Mediators

Berikut contoh API `/order/process` yang memvalidasi input, melakukan pengkondisian, dan merespon dengan payload terstruktur:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<api xmlns="http://ws.apache.org/ns/synapse" name="OrderProcessAPI" context="/order">
    <resource methods="POST" uri-template="/process">
        <inSequence>
            <!-- 1. Ekstrak data JSON request -->
            <property name="itemPrice" expression="json-eval($.price)" type="DOUBLE"/>
            <property name="itemQty" expression="json-eval($.quantity)" type="INTEGER"/>
            <property name="voucherCode" expression="json-eval($.voucher)"/>

            <!-- 2. Validasi input -->
            <filter xpath="get-property('itemQty') <= 0 or get-property('itemPrice') <= 0">
                <then>
                    <property name="HTTP_SC" value="400" scope="axis2"/>
                    <payloadFactory media-type="json">
                        <format>{"status": "FAIL", "message": "Quantity dan Price harus lebih besar dari 0"}</format>
                        <args/>
                    </payloadFactory>
                    <respond/>
                </then>
                <else/>
            </filter>

            <!-- 3. Hitung Diskon Berdasarkan Switch Case -->
            <switch source="get-property('voucherCode')">
                <case regex="DISKON50">
                    <property name="discountPercent" value="50"/>
                </case>
                <case regex="DISKON10">
                    <property name="discountPercent" value="10"/>
                </case>
                <default>
                    <property name="discountPercent" value="0"/>
                </default>
            </switch>

            <!-- 4. Format Output Response -->
            <payloadFactory media-type="json">
                <format>
                    {
                        "status": "SUCCESS",
                        "summary": {
                            "unit_price": $1,
                            "quantity": $2,
                            "voucher_applied": "$3",
                            "discount_percent": "$4%"
                        }
                    }
                </format>
                <args>
                    <arg evaluator="xml" expression="get-property('itemPrice')"/>
                    <arg evaluator="xml" expression="get-property('itemQty')"/>
                    <arg evaluator="xml" expression="get-property('voucherCode')"/>
                    <arg evaluator="xml" expression="get-property('discountPercent')"/>
                </args>
            </payloadFactory>

            <respond/>
        </inSequence>
    </resource>
</api>
```

---

## 4. Ringkasan & Checklist Modul 2

- [x] Paham 3 Scope utama: `default`, `axis2`, dan `transport`.
- [x] Menguasai `<property>` dengan nilai statis maupun dinamis (`json-eval` & `get-property`).
- [x] Menguasai perancangan payload JSON dinamis dengan `<payloadFactory>`.
- [x] Menguasai alur percabangan dengan `<filter>` dan `<switch>`.
- [x] Memahami perbedaan `<call>`, `<send>`, `<respond>`, dan `<drop>`.
