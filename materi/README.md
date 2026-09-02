# Panduan Belajar Integrasi Enterprise: WSO2 Micro Integrator & Ballerina

Selamat datang di repositori pembelajaran mandiri integrasi enterprise. Repositori ini terbagi menjadi dua jalur kurikulum utama:
1. **WSO2 Micro Integrator Track (Config-First / Synapse XML)**
2. **Ballerina Swan Lake Track (Code-First / Cloud-Native)**

---

## 🏛️ Track 1: WSO2 Micro Integrator (MI)

| Modul | Topik Materi | Dokumen |
| :--- | :--- | :--- |
| **Pengantar** | Pengenalan WSO2 Integrator, ESB, dan Konsep SOAP vs REST | [📖 Pengenalan WSO2](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/wso2/pengenalan_wso2_integrator.md) |
| **Modul 1** | **Dasar & Setup Lingkungan Kerja**<br>• Setup Antigravity IDE & Extensions<br>• Anatomi Struktur Proyek Integrasi<br>• Hands-on: REST API Hello World (Port 8290) | [📖 Modul 1: Dasar & Setup](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/wso2/01_dasar_dan_setup.md) |
| **Modul 2** | **Core Mediators & Manipulasi Konteks**<br>• Message Context Scopes: Default, Axis2, Transport<br>• Property, Log, PayloadFactory, Filter & Switch<br>• Hands-on: Order Checkout API | [📖 Modul 2: Core Mediators](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/wso2/02_core_mediators.md) |
| **Modul 3** | **Transformasi Data & Manajemen Endpoint**<br>• JSON to XML & XML to JSON<br>• REST to SOAP Mediation<br>• HTTP, Address, Failover, & Load Balance Endpoints | [📖 Modul 3: Transformation & Endpoint](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/wso2/03_transformation_dan_endpoint.md) |
| **Modul 4** | **Service Orchestration & Penanganan Error**<br>• Sequential Chaining vs Scatter-Gather<br>• Clone, Iterate, & Aggregate Mediators<br>• Global Fault Sequence & HTTP Status Mapping | [📖 Modul 4: Orchestration & Error Handling](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/wso2/04_orchestration_dan_error_handling.md) |
| **Modul 5** | **Asynchronous Messaging & Reliability**<br>• Store-and-Forward Pattern<br>• In-Memory, JMS, RabbitMQ, & JDBC Stores<br>• Message Forwarding Processor & Dead Letter Queue | [📖 Modul 5: Asynchronous & Reliability](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/wso2/05_asynchronous_dan_reliability.md) |
| **Modul 6** | **Deployment, Testing & Monitoring**<br>• Packaging Carbon Application (.CAR)<br>• Standalone Deployment & Docker Containerization<br>• WSO2 MI Dashboard & Observability | [📖 Modul 6: Deployment & Monitoring](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/wso2/06_deployment_dan_monitoring.md) |

---

## 🕊️ Track 2: Bahasa Pemrograman Ballerina (Swan Lake)

| Modul | Topik Materi | Dokumen |
| :--- | :--- | :--- |
| **Roadmap** | **Pengenalan & Roadmap Pembelajaran Ballerina** | [📖 Pengenalan & Roadmap](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/pengenalan_bahasa_ballerina.md) |
| **Modul 1** | **Dasar & Sintaks Inti Ballerina**<br>• Filosofi & Sequence Diagram as Code<br>• Variabel, Mutabilitas (`final`, `const`, `var`)<br>• Tipe Primitif & Presisi Keuangan (`decimal`)<br>• Tipe Opsional (`?`), Nil (`()`), & String Interpolasi | [📖 Modul 1: Dasar & Sintaks](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/01_dasar_dan_sintaks_ballerina.md) |
| **Modul 2** | **Data Types, Koleksi & Structural Typing**<br>• Tipe Data Bawaan: Native JSON & XML<br>• Koleksi: Arrays, Maps, dan Tables (`table<T> key(id)`)<br>• Closed Record (`{| |}`) vs Open Record (`{ }`)<br>• Konsep Structural Typing vs Nominal Typing | [📖 Modul 2: Data Types & Structural Typing](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/02_data_types_dan_structural_typing.md) |
| **Modul 3** | **Control Flow, Query Expressions & Error Handling**<br>• Percabangan `if-else` & Pattern Matching (`match`)<br>• Iterasi `foreach` & `while`<br>• Query Expressions (`from ... in ... where ... select ...`)<br>• Explicit Error Handling & Operator `check` | [📖 Modul 3: Control Flow & Error Handling](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/03_control_flow_dan_error_handling.md) |
| **Modul 4** | **HTTP Services, Parameter Binding & Integrasi API**<br>• Anatomi HTTP Service (`service /context on listener`)<br>• Parameter Binding: Path, Query, Header, & Payload<br>• Respon Kode Status HTTP Standar (`http:Created`, dll)<br>• HTTP Client & Remote Calls (`->`) | [📖 Modul 4: HTTP Services & Integration](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/04_http_services_dan_api_integration.md) |
| **Modul 5** | **Hands-on Komprehensif: E-Commerce Microservice**<br>• **Proyek Gabungan Seluruh Materi 1 - 4**<br>• Implementasi Kode Lengkap (`hello/main.bal`)<br>• Bedah Detail Setiap Baris Kode (Line-by-Line)<br>• Skenario Pengujian Lengkap & Troubleshooting Windows | [📖 Modul 5: Hands-on Komprehensif](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/materi/ballerina/05_hands_on_ecommerce_microservice.md) |

---

## 🛠️ Tools & Prerequisites
- **Java**: OpenJDK 11 atau OpenJDK 17
- **Ballerina**: Ballerina Swan Lake 2201.x+
- **IDE**: Antigravity IDE / VS Code dengan ekstensi **WSO2 Micro Integrator** & **Ballerina**
- **Runtime**: WSO2 Micro Integrator 4.x / Ballerina Runtime Engine
- **Testing Tools**: Postman, cURL, PowerShell `Invoke-RestMethod`
