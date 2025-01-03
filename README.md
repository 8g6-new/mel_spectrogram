# Julia Audio Processing Library

This library processes audio files to generate spectrograms and Mel spectrograms, providing tools for spectral analysis and audio visualization. It includes implementations of various window functions, a Short-Time Fourier Transform (STFT) routine, and Mel filterbanks.

---

## Overview

### Core Concepts
1. **Mel Scale**: The Mel scale approximates human auditory perception of pitch, emphasizing frequencies in the range where humans are most sensitive. This scale is used in speech and audio processing for tasks like speech recognition and audio feature extraction.
   
2. **Windowing**: In signal processing, window functions reduce spectral leakage by tapering the signal at the edges before applying FFT. This script supports multiple window functions, each optimized for different signal properties.

3. **Short-Time Fourier Transform (STFT)**: STFT computes the Fourier transform over successive overlapping windows, converting a signal from the time domain to a time-frequency representation.

4. **Mel Spectrogram**: A Mel spectrogram applies a filterbank to the power spectrum, mapping frequencies to the Mel scale. It is a common input for machine learning models in audio processing.

---

## Functions

### 1. `mel_filterbank`

#### Purpose:
Generate a bank of triangular filters mapped to the Mel scale, which is used to transform frequency-domain signals into the Mel scale.

#### Arguments:
- `num_filters::Int`: Number of Mel filters.
- `fft_size::Int`: Size of the FFT used.
- `sample_rate::Float32`: Sampling rate of the audio file.

#### Returns:
- `filterbank`: A `num_filters x (fft_size ÷ 2 + 1)` matrix representing the Mel filterbank.

#### Steps:
1. Convert frequency range to the Mel scale using:
   <div style="text-align:center;">
   <img src="https://github.com/user-attachments/assets/3348d0a7-9847-4d6e-9fe0-280d55bc8d32" alt="Mel Scale Formula" style="width:400px;"/>
   </div>
2. Compute frequency points for the filters and map them to FFT bin indices.
3. Create triangular filters by linearly interpolating between the filter's start, center, and end points.

---

### 2. `apply_window_function`

#### Purpose:
Generate and apply a window function to minimize spectral leakage.

#### Arguments:
- `window_size::Int`: Size of the analysis window.
- `window_type::String`: Type of window function (`"hann"`, `"hamming"`, `"blackman"`, etc.).

#### Returns:
- `window_values`: An array containing the window's values.

#### Supported Windows:
1. **Hann**: 
   <div style="text-align:center;">
   <img src="https://github.com/user-attachments/assets/55d3dfb4-1f7a-4ffe-bf27-a95f72e89b46" alt="Hann Window" style="width:400px;"/>
   </div>
2. **Hamming**: 
   <div style="text-align:center;">
   <img src="https://github.com/user-attachments/assets/18b4c77f-6627-4d01-a5dc-295f7b54c7ad" alt="Hamming Window" style="width:400px;"/>
   </div>
3. **Blackman**: 
   <div style="text-align:center;">
   <img src="https://github.com/user-attachments/assets/fb9e9178-9287-4d16-822a-04af8148fb67" alt="Blackman Window" style="width:400px;"/>
   </div>
4. **Gaussian**: 
   <div style="text-align:center;">
   <img src="https://github.com/user-attachments/assets/af244b5a-4506-4103-bdc7-5ca8bffba618" alt="Gaussian Window" style="width:400px;"/>
   </div>

---

### 3. `stft`

#### Purpose:
Perform the Short-Time Fourier Transform (STFT) to analyze a signal's frequency content over time.

#### Arguments:
- `file_path::String`: Path to the input WAV file.
- `window_size::Int`: Size of each analysis window.
- `hop_size::Int`: Step size between successive windows.
- `window_type::String`: Type of window function (default: `"hamming"`).

#### Returns:
- `mag`: Magnitude of the FFT.
- `phase`: Phase of the FFT.
- `freq`: Frequency bins.
- `fs`: Sampling frequency of the audio file
