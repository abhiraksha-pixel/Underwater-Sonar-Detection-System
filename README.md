
# Underwater Sonar Detection System

### LFM Sonar Signal Processing, Adaptive CFAR Detection and Interactive MATLAB Dashboard

## Overview

Underwater Sonar Detection System is a MATLAB-based signal processing project designed to detect underwater objects and estimate their distances using simulated acoustic signals.

The project implements Linear Frequency Modulation (LFM), Matched Filtering, Fast Fourier Transform (FFT), and Constant False Alarm Rate (CFAR) detection to identify underwater objects in the presence of noise and reverberation.

Unlike conventional detection techniques that use a fixed threshold, this system implements an adaptive detection approach that dynamically adjusts the detection threshold according to the surrounding noise power.

The system generates acoustic sonar pulses, simulates reflected echoes from multiple underwater objects, processes received signals, and estimates object distances based on round-trip signal propagation time.

The project also includes an interactive MATLAB dashboard featuring animated 360-degree sonar visualization, adjustable noise levels, scanning controls, object detection statistics, and distance estimation results.

The primary goal is to demonstrate how digital signal processing and adaptive detection techniques can be applied to underwater object detection and acoustic ranging.

## Features

- **LFM Sonar Signal Generation:** Generates frequency-modulated acoustic sonar pulses.
- **Multiple Object Detection:** Detects multiple simulated underwater objects at different distances.
- **Underwater Echo Simulation:** Generates reflected acoustic signals based on object distances.
- **Noise Simulation:** Introduces Gaussian noise to simulate underwater disturbances.
- **Reverberation Simulation:** Models simplified underwater background reflections.
- **Matched Filtering:** Enhances target echoes within noisy received signals.
- **FFT-Based Signal Processing:** Calculates the analytic signal and power-based range profile.
- **Adaptive CFAR Detection:** Dynamically calculates detection thresholds based on local noise power.
- **False Detection Reduction:** Suppresses closely spaced unwanted detection peaks.
- **Automatic Distance Estimation:** Calculates object distances using acoustic signal propagation time.
- **Performance Evaluation:** Measures detection rate, false detections, missed objects, and distance estimation error.
- **Animated Sonar Visualization:** Provides a rotating 360-degree sonar-style display.
- **Interactive Dashboard:** Integrates sonar visualization, system controls, and performance statistics.
- **Adjustable Noise Control:** Allows users to evaluate detection performance under different noise conditions.
- **Scanning Controls:** Provides Start, Stop, and Reset functionality.
- **Toolbox-Free Implementation:** Operates using base MATLAB without requiring additional signal processing toolboxes.

## System Architecture

The project follows a structured underwater acoustic signal processing pipeline:

```text
          SONAR SYSTEM PARAMETERS
                     |
                     v
          LFM SIGNAL GENERATION
                     |
                     v
          TRANSMITTED SONAR PULSE
                     |
                     v
       UNDERWATER ENVIRONMENT SIMULATION
                     |
                     v
          MULTIPLE UNDERWATER OBJECTS
                     |
                     v
             REFLECTED ECHOES
                     |
                     v
          NOISE AND REVERBERATION
                     |
                     v
             RECEIVED SIGNAL
                     |
                     v
             MATCHED FILTERING
                     |
                     v
         FFT-BASED ENVELOPE ANALYSIS
                     |
                     v
          POWER-BASED RANGE PROFILE
                     |
                     v
          ADAPTIVE CA-CFAR DETECTION
                     |
                     v
             PEAK DETECTION
                     |
                     v
          FALSE DETECTION REDUCTION
                     |
                     v
             DISTANCE ESTIMATION
                     |
          +----------+----------+
          |                     |
          v                     v
     PERFORMANCE          ANIMATED 2D
      EVALUATION          SONAR DISPLAY
          |                     |
          +----------+----------+
                     |
                     v
         INTERACTIVE MATLAB DASHBOARD
```

## System Modules

### 1. Sonar Signal Generation

The system generates an acoustic sonar pulse using Linear Frequency Modulation (LFM).

LFM signals continuously vary their frequency over time and are commonly referred to as chirp signals.

The transmitted signal is generated mathematically without using the MATLAB Signal Processing Toolbox.

The system applies a manually generated Hann window to reduce spectral leakage and unwanted sidelobes.

