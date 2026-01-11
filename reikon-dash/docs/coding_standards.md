# Coding Standards

**Reikon Dash Automotive Software Quality Guidelines**

This document defines the coding standards for Reikon Dash, ensuring compliance with automotive industry best practices for safety-critical embedded systems.

---

## Table of Contents

1. [Overview](#overview)
2. [MISRA C++:2023 Compliance](#misra-c2023-compliance)
3. [AUTOSAR C++14 Compliance](#autosar-c14-compliance)
4. [SEI CERT C/C++ Secure Coding](#sei-cert-cc-secure-coding)
5. [Qt-Specific Guidelines](#qt-specific-guidelines)
6. [File Organization](#file-organization)
7. [Documentation Requirements](#documentation-requirements)
8. [Static Analysis](#static-analysis)

---

## Overview

### Scope
These standards apply to all C++ source code in the Reikon Dash project, including:
- Platform abstraction layer (`app/platform/`)
- Data model layer (`app/model/`)
- Services layer (`app/services/`)
- Main application entry point (`app/main.cpp`)

QML files follow separate UI coding guidelines (see `docs/qml_guidelines.md`).

### Compliance Levels

| Standard | Target Level | Current Status |
|----------|-------------|----------------|
| **MISRA C++:2023** | Full compliance with deviations | 85% compliant |
| **AUTOSAR C++14** | Rule compliance (no advisory) | 90% compliant |
| **SEI CERT C++** | All rules applicable to automotive | 95% compliant |
| **Qt Best Practices** | All applicable guidelines | 100% compliant |

###Safety Classifications

Code is classified by ISO 26262 ASIL level:

- **ASIL-B**: CAN platform layer, SignalBus (safety-critical telemetry path)
  - Highest coding standards apply
  - 100% MISRA/AUTOSAR compliance required
  - Mandatory static analysis with zero warnings

- **ASIL-QM**: UI layer, logging services (Quality Management only)
  - Standard coding guidelines apply
  - Best-effort MISRA/AUTOSAR compliance
  - Static analysis findings reviewed and justified

---

## MISRA C++:2023 Compliance

MISRA (Motor Industry Software Reliability Association) C++:2023 provides guidelines for the use of C++ in critical systems.

### Mandatory Rules

All **Mandatory** rules must be followed without exception.

**Examples:**
- **Rule 0-1-1**: A project shall not contain unreachable code
- **Rule 0-1-2**: A project shall not contain infeasible paths
- **Rule 0-1-6**: A project shall not contain unused type declarations
- **Rule 5-0-1**: The value of an expression shall be the same under any order of evaluation

### Required Rules

All **Required** rules must be followed unless formally deviated with justification.

**Common Deviations:**
- **Rule 16-2-3**: Unique identifier - Allow Qt macro names (`Q_OBJECT`, `signals`, `slots`)
- **Rule 5-2-2**: Casting - Permit `static_cast` for Qt signal/slot connections
- **Rule 7-5-1**: Function definitions - Allow Qt private slots without external use

### Advisory Rules

**Advisory** rules are recommendations; non-compliance should be reviewed and justified.

### Rule Categories

#### Type Safety
- Use explicit type conversions (no C-style casts)
- Avoid implicit conversions that may lose information
- Use fixed-width integer types (`uint8_t`, `int32_t`) for data structures

```cpp
// ✅ Good - Explicit, safe
uint16_t value = static_cast<uint16_t>(rawValue & 0xFFFF);

// ❌ Bad - C-style cast, implicit truncation
uint16_t value = (uint16_t)rawValue;
```

#### Resource Management
- Use RAII (Resource Acquisition Is Initialization) for all resources
- Prefer smart pointers (`std::unique_ptr`, `std::shared_ptr`) over raw pointers
- Never use `new`/`delete` directly in application code

```cpp
// ✅ Good - RAII with smart pointer
std::unique_ptr<CanBackend> backend = std::make_unique<SocketCanBackend>();

// ❌ Bad - Manual memory management
CanBackend* backend = new SocketCanBackend();
delete backend; // Easy to forget, leak-prone
```

#### Control Flow
- Avoid `goto` statements
- All `switch` statements must have `default` case
- No multiple `return` statements in safety-critical functions
- Limit function complexity (cyclomatic complexity ≤ 10)

```cpp
// ✅ Good - Single return, clear flow
bool CanBackend::sendFrame(const CanFrame& frame)
{
    bool success = false;
    if (validateFrame(frame)) {
        success = transmitToHardware(frame);
    }
    return success;
}

// ❌ Bad - Multiple returns
bool CanBackend::sendFrame(const CanFrame& frame)
{
    if (!validateFrame(frame)) return false;
    if (!transmitToHardware(frame)) return false;
    return true;
}
```

#### Error Handling
- Never ignore return values from functions
- Use exceptions only for truly exceptional conditions
- Prefer error codes for expected failures in safety-critical code

```cpp
// ✅ Good - Check return value
if (!canBackend->initialize("can0")) {
    Logger::instance().error("Failed to initialize CAN interface");
    return false;
}

// ❌ Bad - Ignored return value
canBackend->initialize("can0"); // Did it work? Unknown!
```

---

## AUTOSAR C++14 Compliance

AUTOSAR (Automotive Open System Architecture) C++14 guidelines define modern C++ usage for automotive systems.

### Core Principles

1. **Type Safety**: Strong typing, no type punning
2. **Resource Safety**: RAII, smart pointers, no manual memory management
3. **Const Correctness**: Use `const` wherever possible
4. **Error Handling**: Explicit error propagation
5. **Modern C++**: Prefer C++11/14/17 features over C-style constructs

### Key Rules

#### A7-1-1: Constexpr for Compile-Time Constants

```cpp
// ✅ Good - Compile-time constant
constexpr uint32_t MAX_CAN_ID = 0x1FFFFFFF;
constexpr uint8_t MAX_DLC = 8;

// ❌ Bad - Runtime constant
#define MAX_CAN_ID 0x1FFFFFFF
const uint8_t MAX_DLC = 8; // Not constexpr
```

#### A7-1-4: Auto Type Deduction

```cpp
// ✅ Good - Clear intent, maintainability
auto frame = std::make_unique<CanFrame>();
auto it = signalMap.find("EngineRPM");

// ❌ Bad - Verbose, error-prone
std::unique_ptr<CanFrame> frame = std::make_unique<CanFrame>();
std::unordered_map<QString, QVariant>::iterator it = signalMap.find("EngineRPM");
```

#### A8-4-1: Functions with Unique Parameter Names

```cpp
// ✅ Good - Unique parameter names
void CanBackend::processFrame(const CanFrame& frame, uint64_t timestamp);

// ❌ Bad - Duplicate names in overloads
void CanBackend::processFrame(const CanFrame& frame);
void CanBackend::processFrame(const CanFrame& frame, bool validate); // Confusing
```

#### A12-8-6: Move Semantics for Non-Copyable Objects

```cpp
// ✅ Good - Move semantics for unique_ptr
std::unique_ptr<CanBackend> createBackend() {
    auto backend = std::make_unique<SocketCanBackend>();
    return backend; // Automatic move
}

// ❌ Bad - Copying non-copyable object (won't compile)
std::unique_ptr<CanBackend> backend = otherBackend; // Error!
```

---

## SEI CERT C/C++ Secure Coding

SEI CERT rules focus on security vulnerabilities and undefined behavior.

### Critical Rules for Automotive

#### INT30-C: Integer Overflow

```cpp
// ✅ Good - Checked arithmetic
bool addWithCheck(uint32_t a, uint32_t b, uint32_t& result) {
    if (a > UINT32_MAX - b) {
        return false; // Would overflow
    }
    result = a + b;
    return true;
}

// ❌ Bad - Unchecked overflow
uint32_t total = count * itemSize; // May overflow silently
```

#### ARR30-C: Array Bounds

```cpp
// ✅ Good - Bounds-checked access
if (index < data.size()) {
    value = data[index];
} else {
    Logger::instance().error("Array index out of bounds");
}

// ❌ Bad - Unchecked array access
value = data[index]; // May exceed bounds
```

#### CON50-CPP: Mutex Lock

```cpp
// ✅ Good - RAII lock guard
void SignalBus::setValue(const QString& name, const QVariant& value) {
    QMutexLocker locker(&m_mutex);
    m_signals[name] = value;
    // Automatically unlocks when locker goes out of scope
}

// ❌ Bad - Manual lock/unlock
void SignalBus::setValue(const QString& name, const QVariant& value) {
    m_mutex.lock();
    m_signals[name] = value;
    m_mutex.unlock(); // Forget this = deadlock
}
```

#### MEM51-CPP: Resource Lifetime

```cpp
// ✅ Good - RAII ensures cleanup
{
    std::unique_ptr<CanBackend> backend = createBackend();
    backend->initialize("can0");
    // Automatically deleted when scope exits
}

// ❌ Bad - Manual delete, exception-unsafe
CanBackend* backend = createBackend();
backend->initialize("can0"); // Exception here leaks memory
delete backend;
```

---

## Qt-Specific Guidelines

### Signal/Slot Connections

```cpp
// ✅ Good - New-style connect (compile-time checked)
connect(canBackend, &CanBackend::frameReceived,
        this, &SignalDecoder::onFrameReceived);

// ❌ Bad - Old-style connect (runtime checked only)
connect(canBackend, SIGNAL(frameReceived(CanFrame)),
        this, SLOT(onFrameReceived(CanFrame)));
```

### Q_PROPERTY

```cpp
// ✅ Good - Complete property definition
class Gauge : public QObject {
    Q_OBJECT
    Q_PROPERTY(qreal value READ value WRITE setValue NOTIFY valueChanged)

public:
    qreal value() const { return m_value; }
    void setValue(qreal v) {
        if (m_value != v) {
            m_value = v;
            emit valueChanged();
        }
    }

signals:
    void valueChanged();

private:
    qreal m_value = 0.0;
};
```

### Memory Management with QObject

- Use `QObject` parent-child hierarchy for automatic deletion
- Mark `QObject`-derived classes with `Q_DISABLE_COPY` if not copyable
- Use `deleteLater()` instead of `delete` for event-loop objects

```cpp
class CanBackend : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(CanBackend) // Prevent accidental copying

public:
    explicit CanBackend(QObject* parent = nullptr);
};
```

---

## File Organization

### Header File Structure

```cpp
/**
 * @file    MyClass.h
 * @brief   Brief description of the file purpose.
 * @ingroup appropriate_module
 *
 * @details
 * Detailed description explaining the design, usage patterns,
 * and relationship to other components.
 *
 * @section safety_classification Safety Classification
 * ASIL-B: This component is safety-critical for telemetry integrity.
 *
 * @section dependencies Dependencies
 * - Qt 6.x (Core)
 * - Other headers
 *
 * @section standards_compliance Standards Compliance
 * - MISRA C++:2023: Full compliance
 * - AUTOSAR C++14: Full compliance
 * - SEI CERT C++: Rules INT30-C, ARR30-C applied
 *
 * @author  Kevin Delaney
 * @date    YYYY-MM-DD
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#pragma once

// System includes
#include <cstdint>
#include <memory>

// Qt includes
#include <QObject>

// Project includes
#include "OtherHeader.h"

/**
 * @class MyClass
 * @brief Brief class description.
 *
 * @details
 * Detailed class description with usage examples.
 */
class MyClass : public QObject
{
    Q_OBJECT
    // ... class definition
};
```

### Implementation File Structure

```cpp
/**
 * @file    MyClass.cpp
 * @brief   Implementation of MyClass.
 *
 * @author  Kevin Delaney
 * @date    YYYY-MM-DD
 * @company Delaney Motorsports, LLC
 */

#include "MyClass.h"
#include <QDebug>

// Constants (file scope)
namespace {
    constexpr int DEFAULT_TIMEOUT_MS = 1000;
}

// Implementation
MyClass::MyClass(QObject* parent)
    : QObject(parent)
{
    // Constructor implementation
}

// ... methods
```

---

## Documentation Requirements

All public APIs must be documented with Doxygen comments:

```cpp
/**
 * @brief Initializes the CAN interface.
 *
 * @param interface Platform-specific identifier (e.g., "can0", "vcan0").
 *
 * @return true if initialization succeeded.
 * @return false if initialization failed.
 *
 * @pre The interface name must be valid for the platform.
 * @post If successful, the CAN backend is ready to send/receive frames.
 *
 * @note This method may block for up to 5 seconds during hardware initialization.
 * @warning Calling this on an already-initialized backend may cause undefined behavior.
 *
 * @see sendFrame()
 * @see frameReceived()
 */
virtual bool initialize(const QString& interface) = 0;
```

---

## Static Analysis

### Required Tools

1. **Cppcheck** (MISRA addon):
```bash
cppcheck --addon=misra --enable=all app/
```

2. **Clang-Tidy** (AUTOSAR + CERT checks):
```bash
clang-tidy app/**/*.cpp -checks='cert-*,autosar-*,modernize-*'
```

3. **Clang Static Analyzer**:
```bash
scan-build cmake --build .
```

### Violation Handling

1. **Zero Tolerance**: ASIL-B code must have zero static analysis warnings
2. **Justified Deviations**: Non-ASIL code may have justified deviations
3. **Deviation Process**:
   - Document in `docs/misra_deviations.md`
   - Include file, line number, rule violated
   - Provide technical justification
   - Obtain safety engineer review

**Example Deviation:**

| File | Line | Rule | Justification | Reviewer |
|------|------|------|---------------|----------|
| SignalBus.cpp | 45 | MISRA 16-2-3 | Qt macro `Q_OBJECT` required for signal/slot mechanism. No alternative exists. | K. Delaney |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-10 | Kevin Delaney | Initial release with MISRA/AUTOSAR/CERT guidelines |

---

**Author**: Kevin Delaney
**Company**: Delaney Motorsports, LLC
**Location**: Sarasota, FL
**Last Updated**: January 10, 2026
