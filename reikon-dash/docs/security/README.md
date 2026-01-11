# ISO/SAE 21434 Cybersecurity Documentation

**Reikon Dash Security Analysis and Requirements**

This directory contains cybersecurity artifacts developed in accordance with ISO/SAE 21434:2021 (Road vehicles - Cybersecurity engineering) for the Reikon Dash motorsport telemetry display system.

---

## Document Overview

| Document | ISO/SAE 21434 Clause | Status | Description |
|----------|---------------------|--------|-------------|
| [Threat Analysis](threat_analysis.md) | Clause 9 | ✅ Draft | TARA (Threat Analysis and Risk Assessment) |
| [Security Concept](security_concept.md) | Clause 9 | 🟡 In Progress | Cybersecurity goals and requirements |
| [Security Requirements](security_requirements.md) | Clause 10 | 🟡 In Progress | Product cybersecurity requirements |
| [Security Architecture](security_architecture.md) | Clause 10 | 🔴 Planned | Security mechanisms and controls |
| [Vulnerability Analysis](vulnerability_analysis.md) | Clause 11 | 🔴 Planned | Known vulnerabilities and mitigations |
| [Incident Response](incident_response.md) | Clause 12 | 🔴 Planned | Security event handling procedures |

---

## Executive Summary

### Item Definition
**Item**: Reikon Dash Motorsport Telemetry Display System
**Interfaces**:
- **CAN Bus**: Bidirectional communication with vehicle ECUs
- **USB**: Configuration upload, data download (optional)
- **Network**: WiFi telemetry streaming (future feature)

### Cybersecurity Goals

**CG-01**: Protect the integrity of displayed telemetry data
- **Impact**: CAL 2 (Medium) - Incorrect data could affect race strategy/safety
- **Feasibility**: Moderate (CAN bus access is restricted in racing environments)

**CG-02**: Prevent unauthorized modification of system configuration
- **Impact**: CAL 3 (Major) - Configuration tampering could disable safety features
- **Feasibility**: High (physical access to vehicle required)

**CG-03**: Ensure availability of telemetry display during racing
- **Impact**: CAL 2 (Medium) - Loss of display affects situational awareness
- **Feasibility**: Moderate (DoS attacks require CAN bus access)

### CAL (Cybersecurity Assurance Level) Determination

Using ISO/SAE 21434 risk assessment methodology:

| Attack Scenario | Impact | Feasibility | CAL |
|----------------|--------|-------------|-----|
| CAN frame injection (spoofing) | High | Moderate | CAL 3 |
| CAN bus flooding (DoS) | Medium | Moderate | CAL 2 |
| Configuration file tampering | High | Low | CAL 2 |
| Firmware modification | High | Low | CAL 2 |
| Network eavesdropping (WiFi) | Low | High | CAL 1 |

**Overall System CAL**: **CAL 3** (driven by CAN injection risk)

---

## Threat Landscape

### Attack Surfaces

#### 1. CAN Bus Interface (Primary Attack Surface)
**Threat Level**: High
- **Attack Vector**: Physical access to CAN bus wiring, OBD-II port
- **Attacker Profile**: Malicious competitor, insider threat
- **Threat Scenarios**:
  - **T-01**: CAN frame injection (spoofing ECU messages)
  - **T-02**: CAN bus flooding (denial of service)
  - **T-03**: CAN frame interception (eavesdropping on telemetry)

#### 2. USB Configuration Interface (Secondary Attack Surface)
**Threat Level**: Medium
- **Attack Vector**: Physical access to USB port
- **Attacker Profile**: Insider, supply chain attack
- **Threat Scenarios**:
  - **T-04**: Malicious configuration file upload
  - **T-05**: Buffer overflow via crafted config file
  - **T-06**: Privilege escalation through config parser

#### 3. Network Interface (Future - Not Yet Implemented)
**Threat Level**: Medium (when implemented)
- **Attack Vector**: WiFi network proximity
- **Attacker Profile**: Remote attacker, man-in-the-middle
- **Threat Scenarios**:
  - **T-07**: Unencrypted telemetry interception
  - **T-08**: Unauthorized connection to telemetry stream
  - **T-09**: WiFi credential theft

---

## Security Requirements

### SR-01: CAN Frame Authentication (CAL 3)
**Status**: 🔴 Planned (v1.1.0)

**Requirement**: The system shall verify the authenticity of received CAN frames before processing

**Implementation**:
- HMAC-SHA256 authentication on critical CAN IDs
- Shared secret key provisioned during manufacturing
- Authentication failure triggers fault indication