The sonar configuration uses the following parameters:

| Parameter | Value |
|---|---|
| Speed of Sound in Water | 1500 m/s |
| Sampling Frequency | 200 kHz |
| Center Frequency | 30 kHz |
| Starting Frequency | 26 kHz |
| Ending Frequency | Approximately 34 kHz |
| Signal Bandwidth | 8 kHz |
| Pulse Duration | 2 ms |
| Maximum Observation Range | 350 m |

### 2. Underwater Object Simulation

The system simulates multiple underwater objects located at different distances from the sonar source.

Each object is assigned a distance and a relative echo amplitude.

| Object | Actual Distance | Relative Echo Amplitude |
|---|---|---|
| Object 1 | 120 m | 1.00 |
| Object 2 | 185 m | 0.72 |
| Object 3 | 260 m | 0.55 |

The reflected signal from each object is generated by delaying and scaling the transmitted sonar pulse.

The delay represents the time required for the acoustic signal to travel from the sonar source to the object and return.

### 3. Echo Signal Generation

The system calculates the round-trip propagation delay for each underwater object.

The round-trip time is calculated using:

```text
t = 2d / c
```

Where:

- t = Round-trip propagation time in seconds.
- d = Distance of the underwater object in metres.
- c = Speed of sound in water.

The delayed echoes from all simulated objects are combined to generate the received sonar signal.

### 4. Noise and Reverberation Simulation

Underwater acoustic signals can be affected by environmental disturbances, marine activity, background noise, and reflections from underwater surfaces.

The system introduces two types of disturbances:

- Gaussian background noise.
- Simplified reverberation generated using smoothed random noise.

These disturbances are combined with the reflected sonar echoes to simulate noisy underwater signal reception.

The interactive dashboard allows users to adjust the Gaussian noise level between 0 and 1.

| Noise Level | Simulation Condition |
|---|---|
| 0.00 | No added Gaussian noise |
| 0.12 | Default noise condition |
| 0.25 | Increased noise |
| 0.50 | High noise |
| 1.00 | Very high noise |

The simplified reverberation component remains present even when the Gaussian noise level is set to zero.

### 5. Matched Filtering

Matched filtering is a digital signal processing technique used to detect known signals within noisy received signals.

The system performs convolution between the received sonar signal and the time-reversed transmitted pulse.

```text
Matched Filter = Time-Reversed Transmitted Signal

Matched Filter Output = Convolution of Received Signal
                        and Matched Filter
```

This process enhances reflected sonar echoes and produces prominent peaks corresponding to potential underwater objects.

Matched filtering improves the signal-to-noise ratio and supports accurate estimation of echo arrival times.

### 6. FFT-Based Envelope Analysis

The system implements an FFT-based analytic signal calculation as an alternative to the toolbox-dependent Hilbert transform function.

The matched-filter output is transformed into the frequency domain using Fast Fourier Transform (FFT).

A frequency-domain multiplier is applied, followed by Inverse Fast Fourier Transform (IFFT), to generate the analytic signal.

The power-based range profile is calculated using:

```text
Range Profile = |Analytic Signal|²
```

The resulting range profile represents reflected signal power across different underwater distances.

### 7. Adaptive CFAR Detection

Constant False Alarm Rate (CFAR) is an adaptive detection technique commonly used in radar and sonar signal processing.

The project implements Cell-Averaging Constant False Alarm Rate (CA-CFAR).

Unlike fixed-threshold detection, CA-CFAR estimates the surrounding noise power and dynamically adjusts the detection threshold.

The algorithm consists of three main components:

- **Training Cells:** Estimate the surrounding noise power.
- **Guard Cells:** Reduce contamination of the noise estimate by target signal energy.
- **Cell Under Test (CUT):** Represents the signal sample being evaluated for target detection.

The CFAR processing structure is represented below:

```text
+----------------+-------------+-----+-------------+----------------+
| Training Cells | Guard Cells | CUT | Guard Cells | Training Cells |
+----------------+-------------+-----+-------------+----------------+
         |                              |
         +--------------+---------------+
                        |
                        v
              LOCAL NOISE ESTIMATION
                        |
                        v
              ADAPTIVE THRESHOLD
                        |
                        v
               TARGET DETECTION
```

The adaptive detection threshold is calculated using:

