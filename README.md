# APB Based UART Controller with FIFO Architecture

## Overview

This project presents the RTL design and functional verification of an APB-based UART Controller integrated with FIFO architecture using Verilog HDL.

The design enables reliable asynchronous serial communication between a processor and external devices through the AMBA APB protocol. FIFO buffering is incorporated on both transmitter and receiver paths to improve throughput and prevent data loss during continuous data transfer.

The complete design was developed as a major academic project and verified using simulation in ModelSim/Icarus Verilog and GTKWave.

---

## Project Objectives

- Design an APB-compliant UART peripheral.
- Implement UART Transmitter and Receiver modules.
- Generate accurate baud-rate timing using a Baud Generator.
- Integrate FIFO buffers to support continuous data transfer.
- Verify complete system functionality through simulation.
- Develop a modular architecture suitable for FPGA and SoC integration.

---

## Features

✔ APB Slave Interface

✔ UART Transmitter (TX)

✔ UART Receiver (RX)

✔ Baud Rate Generator

✔ TX FIFO Buffer

✔ RX FIFO Buffer

✔ FSM-Based UART Control

✔ RTL Functional Verification

✔ Modular and Reusable Design

---

# System Architecture

The overall architecture consists of:

- APB Slave Interface
- Baud Generator
- UART Transmitter
- UART Receiver
- TX FIFO
- RX FIFO

The APB slave acts as an interface between the processor and UART subsystem.

TX FIFO temporarily stores outgoing data before transmission.

RX FIFO stores received bytes before they are read by the processor.

The baud generator produces baud clock ticks required for UART communication.

## Block Diagram

![Block Diagram](docs/block_diagram.png)

---

# Data Flow

## Transmit Path

1. CPU writes data through APB.
2. APB slave decodes the transaction.
3. Data is stored inside TX FIFO.
4. UART TX reads data from FIFO.
5. UART TX serializes data.
6. Data is transmitted through TXD.

## Receive Path

1. UART RX receives serial data through RXD.
2. UART RX reconstructs parallel data.
3. Received byte is stored inside RX FIFO.
4. CPU reads received data using APB transactions.

## TX/RX Flowchart

![TX RX Flowchart](docs/tx_rx_flowchart.png)

---

# Module Description

## 1. APB Slave

The APB slave provides communication between the processor and UART peripheral.

### Responsibilities

- Address decoding
- Read operations
- Write operations
- Control signal generation
- FIFO access control

### Important APB Signals

| Signal | Description |
|----------|-------------|
| PADDR | Address Bus |
| PWDATA | Write Data |
| PRDATA | Read Data |
| PWRITE | Read/Write Select |
| PSEL | Peripheral Select |
| PENABLE | Transfer Enable |
| PREADY | Slave Ready |

---

## 2. Baud Generator

The baud generator creates baud-rate timing pulses required by UART TX and UART RX.

### Working

A clock divider divides the system clock according to:

Baud Divisor = Clock Frequency / Baud Rate

Example:

- Clock Frequency = 50 MHz
- Baud Rate = 115200

Divisor ≈ 434

The baud generator produces one baud_tick every 434 clock cycles.

---

## 3. TX FIFO

The TX FIFO acts as a temporary buffer between APB and UART TX.

### Functions

- Stores outgoing bytes
- Reduces processor intervention
- Prevents transmission stalls

### FIFO Parameters

- Data Width = 8 bits
- Depth = 16 entries

---

## 4. RX FIFO

The RX FIFO stores received bytes until they are read by the processor.

### Functions

- Prevents data loss
- Supports continuous reception
- Decouples UART RX from CPU timing

---

## 5. UART Transmitter

The UART TX converts parallel data into serial format.

### UART Frame Format

```
Start Bit | 8 Data Bits | Stop Bit
     0    |  D0-D7      |     1
```

### Transmission Sequence

1. Start Bit
2. Data Bits (LSB First)
3. Stop Bit

---

## UART TX FSM

![UART TX FSM](docs/uart_tx_fsm.png)

### States

| State | Function |
|---------|----------|
| IDLE | Wait for Data |
| START | Send Start Bit |
| DATA | Send 8 Data Bits |
| STOP | Send Stop Bit |

---

## 6. UART Receiver

UART RX receives serial data and reconstructs parallel bytes.

### Reception Sequence

1. Detect Start Bit
2. Receive 8 Data Bits
3. Verify Stop Bit
4. Store Data

---

## UART RX FSM

![UART RX FSM](docs/uart_rx_fsm.png)

### States

| State | Function |
|---------|----------|
| IDLE | Monitor RX Line |
| START | Detect Start Bit |
| DATA | Receive Data Bits |
| STOP | Validate Stop Bit |
| DONE | Reception Complete |

---

# Verification

The design was verified through dedicated testbenches for:

- Baud Generator
- FIFO
- UART TX
- UART RX
- APB Slave
- Top-Level Integration

Waveforms were analyzed using GTKWave.

---

# Simulation Results

The simulation confirms:

✔ Successful APB transactions

✔ Correct baud-rate generation

✔ Reliable UART transmission

✔ Accurate UART reception

✔ Proper FIFO buffering

✔ End-to-end data transfer

---

# Applications

- Portable ECG Monitoring Systems
- Biomedical Devices
- Embedded Communication Systems
- FPGA-Based SoCs
- Industrial Monitoring Systems
- Sensor Data Acquisition Platforms

---

# Future Work

- Configurable Baud Rates
- Parity Bit Support
- Variable Data Length Support
- Interrupt-Based Communication
- FPGA Implementation
- Portable ECG Monitoring System Integration
- RISC-V SoC Integration

---

# Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- Ubuntu Linux
- Git
- GitHub

---

# License

This project is intended for academic and educational purposes.