**Rationale**: Mitigates T-01 (CAN frame injection)

---

### SR-02: CAN Frame Rate Limiting (CAL 2)
**Status**: 🔴 Planned (v1.0.0)

**Requirement**: The system shall detect and mitigate CAN bus flooding attacks

**Implementation**:
- Per-ID rate monitoring (e.g., max 100 frames/sec per ID)
- Anomaly detection: sudden burst of frames
- Rate limit exceeded → discard excess frames, log event

**Rationale**: Mitigates T-02 (CAN bus flooding DoS)

---

### SR-03: Configuration File Validation (CAL 2)
**Status**: 🟡 In Progress

**Requirement**: The system shall validate the integrity and authenticity of configuration files

**Implementation**:
- Digital signature verification (RSA-2048 or Ed25519)
- File format validation (JSON schema)
- Range checks on all configuration parameters

**Rationale**: Mitigates T-04 (malicious configuration), T-05 (buffer overflow)

---

### SR-04: Secure Boot (CAL 3)
**Status**: 🔴 Planned (v1.1.0)

**Requirement**: The system shall verify firmware integrity before execution

**Implementation**:
- Boot ROM verifies bootloader signature (hardware-backed)
- Bootloader verifies application signature
- Chain of trust from hardware root of trust

**Rationale**: Prevents firmware modification attacks

---

### SR-05: Memory Protection (CAL 2)
**Status**: ✅ Implemented

**Requirement**: The system shall protect against memory corruption attacks

**Implementation**:
- Stack canaries (enabled in GCC/Clang)
- ASLR (Address Space Layout Randomization) where available
- DEP/NX (Data Execution Prevention)
- Bounds checking on all array accesses

**Rationale**: Mitigates buffer overflow exploitation

---

### SR-06: Encrypted WiFi Telemetry (CAL 2)
**Status**: 🔴 Planned (v1.2.0)

**Requirement**: Network telemetry shall be encrypted to prevent eavesdropping

**Implementation**:
- TLS 1.3 for all WiFi telemetry streams
- Certificate-based authentication
- Perfect forward secrecy (PFS)

**Rationale**: Mitigates T-07 (eavesdropping), T-08 (unauthorized access)

---

## Security Architecture

### Defense in Depth

Reikon Dash implements multiple layers of security:

```
┌─────────────────────────────────────────┐
│         Layer 4: Monitoring             │  ← Logging, intrusion detection
├─────────────────────────────────────────┤
│     Layer 3: Application Security       │  ← Input validation, safe APIs
├─────────────────────────────────────────┤
│    Layer 2: OS Security                 │  ← ASLR, DEP, sandboxing
├─────────────────────────────────────────┤
│     Layer 1: Hardware Security          │  ← Secure boot, memory protection
└─────────────────────────────────────────┘
```

### Trust Boundaries

```
     ┌──────────────┐
     │ Untrusted    │ ← External CAN bus (attacker-controlled)
     │  CAN Bus     │
     └──────┬───────┘
            │
    ┌───────▼────────┐
    │  CAN Receiver  │ ← Trust boundary: frame validation
    └───────┬────────┘
            │
    ┌───────▼────────┐
    │  SignalBus     │ ← Trusted zone: validated data only
    └───────┬────────┘
            │
    ┌───────▼────────┐
    │   QML UI       │ ← Display layer (read-only)
    └────────────────┘
```

**Principle**: Never trust data from CAN bus; validate at trust boundary

---

## Secure Development Practices

### Secure Coding Standards

All code follows:
- **MISRA C++:2023** - Prevents common vulnerabilities
- **SEI CERT C++** - Security-specific coding rules
- **AUTOSAR C++14** - Modern C++ safety patterns

### Static Analysis

**Tools**:
- **Cppcheck** - Buffer overflows, null pointer dereferences
- **Clang-Tidy** - Security checkers (cert-*, bugprone-*)
- **SonarQube** (planned) - OWASP Top 10 vulnerability detection

**Mandatory**:
- Zero high-severity findings before release
- All findings reviewed and justified

### Dynamic Analysis

**Tools**:
- **AddressSanitizer (ASan)** - Memory safety violations
- **UndefinedBehaviorSanitizer (UBSan)** - Undefined behavior detection
- **ThreadSanitizer (TSan)** - Data races and concurrency bugs

**Testing**:
- All unit tests run with sanitizers enabled
- Integration tests cover security-critical paths

### Penetration Testing (Planned)