```text
Threshold = Alpha × Estimated Noise Power
```

Where:

```text
Alpha = N × (Pfa^(-1/N) - 1)
```

- N = Total number of training cells.
- Pfa = Nominal false alarm probability setting.
- Alpha = CFAR threshold scaling factor.

A signal sample is considered a potential target when its power exceeds the adaptive threshold.

The project uses the following CFAR configuration:

| Parameter | Value |
|---|---|
| CFAR Algorithm | Cell-Averaging CFAR |
| Training Cells | 200 on each side |
| Guard Cells | 100 on each side |
| Total Training Cells | 400 |
| Nominal False Alarm Probability | 0.00001 |
| Minimum Peak Separation | 3 metres |

The nominal false alarm probability is an algorithm configuration parameter and does not represent a measured real-world false alarm rate.

### 8. Peak Detection and False Detection Reduction

The system identifies local maxima within the CFAR-detected signal samples.

Potential target peaks are sorted according to their signal power.

A minimum separation distance of 3 metres is applied between retained peaks to suppress closely spaced unwanted detections.

This approach reduces duplicate detections caused by noise and matched-filter sidelobes.

However, genuine underwater objects separated by less than the configured minimum distance may also be suppressed.

### 9. Distance Estimation

The distance of each detected underwater object is calculated using the round-trip travel time of the reflected acoustic signal.

```text
Distance = (Speed of Sound × Round-Trip Time) / 2
```

Mathematically:

```text
d = (c × t) / 2
```

Where:

- d = Estimated object distance in metres.
- c = Speed of sound in water (1500 m/s).
- t = Round-trip propagation time in seconds.

The estimated object distances are compared with their actual simulated distances.

| Object | Round-Trip Time | Actual Distance |
|---|---|---|
| Object 1 | 0.1600 seconds | 120 m |
| Object 2 | 0.2467 seconds | 185 m |
| Object 3 | 0.3467 seconds | 260 m |

### 10. Performance Evaluation

The system evaluates target detection and distance estimation performance using multiple metrics.

| Metric | Purpose |
|---|---|
| Correct Detections | Counts successfully detected simulated objects. |
| Missed Objects | Counts simulated objects that were not detected. |
| False Detections | Counts detections that do not match actual simulated objects. |
| Detection Rate | Measures the percentage of actual objects successfully detected. |
| Mean Distance Error | Measures the average absolute distance estimation error for matched objects. |
| Nominal Range Resolution | Estimates theoretical range resolution based on signal bandwidth. |

The target detection rate is calculated using:

```text
Detection Rate (%) = (Correct Detections / Actual Objects) × 100
```

The nominal range resolution is calculated using:

```text
Range Resolution = c / (2 × B)
```

Where:

- c = Speed of sound in water.
- B = Transmitted signal bandwidth.

For the configured bandwidth of 8 kHz:

```text
Range Resolution = 1500 / (2 × 8000)

Range Resolution = 0.09375 metres
```

This is a nominal bandwidth-based resolution estimate. Actual resolution depends on signal processing, windowing, noise, and detection conditions.

### 11. Animated Sonar Visualization

The system provides an animated 360-degree sonar-style display.

The visualization includes:

- Circular distance indicators.
- Angular reference lines.
- Rotating sonar scanning line.
- Detected underwater object markers.
- Estimated object distance labels.
- Automatic object count.

The displayed distances are obtained from the sonar signal processing algorithm.

The angular positions of detected objects are assigned for visualization purposes and do not represent measured object directions.

## Dashboard Modules

The interactive MATLAB dashboard provides the following sections:

| Module | Functionality |
|---|---|
| Start Scanning | Executes target detection and starts the rotating sonar visualization. |
| Stop Scanning | Stops the sonar scanning animation. |
| Reset System | Clears detection results and restores default settings. |
| Noise Control | Adjusts simulated Gaussian noise and recalculates detection results. |
| System Parameters | Displays sonar frequency, bandwidth, sound speed, and maximum range. |
| Live Sonar Display | Displays detected underwater objects and their estimated distances. |
| Object Counter | Displays the total number of detected objects. |
| Detection Rate | Displays the percentage of simulated objects successfully detected. |
| False Detection Counter | Displays unmatched target detections. |
| Distance Error | Displays the mean absolute distance estimation error. |
| Distance Table | Displays individual detected object distances. |
| Scan Angle Indicator | Displays the current animation angle. |
| System Status | Displays Ready, Processing, Scanning, and Stopped states. |

