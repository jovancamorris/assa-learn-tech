# Panduan & Roadmap Pembelajaran Bahasa Ballerina

---

## 1. Apa itu Ballerina?

**Ballerina** adalah bahasa pemrograman *open-source*, *cloud-native*, dan *statically typed* yang dikembangkan oleh **WSO2**. Bahasa ini dirancang khusus untuk mempermudah **integrasi sistem terdistribusi, pengembangan microservices, dan orkestrasi API modern**.

Berbeda dengan bahasa pemrograman umum (seperti Java, Python, Go) yang memperlakukan jaringan sebagai pustaka pihak ketiga, **Ballerina memperlakukan jaringan (HTTP, gRPC, Kafka), format data (JSON, XML), dan layanan web sebagai fitur bawaan kelas satu (*first-class citizens*)** di dalam sintaksis bahasanya.

```mermaid
graph LR
    Client([Client / Frontend]) -->|HTTP / REST / GraphQL| Bal[Ballerina Microservice]
    Bal -->|http:Client (->)| ExtAPI[External REST API]
    Bal -->|kafka:Producer (->)| MQ[Kafka / RabbitMQ]
    Bal -->|mysql:Client (->)| DB[(SQL Database)]
```

---

## 2. Kurikulum & Modul Pembelajaran Ballerina

Untuk menguasai Ballerina secara terstruktur dari dasar hingga tingkat mahir, silakan ikuti rangkaian modul pembelajaran berikut:

| Modul | Topik Materi | Dokumen |
| :--- | :--- | :--- |
| **Modul 1** | **Dasar & Sintaks Inti Ballerina**<br>• Filosofi & Sequence Diagram as Code<br>• Variabel, Mutabilitas (`final`, `const`, `var`)<br>• Tipe Primitif & Presisi Keuangan (`decimal`)<br>• Tipe Opsional (`?`), Nil (`()`), & String Interpolasi | [📖 Modul 1: Dasar & Sintaks](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/01_dasar_dan_sintaks_ballerina.md) |
| **Modul 2** | **Data Types, Koleksi & Structural Typing**<br>• Tipe Data Bawaan: Native JSON & XML<br>• Koleksi: Arrays, Maps, dan Tables (`table<T> key(id)`)<br>• Closed Record (`{| |}`) vs Open Record (`{ }`)<br>• Konsep Structural Typing vs Nominal Typing | [📖 Modul 2: Data Types & Structural Typing](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/02_data_types_dan_structural_typing.md) |
| **Modul 3** | **Control Flow, Query Expressions & Error Handling**<br>• Percabangan `if-else` & Pattern Matching (`match`)<br>• Iterasi `foreach` & `while`<br>• Query Expressions (`from ... in ... where ... select ...`)<br>• Explicit Error Handling & Operator `check` | [📖 Modul 3: Control Flow & Error Handling](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/03_control_flow_dan_error_handling.md) |
| **Modul 4** | **HTTP Services, Parameter Binding & Integrasi API**<br>• Anatomi HTTP Service (`service /context on listener`)<br>• Parameter Binding: Path, Query, Header, & Payload<br>• Respon Kode Status HTTP Standar (`http:Created`, dll)<br>• HTTP Client & Remote Calls (`->`) | [📖 Modul 4: HTTP Services & Integration](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/04_http_services_dan_api_integration.md) |
| **Modul 5** | **Hands-on Komprehensif: E-Commerce Microservice**<br>• **Proyek Gabungan Seluruh Materi 1 - 4**<br>• Implementasi Kode Lengkap (`hello/main.bal`)<br>• Bedah Detail Setiap Baris Kode (Line-by-Line)<br>• Skenario Pengujian Lengkap & Troubleshooting Windows | [📖 Modul 5: Hands-on Komprehensif](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/05_hands_on_ecommerce_microservice.md) |

---

## 3. Perbandingan Singkat: WSO2 Micro Integrator vs Ballerina

| Aspek | WSO2 Micro Integrator (MI) | Ballerina |
| :--- | :--- | :--- |
| **Pendekatan** | **Config-First** (Synapse XML & Drag-and-Drop Visual). | **Code-First** (Bahasa Pemrograman Modern & Visual). |
| **Bahasa Utama** | XML (Synapse Configuration Language). | Ballerina Language (`.bal`). |
| **Runtime Port** | Port `8290` (HTTP) / `8253` (HTTPS). | Port `9090` (Konfigurasi bebas pada Listener). |
| **Target Kasus** | ESB Enterprise, Mediasi Protokol Legacy (SOAP, ISO8583, JMS, File/VFS). | Microservices Modern, API Gateways, Cloud Integrations, Event-Driven Services. |

---

## 4. Cara Menjalankan Project Cepat

Proyek gabungan lengkap dari seluruh materi ini sudah siap di folder `hello`:

```powershell
cd C:\Users\eksad\OneDrive\Documents\assa\selfLearning\hello
bal run
```

Akses endpoint katalog produk:
```powershell
Invoke-RestMethod -Uri "http://localhost:9090/ecommerce/products" -Method Get | ConvertTo-Json
```