**Scope**:
- CAN bus fuzzing (malformed frames)
- Configuration file fuzzing (edge cases, malicious inputs)
- Network protocol fuzzing (when WiFi implemented)

**Timeline**: Q3 2026 (before v1.1.0 release)

---

## Vulnerability Management

### Vulnerability Disclosure Policy

**Reporting**: security@delaneymotorsports.com
**Response SLA**:
- Critical vulnerabilities: 24-hour acknowledgment, 7-day patch
- High vulnerabilities: 48-hour acknowledgment, 30-day patch
- Medium/Low: 1-week acknowledgment, 90-day patch

### Known Vulnerabilities

| ID | Severity | Description | Status | Mitigation |
|----|----------|-------------|--------|------------|
| CVE-2026-XXXXX | Medium | Unvalidated CAN DLC field | Open | Range check in v1.0.0 |
| (None currently) | - | - | - | - |

### Supply Chain Security

**Dependencies**:
- Qt Framework: Monitor security advisories, update promptly
- Linux Kernel: Use LTS releases with backported security patches
- Compiler Toolchain: GCC/Clang security updates

**Policy**: Update dependencies within 30 days of security advisory

---

## Incident Response

### Security Event Classification

| Severity | Description | Response Time | Escalation |
|----------|-------------|---------------|------------|
| **Critical** | Active exploit, data breach | Immediate | CEO, Legal |
| **High** | Vulnerability confirmed, exploit possible | 24 hours | CTO, Safety Manager |
| **Medium** | Potential vulnerability, no exploit | 1 week | Engineering Lead |
| **Low** | Theoretical risk, low impact | 30 days | Security Team |

### Incident Handling Procedure

1. **Detection**: Automated monitoring, user reports, security research
2. **Triage**: Assess severity, determine scope
3. **Containment**: Isolate affected systems, prevent spread
4. **Remediation**: Develop and test patch
5. **Notification**: Inform affected users, publish advisory
6. **Post-Mortem**: Root cause analysis, process improvements

---

## Compliance and Certification

### ISO/SAE 21434 Compliance Roadmap

| Phase | Target Date | Status |
|-------|------------|--------|
| Concept Phase (Clause 5-6) | Q1 2026 | ✅ Complete |
| Product Development (Clause 9-10) | Q2 2026 | 🟡 In Progress |
| Production (Clause 11) | Q3 2026 | 🔴 Not Started |
| Operations & Maintenance (Clause 12-13) | Q4 2026 | 🔴 Not Started |

### Third-Party Security Assessment

**Planned**: Independent penetration testing by certified firm (Q3 2026)
**Scope**: CAL 3 requirements validation
**Deliverable**: Security assessment report, vulnerability findings

---

## Security Testing

### Test Cases

| Test ID | Requirement | Description | Status |
|---------|-------------|-------------|--------|
| SEC-001 | SR-01 | CAN frame with invalid HMAC rejected | 🔴 Planned |
| SEC-002 | SR-02 | CAN flooding triggers rate limiting | 🔴 Planned |
| SEC-003 | SR-03 | Unsigned config file rejected | 🟡 In Progress |
| SEC-004 | SR-04 | Modified firmware fails boot | 🔴 Planned |
| SEC-005 | SR-05 | Buffer overflow attempt detected | ✅ Pass (ASan) |

---

## Privacy Considerations

### Data Collection

Reikon Dash collects:
- **Telemetry Data**: Vehicle speed, RPM, throttle position (logged locally)
- **Diagnostic Logs**: Error messages, system events
- **Usage Metrics**: None (no telemetry sent to cloud)

### Data Protection

- **Storage**: Local only, encrypted at rest (planned)
- **Transmission**: No telemetry sent to external servers
- **Retention**: User-controlled deletion

**GDPR Compliance**: Not applicable (no personal data collected)

---

## References

- ISO/SAE 21434:2021 - Road vehicles - Cybersecurity engineering
- NIST Cybersecurity Framework v1.1
- OWASP Top 10 for Embedded Devices
- CAN Security Best Practices (SAE J2980)

---

## Contact

**Security Officer**: Kevin Delaney
**Company**: Delaney Motorsports, LLC
**Email**: security@delaneymotorsports.com
**PGP Key**: Available on request
**Location**: Sarasota, FL

**Responsible Disclosure**: Please report vulnerabilities privately to security@delaneymotorsports.com before public disclosure.

---

**Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-10 | Kevin Delaney | Initial security analysis draft |

**Classification**: Internal Use Only
**Approval Status**: Draft (Pending Security Assessment)
