# Panduan Belajar WSO2 Micro Integrator (MI)

Selamat datang di repositori materi pembelajaran mandiri **WSO2 Integrator (Micro Integrator)**. Repositori ini dirancang terstruktur mulai dari pemahaman konsep dasar, mediasi protokol, orkestrasi layanan, penanganan keandalan pesan, hingga proses deployment dan monitoring di lingkungan produksi.

---

## 📚 Daftar Modul Pembelajaran (Roadmap)

| Modul | Topik Materi | Dokumen |
| :--- | :--- | :--- |
| **Pengantar** | Pengenalan WSO2 Integrator, ESB, dan Konsep SOAP vs REST | [📖 Pengenalan WSO2](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/pengenalan_wso2_integrator.md) |
| **Modul 1** | **Dasar & Setup Lingkungan Kerja**<br>• Setup JDK & VS Code Extension<br>• Anatomi Struktur Proyek Maven<br>• Hands-on: Membuat REST API Pertama | [📖 Modul 1: Dasar & Setup](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/01_dasar_dan_setup.md) |
| **Modul 2** | **Core Mediators & Manipulasi Konteks**<br>• Scopes: Default, Axis2, Transport<br>• Property, Log, PayloadFactory<br>• Conditional Flow: Filter & Switch<br>• Call vs Send vs Respond | [📖 Modul 2: Core Mediators](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/02_core_mediators.md) |
| **Modul 3** | **Transformasi Data & Manajemen Endpoint**<br>• JSON to XML & XML to JSON<br>• REST to SOAP Mediation<br>• HTTP, Address, Failover, & Load Balance Endpoints<br>• Timeout & Suspend States | [📖 Modul 3: Transformation & Endpoint](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/03_transformation_dan_endpoint.md) |
| **Modul 4** | **Service Orchestration & Penanganan Error**<br>• Sequential Chaining vs Scatter-Gather<br>• Clone, Iterate, & Aggregate Mediators<br>• Global Fault Sequence & HTTP Status Mapping | [📖 Modul 4: Orchestration & Error Handling](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/04_orchestration_dan_error_handling.md) |
| **Modul 5** | **Asynchronous Messaging & Reliability**<br>• Store-and-Forward Pattern<br>• In-Memory, JMS, RabbitMQ, & JDBC Stores<br>• Message Forwarding Processor & Retry Policy<br>• Dead Letter Queue (DLQ) | [📖 Modul 5: Asynchronous & Reliability](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/05_asynchronous_dan_reliability.md) |
| **Modul 6** | **Deployment, Testing & Monitoring**<br>• Packaging Carbon Application (.CAR)<br>• Standalone Deployment & Docker Containerization<br>• Synapse Unit Testing Framework<br>• WSO2 MI Dashboard & Observability | [📖 Modul 6: Deployment & Monitoring](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/06_deployment_dan_monitoring.md) |
| **Ballerina** | **Bahasa Pemrograman Integrasi (Code-First)**<br>• Konsep Network-Aware Programming<br>• Sequence Diagram Dual-Representation<br>• Perbandingan Ballerina vs WSO2 MI<br>• Hands-on HTTP Service & Remote Calls | [📖 Pengenalan Ballerina](file:///c:/Users/eksad/OneDrive/Documents/assa/selfLearning/pengenalan_bahasa_ballerina.md) |

---

## 🛠️ Tools & Prerequisites
- **Java**: OpenJDK 11 atau OpenJDK 17
- **IDE**: Visual Studio Code dengan ekstensi **WSO2 Micro Integrator** & **Ballerina**
- **Runtime**: WSO2 Micro Integrator 4.x / Ballerina Swan Lake
- **Testing Tools**: Postman, cURL, SOAPUI
