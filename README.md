"""
# Julia Audio Processing Library

This library provides functionality for processing audio files, including 
Short-Time Fourier Transform (STFT), Mel filterbank creation, and Mel spectrogram generation. 
It supports various window functions for spectral analysis.

## Functions

### `mel_filterbank`

Generate a Mel filterbank.

#### Arguments:
- `num_filters::Int`: The number of Mel filters to generate.
- `fft_size::Int`: The size of the FFT used for spectral analysis.
- `sample_rate::Float32`: The sampling rate of the audio signal.

#### Returns:
- A 2D matrix representing the Mel filterbank.

---

### `apply_window_function`

Generate a window function to reduce spectral leakage in FFT analysis.

#### Arguments:
- `window_size::Int`: The size of the window.
- `window_type::String`: The type of window function (e.g., "hann", "hamming", "blackman", etc.).

#### Returns:
- A 1D array containing the window values.

---

### `stft`

Perform the Short-Time Fourier Transform on an audio file.

#### Arguments:
- `file_path::String`: The path to the audio file.
- `window_size::Int`: The size of the analysis window.
- `hop_size::Int`: The number of samples between successive windows.
- `window_type::String`: The type of window function to apply (default: "hamming").

#### Returns:
- `mag`: The magnitude of the FFT for each time frame.
- `phase`: The phase of the FFT for each time frame.
- `freq`: The frequency bins corresponding to the FFT output.
- `fs`: The sampling rate of the audio file.

---

### `create_mel_spectrogram`

Generate a Mel spectrogram from an audio file and save it as an image.

#### Arguments:
- `input_path::String`: Path to the input WAV file.
- `output_path::String`: Path where the Mel spectrogram image will be saved.

#### Steps:
1. Load the audio file using `wavread`.
2. Calculate the window length and hop length based on the sampling rate.
3. Perform STFT using the `stft` function.
4. Create a Mel filterbank using `mel_filterbank`.
5. Compute the power spectrogram and transform it to the Mel scale.
6. Convert the Mel spectrogram to decibels (dB).
7. Plot and save the Mel spectrogram as an image.

---

## Example Usage:

```julia
# Generate a Mel spectrogram for an audio file
create_mel_spectrogram(
    "./sep/test/Black Woodpecker/0.wav_1.wav",
    "./output_mel_spectrogram.png"
)
