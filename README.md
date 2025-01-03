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
   \[
   \text{Mel} = 2595 \cdot \log_{10}(1 + \frac{f}{700})
   \]
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
1. **Hann**: \( 0.5 \cdot (1 - \cos(\frac{2\pi n}{N-1})) \)
2. **Hamming**: \( 0.54 - 0.46 \cdot \cos(\frac{2\pi n}{N-1}) \)
3. **Blackman**: \( 0.42 - 0.5 \cdot \cos(\frac{2\pi n}{N-1}) + 0.08 \cdot \cos(\frac{4\pi n}{N-1}) \)
4. **Gaussian**: \( e^{-\frac{1}{2} \left(\frac{n-N/2}{\sigma \cdot N/2}\right)^2} \)

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
- `fs`: Sampling frequency of the audio file.

#### Steps:
1. Divide the signal into overlapping windows.
2. Apply a window function to each segment.
3. Compute the FFT for each window.
4. Extract magnitude and phase from the FFT output.

---

### 4. `create_mel_spectrogram`

#### Purpose:
Generate and save a Mel spectrogram from an audio file.

#### Arguments:
- `input_path::String`: Path to the input audio file.
- `output_path::String`: Path to save the generated Mel spectrogram image.

#### Returns:
- None (saves the spectrogram as an image).

#### Steps:
1. Load the audio file and extract data and sampling frequency.
2. Define window and hop lengths based on the sampling rate.
3. Perform STFT to obtain the spectrogram.
4. Generate a Mel filterbank.
5. Apply the filterbank to the power spectrogram to create a Mel spectrogram.
6. Convert to decibel (dB) scale:
   \[
   \text{Mel Spectrogram (dB)} = 10 \cdot \log_{10}(\text{Mel Spectrogram} + 1e-7)
   \]
7. Visualize and save the spectrogram using a heatmap.

---

## Example Usage

```julia
# Generate a Mel spectrogram for an audio file
create_mel_spectrogram(
    "./sep/test/Black Woodpecker/0.wav_1.wav",
    "./output_mel_spectrogram.png"
)
