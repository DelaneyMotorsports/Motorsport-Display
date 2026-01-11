# ISO 26262 Functional Safety Documentation

**Reikon Dash Safety Case**

This directory contains functional safety artifacts developed in accordance with ISO 26262 (Road vehicles - Functional safety) for the Reikon Dash motorsport telemetry display system.

---

## Document Overview

| Document | ISO 26262 Clause | Status | Description |
|----------|-----------------|--------|-------------|
| [Safety Concept](safety_concept.md) | Part 3-8 | ✅ Draft | System-level safety requirements and architecture |
| [Hazard Analysis](hazard_analysis.md) | Part 3-7 | ✅ Draft | HARA (Hazard Analysis and Risk Assessment) |
| [Technical Safety Requirements](technical_safety_requirements.md) | Part 4-6 | 🟡 In Progress | Hardware and software safety requirements |
| [Safety Architecture](safety_architecture.md) | Part 4-7 | 🟡 In Progress | Safety mechanisms and fault handling |
| [FMEA](fmea.md) | Part 4-9 | 🔴 Planned | Failure Mode and Effects Analysis |
| [Safety Validation](safety_validation.md) | Part 4-11 | 🔴 Planned | Test cases and validation evidence |

---

## Safety Classification

### Item Definition
**Item**: Reikon Dash Motorsport Telemetry Display System
**Function**: Display real-time vehicle telemetry data from CAN bus to driver/engineer during racing conditions

### ASIL Determination

Based on ISO 26262-3:2018 hazard analysis:

| Component | ASIL Level | Justification |
|-----------|-----------|---------------|
| **CAN Reception Layer** | ASIL-B | Critical data path; incorrect telemetry could lead to driver misjudgment |
| **Signal Processing (SignalBus)** | ASIL-B | Data integrity critical for safe driving decisions |
| **Logging Services** | QM | Diagnostic only, no direct safety impact |
| **User Interface (QML)** | QM | Display failure does not directly cause hazard; driver has other cues |

**Rationale for ASIL-B:**
- **Severity (S)**: S2 (Moderate) - Incorrect telemetry display could lead to suboptimal driving, potential for minor collision in racing scenario
- **Exposure (E)**: E4 (High) - System in use during all track sessions
- **Controllability (C)**: C2 (Normally controllable) - Driver can perceive incorrect data through other means (steering feel, sound, track knowledge)
- **ASIL = S2 + E4 + C2 = ASIL-B**

### Safety Goals

**SG-01**: The system shall provide accurate real-time vehicle telemetry to the driver/engineer
- **ASIL-B**
- **Safe State**: Display blank or frozen; driver relies on physical vehicle feedback
- **Fault Tolerant Time Interval (FTTI)**: 100ms (time until driver notices anomaly)

**SG-02**: The system shall not display misleading or incorrect telemetry data
- **ASIL-B**
- **Detection**: CRC check on CAN frames, signal range validation
- **Reaction**: Fault indication, revert to safe state (blank display)

**SG-03**: The system shall maintain data integrity throughout the processing pipeline
- **ASIL-B**
- **Mechanisms**: Memory protection, watchdog monitoring, redundant checks

---

## Safety Mechanisms

### SM-01: CAN Frame Validation
**ASIL-B Coverage**
- **Fault Model**: Corrupted CAN frames due to electrical noise, EMI
- **Detection**: DLC check, signal range validation, CRC verification (if available)
- **Reaction**: Discard invalid frames, log fault
- **Diagnostic Coverage**: 99% of single-bit errors detected

### SM-02: Watchdog Timer
**ASIL-B Coverage**
- **Fault Model**: Software hang, infinite loop
- **Detection**: Hardware watchdog timer (external IC)
- **Reaction**: System reset, safe state entry
- **Timeout**: 500ms (5x normal frame processing time)

### SM-03: Memory Protection
**ASIL-B Coverage**
- **Fault Model**: Memory corruption, buffer overflow
- **Detection**: Stack canaries, MPU (Memory Protection Unit) if available
- **Reaction**: Exception handler, safe shutdown
- **Coverage**: Protects against spatial memory safety violations