The dashboard integrates signal processing, adaptive target detection, performance evaluation, and animated visualization into a single graphical user interface.

## Dashboard Architecture

```text
+---------------------------------------------------------------+
|              INTERACTIVE UNDERWATER SONAR SYSTEM               |
+------------------+-------------------------+------------------+
|                  |                         |                  |
|  SONAR CONTROLS  |   LIVE SONAR DISPLAY    | DETECTION RESULTS|
|                  |                         |                  |
|  Start Scanning  |    Circular Range Grid  | Objects Detected |
|                  |                         |                  |
|  Stop Scanning   |    Rotating Scan Line   | Detection Rate   |
|                  |                         |                  |
|  Reset System    |    Detected Objects     | False Detections |
|                  |                         |                  |
|  Noise Slider    |    Distance Labels      | Mean Error       |
|                  |                         |                  |
|  System          |    360-Degree Sonar     | Distance Table   |
|  Parameters      |    Visualization        |                  |
|                  |                         | Scan Angle       |
|  System Status   |                         | Range Resolution |
|                  |                         |                  |
+------------------+-------------------------+------------------+
```

## MATLAB Visualization Outputs

The MATLAB CFAR implementation generates six visualization outputs.

| Figure | Visualization |
|---|---|
| Figure 1 | Transmitted LFM Sonar Signal |
| Figure 2 | Received Signal with Noise and Reverberation |
| Figure 3 | Matched Filter Range Profile |
| Figure 4 | Adaptive CFAR Underwater Object Detection |
| Figure 5 | Actual vs Estimated Object Distance |
| Figure 6 | Animated 2D Underwater Sonar Display |

The interactive dashboard provides an additional integrated visualization interface.

## Technology Stack

**Programming Language**

- MATLAB

**Development Environment**

- MATLAB R2026b
- MATLAB Editor
- MATLAB Command Window

**Digital Signal Processing**

- Linear Frequency Modulation (LFM)
- Matched Filtering
- Convolution
- Fast Fourier Transform (FFT)
- Inverse Fast Fourier Transform (IFFT)
- Analytic Signal Calculation
- Hann Windowing
- Power-Based Range Analysis

**Detection Algorithms**

- Cell-Averaging Constant False Alarm Rate (CA-CFAR)
- Local Maximum Peak Detection
- Minimum Peak Separation
- Acoustic Time-of-Flight Estimation

**Frontend and Visualization**

- MATLAB UI Figure
- MATLAB UI Axes
- MATLAB UI Panels
- MATLAB UI Buttons
- MATLAB UI Slider
- MATLAB UI Table
- MATLAB Polar Plots
- MATLAB Timer-Based Animation

**Performance Evaluation**

- Target Detection Rate
- False Detection Count
- Missed Object Count
- Mean Absolute Distance Error
- Nominal Range Resolution

## Project Structure

```text
Underwater-Sonar-Detection-System/
│
├── underwater_object_detection.m
│
├── Underwater_Sonar_CFAR.m
│
├── Underwater_Sonar_Dashboard.m
│
└── README.md
```

### File Description

| File | Description |
|---|---|
| underwater_object_detection.m | Original underwater sonar signal processing implementation. |
| Underwater_Sonar_CFAR.m | Upgraded toolbox-free sonar simulation with adaptive CFAR detection, performance evaluation, and animated sonar visualization. |
| Underwater_Sonar_Dashboard.m | Standalone interactive MATLAB dashboard with scanning controls, noise adjustment, target detection, and performance statistics. |
| README.md | Project documentation, architecture, installation instructions, and implementation details. |

The upgraded CFAR and dashboard implementations are standalone MATLAB scripts and do not require external datasets or additional supporting functions.

## Installation and Setup

### 1. Clone the Repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

### 2. Navigate to the Project Directory

```bash
cd Underwater-Sonar-Detection-System
```

### 3. Install MATLAB

Ensure MATLAB is installed on your system.

The project was developed and demonstrated using:

```text
MATLAB R2026b
```

### 4. Verify MATLAB Installation

Open MATLAB and execute the following command in the Command Window:

