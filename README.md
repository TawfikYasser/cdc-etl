# cdc-etl

A Change Data Capture (CDC) pipeline utilizing PostgreSQL, Debezium, Apache Kafka, and Docker to capture and process real-time data changes.

---

## 📖 TABLE OF CONTENTS

- [ABOUT](#about)
- [ARCHITECTURE](#architecture)
- [FEATURES](#features)
- [PREREQUISITES](#prerequisites)
- [INSTALLATION](#installation)
- [USAGE](#usage)
- [PROJECT STRUCTURE](#project-structure)
- [TECHNOLOGIES USED](#technologies-used)
- [CONTRIBUTING](#contributing)
- [LICENSE](#license)
- [CONTACT](#contact)

---

## 📌 ABOUT

This project demonstrates a CDC pipeline that:

1. **Captures** changes from a PostgreSQL database using Debezium.
2. **Streams** the changes through Apache Kafka.
3. **Processes** the data for downstream applications.

---

## 🏗️ ARCHITECTURE

The pipeline follows this flow:

1. **Data Source**:
   - PostgreSQL database with logical replication enabled.

2. **Change Data Capture**:
   - Debezium captures changes from PostgreSQL and publishes them to Kafka topics.

3. **Data Streaming**:
   - Apache Kafka acts as the message broker, facilitating real-time data streaming.

---

## ✨ FEATURES

- Real-time data capture from PostgreSQL.
- Stream processing with Apache Kafka.
- Dockerized setup for easy deployment.

---

## ✅ PREREQUISITES

Before you begin, ensure you have met the following requirements:

- Docker and Docker Compose installed on your machine.
- Python 3.7 or higher installed.

---

## 🚀 INSTALLATION

1. **Clone the repository**:

   ```bash
   git clone https://github.com/TawfikYasser/cdc-etl.git
   cd cdc-etl
   ```

2. **Start the Docker containers**:

   ```bash
   docker-compose up -d
   ```

   This will set up PostgreSQL, Kafka, and other necessary services.

3. **Install Python dependencies**:

   ```bash
   pip install psycopg2-binary faker
   ```

---

## 🛠️ USAGE

1. **Run the data generator**:

   ```bash
   python3 main.py
   ```

   This script will generate synthetic data and insert it into the PostgreSQL database.

2. **Access pgAdmin**:

   - Navigate to `http://localhost:5050` in your browser to access pgAdmin.

3. **Create Debezium Connector**:

   - Use the Debezium UI at `http://localhost:8080` to create a connector for capturing changes from PostgreSQL.

4. **Monitor Kafka Topics**:

   - Access the Kafka Control Center at `http://localhost:9021` to monitor topics and messages.

5. **Update Data**:

   - Execute SQL commands to update data in PostgreSQL and observe the changes propagated through Kafka.

   ```sql
   UPDATE transactions SET amount = amount + 100 WHERE transaction_id = 'your_transaction_id';
   ```

---

## 📁 PROJECT STRUCTURE

```bash
cdc-etl/
├── docker-compose.yml        # Docker Compose configuration
├── main.py                   # Python script to generate and insert data into PostgreSQL
├── postgresql.sql            # SQL script to set up PostgreSQL schema
├── README.md                 # Project documentation
```

---

## 🧰 TECHNOLOGIES USED

- **PostgreSQL**: Relational database for data storage.
- **Debezium**: CDC platform for capturing changes from databases.
- **Apache Kafka**: Distributed event streaming platform.
- **Docker & Docker Compose**: Containerization and orchestration tools.
- **Python**: Programming language for data generation script.

---

## 🤝 CONTRIBUTING

Contributions are welcome! To contribute:

1. **Fork** the repository.
2. **Create** a new branch: `git checkout -b feature/your-feature-name`.
3. **Commit** your changes: `git commit -m 'Add some feature'`.
4. **Push** to the branch: `git push origin feature/your-feature-name`.
5. **Submit** a pull request.

Please ensure your code adheres to the project's coding standards and includes relevant tests.

---

## 📄 LICENSE

This project is licensed under the [MIT License](LICENSE).

---

## 📬 CONTACT

**Tawfik Yasser**  
GitHub: [@TawfikYasser](https://github.com/TawfikYasser)

---
