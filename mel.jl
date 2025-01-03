using Plots
include("./dsp.jl")

function create_mel_spectrogram(input_path::String, output_path::String)

    data, sampling_frequency = wavread(input_path)

 
    window_length = nextpow(2, ceil(Int, .04 * sampling_frequency))  # 40 ms window
    hop_length = div(window_length,10)  


    mag, phase, freq, fs = stft(input_path, window_length, hop_length, "hamming")

    num_mels = 512

    mel_bank = mel_filterbank(num_mels, window_length, sampling_frequency)

    power_spectrogram = mag .^ 2

    mel_spectrogram_vec = zeros(Float32, num_mels, size(power_spectrogram, 2))
    for i in 1:size(power_spectrogram, 2)
        mel_spectrogram_vec[:, i] = mel_bank * power_spectrogram[:, i]
    end

    # mel_spectrogram_db = 10 * log10.(power_spectrogram .+ 1e-7)
    mel_spectrogram_db = 10 * log10.(mel_spectrogram_vec .+ 1e-7)


    plt = heatmap(
        mel_spectrogram_db,
        color=:thermal,
        # xlabel="Time (milli seconds)",
        # ylabel="Mel Frequency (Hz)",
        # axis=false,
        # legend=false,
        size=(1920,1080),
        framestyle=:none
    )

    savefig(plt, "./ouput.png")
end

create_mel_spectrogram("./sep/test/Black Woodpecker/0.wav_1.wav", "./output_mel_spectrogram.png")
