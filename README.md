# 🩺 Digital Stethoscope with Noise Suppression using FPGA & FIR Filter

![FPGA](https://img.shields.io/badge/Platform-FPGA-blue.svg)
![HDL](https://img.shields.io/badge/Language-Verilog%20%2F%20VHDL-orange.svg)
![DSP](https://img.shields.io/badge/DSP-FIR%20Filter-brightgreen.svg)
![Status](https://img.shields.io/badge/Status-Completed-success.svg)

## 📖 Project Overview
Traditional acoustic stethoscopes often struggle with ambient noise and low signal amplitude, making accurate medical diagnosis challenging in noisy environments. This project implements a **Real-Time Digital Stethoscope** using a **Field Programmable Gate Array (FPGA)**. 

By capturing raw audio signals and passing them through a custom-designed **Finite Impulse Response (FIR) Filter**, this system effectively suppresses background noise and isolates the low-frequency heart and lung sounds (typically 20 Hz to 400 Hz) for crystal-clear auditory analysis.

## ✨ Key Features
* **Real-Time Processing:** High-speed, deterministic signal processing utilizing the parallel architecture of an FPGA.
* **Custom FIR Filter:** [Insert Tap Number, e.g., 64-tap] Low-pass/Band-pass FIR filter optimized for human physiological acoustics.
* **Hardware Noise Suppression:** Eliminates ambient noise and high-frequency artifacts without the latency of software-based systems.
* **Analog-to-Digital Interfacing:** Seamless integration with standard digital microphones or analog audio inputs via ADC/I2S protocols.
* **Optimized Resource Utilization:** Efficient use of FPGA DSP slices, LUTs, and Block RAM.

## ⚙️ System Architecture

### 1. Data Acquisition (Input Stage)
An electronic microphone captures the heart sounds. The analog signal is digitized using an onboard ADC (or external I2S module) operating at a sampling rate of [e.g., 8 kHz or 44.1 kHz], optimized for physiological audio frequencies.

### 2. DSP Core: The FIR Filter
The digitized signal is fed into the custom FIR filter block. 
* **Filter Type:** [e.g., Low-Pass Filter]
* **Cutoff Frequency:** [e.g., 400 Hz]
* **Windowing Technique:** [e.g., Hamming / Blackman Window]
* **Implementation:** Multiply-Accumulate (MAC) operations utilizing the FPGA's dedicated DSP slices.

### 3. Output Stage
The filtered digital signal is routed to a DAC (Digital-to-Analog Converter) or PWM output, driving a standard 3.5mm audio jack for headphones or speakers.

## 🛠️ Hardware & Software Requirements

### Hardware
* **FPGA Development Board:** [e.g., Xilinx Basys 3 / Digilent Zybo Z7 / Intel Cyclone V]
* **Input Device:** [e.g., Pmod MIC3, Electret Microphone Amplifier with ADC]
* **Output Device:** Standard Headphones / Speaker connected via [e.g., Pmod I2S2 or onboard audio jack]

### Software / Tools
* **Synthesis & Implementation:** [e.g., Xilinx Vivado 2022.2 / Intel Quartus Prime]
* **Filter Design:** MATLAB (Filter Designer app) or Python (SciPy) for generating filter coefficients.
* **HDL:** [Verilog / VHDL / SystemVerilog]

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone [https://github.com/Warrrinoix/Digital-Stethoscope-with-Noise-Suppression-using-FPGA-FIR_Filter-.git](https://github.com/Warrrinoix/Digital-Stethoscope-with-Noise-Suppression-using-FPGA-FIR_Filter-.git)
cd Digital-Stethoscope-with-Noise-Suppression-using-FPGA-FIR_Filter-