```matlab
ver
```

This command displays the installed MATLAB version and available toolboxes.

### 5. Open the Project Folder

Navigate to the cloned project directory using the MATLAB Current Folder panel.

Alternatively, use:

```matlab
cd('YOUR_PROJECT_FOLDER_PATH')
```

### Dependencies

The upgraded implementation uses base MATLAB functions.

No additional installation of the following toolboxes is required:

- Signal Processing Toolbox
- Phased Array System Toolbox
- DSP System Toolbox
- Statistics and Machine Learning Toolbox

No Python environment, external libraries, physical sonar sensors, or external datasets are required.

## How to Run the Project

### Basic Sonar Implementation

Open the original MATLAB script:

```text
underwater_object_detection.m
```

Execute the following command:

```matlab
underwater_object_detection
```

The original implementation is retained as a reference. Depending on its version, it may contain toolbox-dependent functions.

For toolbox-free execution, use the upgraded CFAR implementation.

### Adaptive CFAR Implementation

**Step 1:** Open the following MATLAB script:

```text
Underwater_Sonar_CFAR.m
```

**Step 2:** Click the Run button or press F5.

Alternatively, execute:

```matlab
Underwater_Sonar_CFAR
```

**Step 3:** View the generated visualization outputs.

The system displays:

- Transmitted sonar signal.
- Received noisy sonar signal.
- Matched filter range profile.
- Adaptive CFAR target detection.
- Actual versus estimated distances.
- Animated underwater sonar display.

**Step 4:** Review the detection results and performance statistics in the MATLAB Command Window.

### Interactive MATLAB Dashboard

**Step 1:** Open the following MATLAB script:

```text
Underwater_Sonar_Dashboard.m
```

**Step 2:** Execute the script:

```matlab
Underwater_Sonar_Dashboard
```

**Step 3:** Wait for the interactive dashboard to open.

**Step 4:** Click START SCANNING.

**Step 5:** Observe the detected underwater objects and estimated distances.

**Step 6:** Adjust the noise slider to evaluate detection performance under different noise conditions.

**Step 7:** Click STOP SCANNING to stop the rotating sonar visualization.

**Step 8:** Click RESET SYSTEM to clear the results and restore the default configuration.

## Experimental Configuration

The default simulation uses the following configuration:

| Parameter | Configuration |
|---|---|
| Number of Underwater Objects | 3 |
| Object 1 Distance | 120 m |
| Object 2 Distance | 185 m |
| Object 3 Distance | 260 m |
| Speed of Sound | 1500 m/s |
| Center Frequency | 30 kHz |
| Sampling Frequency | 200 kHz |
| Bandwidth | 8 kHz |
| Pulse Duration | 2 ms |
| Maximum Observation Range | 350 m |
| Default Noise Level | 0.12 |
| Reverberation Scaling Factor | 0.08 |
| Minimum Peak Separation | 3 m |
| Random Seed | 1 |

A fixed random seed is used to provide repeatable simulation results.

## Experimental Results

The system successfully detected all three simulated underwater objects under the default experimental configuration.

### Distance Estimation Results

| Object | Actual Distance | Estimated Distance (Rounded) |
|---|---|---|
| Object 1 | 120 m | 120.00 m |
| Object 2 | 185 m | 185.00 m |
| Object 3 | 260 m | 260.00 m |

### Performance Statistics

| Performance Metric | Result |
|---|---|
| Actual Objects | 3 |
| Detected Objects | 3 |
| Correct Detections | 3 |
| Missed Objects | 0 |
| False Detections | 0 |
| Target Detection Rate | 100% |
| Detection Precision | 100% |
| Mean Distance Error | 0.0008 m |
| Nominal Range Resolution | 0.094 m |
| Maximum Observation Range | 350 m |

The experimental results demonstrate the effectiveness of matched filtering and adaptive CFAR detection for the configured simulated underwater environment.

These results are specific to the default simulation and may vary when noise levels, target distances, echo amplitudes, or detection parameters are modified.

## Implementation Comparison

The project demonstrates the progression from a basic sonar simulation to an adaptive detection system with an interactive dashboard.

