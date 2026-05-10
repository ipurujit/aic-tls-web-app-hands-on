# Secure Web App

A Spring Boot web application to demonstrate TLS/SSL support for secure HTTPS connections.

## 🚀 Features

- **Spring Boot Framework** - Modern Java web application
- **Thymeleaf Templates** - Server-side HTML rendering
- **Spring Security** - Authentication and authorization
- **TLS/SSL Support** - HTTPS with custom certificate chain
- **MVC Architecture** - Clean separation of concerns

## 📋 Prerequisites

- **Java 17+**
- **Maven 3.6+**
- **OpenSSL** (for certificate generation)

## 🛠️ Quick Start

### Clone and Build
```bash
git clone <repository-url>
cd securewebapp
./mvnw clean package
```

### Install Root Certificate
**Important**: Install `scripts/rootCA.crt` in your system's trust store.

**Windows**: Import to "Trusted Root Certification Authorities"  
**macOS**: Double-click and add to "System" keychain  
**Linux**: `sudo cp scripts/rootCA.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates`

### 5. Run the Application
```bash
./mvnw spring-boot:run
```

Access at: `https://localhost:8080`

## 📁 Project Structure

```
securewebapp/
├── src/main/java/org/finki/puru/advinfo/securewebapp/
│   ├── SecurewebappApplication.java          # Main application class
│   ├── config/
│   │   ├── MvcConfig.java                    # MVC configuration
│   │   └── SecurityConfig.java               # Security configuration
│   ├── controller/
│   │   └── BasicErrorController.java         # Error handling
│   └── repository/                           # Data access layer
├── src/main/resources/
│   ├── application.yaml                      # Application configuration
│   ├── keys/                                # Certificate storage
│   └── templates/                           # Thymeleaf templates
│       ├── hello.html
│       ├── home.html
│       └── login.html
├── scripts/                                 # Certificate generation
│   ├── ........                             # Certificate script
│   ├── *.ext                                # Certificate extensions
│   └── *.crt, *.key, *.p12                  # Generated certificates
├── .env.example                             # Environment variables template
├── pom.xml                                  # Maven configuration
└── README.md                                # This file
```

## 🔐 Security Features

- **HTTPS Only** - All connections secured with TLS 1.2+
- **Custom Certificate Chain** - Root CA → Intermediate CA → Server Certificate
- **Spring Security Integration** - Authentication and authorization
- **Secure Headers** - Protection against common web vulnerabilities

## 🧪 Testing

```bash
./mvnw test
```

## 🔧 Development

### IDE Setup
- Import as Maven project in IntelliJ IDEA or Eclipse
- Ensure Java 17+ SDK is configured

### Certificate Management
- Certificates are generated in `scripts/` directory
- PKCS#12 bundle copied to `src/main/resources/keys/`
- Root CA must be installed in system trust store

## 📄 License

- GPL-3.0 License - See [LICENSE](LICENSE) file for details
---