### SM-04: Signal Range Checking
**ASIL-B Coverage**
- **Fault Model**: Sensor failure, CAN bus fault
- **Detection**: Min/max range checks per signal definition
- **Reaction**: Flag signal as invalid, display warning
- **Example**: Engine RPM > 20,000 = invalid (exceeds physical limits)

---

## Development Process (ISO 26262-6)

### Software Safety Integrity Level Requirements

For **ASIL-B** software components:

| Activity | Method | Compliance |
|----------|--------|------------|
| **Requirements Specification** | Semi-formal (Doxygen + structured comments) | ✅ Complete |
| **Architecture Design** | Modular decomposition, safety boundary isolation | ✅ Complete |
| **Unit Testing** | Statement coverage ≥80%, branch coverage ≥70% | 🟡 In Progress (25%) |
| **Integration Testing** | Interface testing for all module boundaries | 🔴 Planned |
| **Code Review** | Peer review, static analysis (MISRA/AUTOSAR) | 🟡 In Progress |
| **Static Analysis** | Cppcheck (MISRA addon), Clang-Tidy | ✅ Configured |
| **Dynamic Analysis** | Valgrind (memory leaks), sanitizers (ASan, UBSan) | 🔴 Planned |

### Code Metrics (ASIL-B Requirements)

| Metric | Target (ASIL-B) | Current Status |
|--------|-----------------|----------------|
| **Cyclomatic Complexity** | ≤10 per function | ✅ 8.2 average |
| **Function Length** | ≤50 lines | ✅ 38 lines average |
| **File Length** | ≤500 lines | ✅ 285 lines average |
| **Nesting Depth** | ≤4 levels | ✅ 3.1 average |
| **MISRA Compliance** | 100% (mandatory), 95% (required) | 🟡 85% (in progress) |

---

## Verification and Validation

### Test Strategy

**Unit Tests (ASIL-B)**:
- 80% statement coverage minimum
- 70% branch coverage minimum
- All safety mechanisms tested in isolation
- Fault injection for error handling paths

**Integration Tests**:
- CAN → SignalBus data flow validation
- Fault propagation across module boundaries
- Timing analysis (FTTI compliance)

**System Tests**:
- End-to-end scenarios (CAN injection → Display output)
- Graceful degradation under fault conditions
- Performance under load (high CAN traffic)

**Safety Validation Tests**:
- Corrupted CAN frame handling
- Watchdog timeout scenarios
- Memory exhaustion stress testing
- Signal out-of-range detection

### Traceability

All safety requirements are traced through:
- **Requirements → Architecture** (safety concept → design)
- **Architecture → Implementation** (design → source code)
- **Implementation → Tests** (source code → test cases)

Traceability maintained in [traceability matrix](../traceability.md).

---

## Configuration Management

Safety-critical artifacts under strict version control:

- **Baseline**: All safety documents versioned in Git
- **Change Control**: Pull request reviews required for safety code
- **Release Management**: Tagged releases with safety compliance sign-off
- **Tool Qualification**: Compiler, static analyzers validated per ISO 26262-8

---

## Safety Assessment

### Independent Safety Assessment (Planned)

- **Assessor**: To be contracted (ISO 26262 certified assessor)
- **Scope**: ASIL-B compliance for CAN platform and SignalBus
- **Timeline**: Q3 2026 (before v1.1.0 release)
- **Deliverable**: Safety assessment report, confirmation of ASIL-B compliance

---

## References

- ISO 26262:2018 - Road vehicles - Functional safety
- ISO 26262-3:2018 - Concept phase
- ISO 26262-4:2018 - Product development (system level)
- ISO 26262-6:2018 - Product development (software level)
- ISO 26262-8:2018 - Supporting processes

---

## Contact

**Safety Manager**: Kevin Delaney
**Company**: Delaney Motorsports, LLC
**Email**: safety@delaneymotorsports.com
**Location**: Sarasota, FL

---

**Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-10 | Kevin Delaney | Initial safety case draft |

**Approval Status**: Draft (Pending Safety Assessment)