| Parameter | Basic Sonar | Upgraded CFAR Sonar | Interactive Dashboard |
|---|---|---|---|
| LFM Signal Generation | Supported | Supported | Supported |
| Multiple Object Simulation | Supported | Supported | Supported |
| Noise Simulation | Supported | Supported | Supported |
| Matched Filtering | Supported | Supported | Supported |
| Adaptive CFAR | Not Included | Supported | Supported |
| False Detection Reduction | Basic | Supported | Supported |
| Distance Estimation | Supported | Supported | Supported |
| Performance Evaluation | Basic | Detailed | Integrated |
| Animated Sonar Display | Not Included | Supported | Supported |
| Interactive Noise Control | Not Included | Not Included | Supported |
| Start and Stop Controls | Not Included | Not Included | Supported |
| Graphical User Interface | Not Included | Separate Figures | Integrated Dashboard |
| Toolbox-Free Execution | Version Dependent | Supported | Supported |

## Potential Applications

The signal processing techniques demonstrated in this project are relevant to several underwater acoustic applications.

- Underwater obstacle detection.
- Autonomous underwater vehicle navigation.
- Remotely operated underwater vehicles.
- Marine object detection.
- Underwater acoustic monitoring.
- Ocean exploration and surveying.
- Underwater search and rescue.
- Submerged infrastructure inspection.
- Underwater robotics.
- Sonar signal processing research.
- Digital signal processing education.

These represent potential applications of the underlying sonar techniques rather than validated deployments of the current simulation.

## Advantages

- Adaptive detection threshold based on surrounding noise conditions.
- Multiple underwater object detection.
- Automatic distance estimation.
- Improved suppression of unwanted detection peaks.
- Repeatable simulation results.
- Interactive noise adjustment.
- Integrated performance evaluation.
- Animated sonar visualization.
- User-friendly graphical interface.
- Low-cost simulation-based implementation.
- No additional MATLAB toolboxes required for the upgraded implementation.
- No external hardware or datasets required.

## Project Objective

The objective of this project is to develop an underwater sonar simulation system capable of detecting multiple underwater objects and estimating their distances using digital signal processing and adaptive detection techniques.

By combining Linear Frequency Modulation, Matched Filtering, FFT-Based Envelope Analysis, and Adaptive CFAR Detection, the system processes reflected acoustic signals and identifies potential underwater objects in the presence of simulated environmental noise.

The project demonstrates the application of Digital Signal Processing, acoustic signal analysis, adaptive thresholding, time-of-flight distance estimation, and graphical user interface development using MATLAB.

The interactive dashboard provides an accessible platform for understanding sonar operation, evaluating detection performance, and visualizing underwater object distances.

## Future Enhancements

- Integration with physical sonar sensors and hydrophones.
- Real-time underwater acoustic signal acquisition.
- Support for recorded sonar datasets.
- Doppler-based underwater object speed estimation.
- Range-Doppler map visualization.
- Moving underwater object simulation.
- Multiple object tracking.
- Direction-of-arrival estimation.
- Beamforming and sonar sensor array processing.
- Machine learning-based underwater object classification.
- Advanced underwater multipath channel modelling.
- Improved noise and reverberation modelling.
- Dynamic underwater object configuration.
- Three-dimensional underwater sonar visualization.
- Export of detection results to CSV files.
- Real-time underwater obstacle detection and navigation.

## Important Note

This project is an academic simulation-based implementation of underwater sonar signal processing and adaptive CFAR detection.

The current system does not use physical sonar hardware or real underwater acoustic measurements.

The estimated object distances are calculated from simulated reflected acoustic signals. The angular positions displayed in the sonar visualization are assigned for illustrative purposes and do not represent actual direction-of-arrival measurements.

The rotating sonar scanning line is a graphical animation and does not perform physical directional scanning.

The speed of sound in water is assumed to be constant at 1500 m/s. In practical underwater environments, sound propagation depends on temperature, salinity, pressure, and other environmental conditions.

The reported detection rate of 100% and mean distance error of 0.0008 metres are specific to the default simulation configuration and should not be interpreted as guaranteed real-world sonar performance.

The configured minimum peak separation may suppress genuine closely spaced underwater objects.

## Author

**Abhi Raksha**

B.Tech – Electronics and Computer Science  
Specialization: Artificial Intelligence and Machine Learning

LinkedIn: https://www.linkedin.com/in/abhi-raksha-9b3b80369/
