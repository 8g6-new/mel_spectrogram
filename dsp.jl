using FFTW, WAV, LinearAlgebra
using SpecialFunctions

function mel_filterbank(num_filters::Int, fft_size::Int, sample_rate::Float32)
    f_min = 0
    f_max = sample_rate / 2
    center = 2595
    log_center = log10(1 + f_min / 700)
    mel_min = center * log_center
    mel_max = center * log10(1 + f_max / 700)
    mel_points = range(mel_min, stop=mel_max, length=num_filters + 2)
    
    freq_points = @. 700 * (10^(mel_points / center) - 1)
    bin_points = round.(Int, freq_points / (sample_rate / fft_size))

    filterbank = zeros(num_filters, fft_size ÷ 2 + 1)
    for m in 1:num_filters
        start_bin = bin_points[m]
        mid_bin = bin_points[m + 1]
        end_bin = bin_points[m + 2]

        for k in start_bin:mid_bin-1
            filterbank[m, k + 1] = (k - start_bin) / (mid_bin - start_bin)
        end

        for k in mid_bin:end_bin-1
            filterbank[m, k + 1] = (end_bin - k) / (end_bin - mid_bin)
        end
    end

    return filterbank
end


function apply_window_function(window_size::Int, window_type::String)
    window_values = zeros(Float64, window_size)
    n = window_size - 1
    indices = 0:n
    π_2 = 2 * π
    π_4 = 4 * π
    π_6 = 6 * π
    π_8 = 8 * π

    if window_type == "hann"
        window_values .= 0.5 .* (1 .- cos.(π_2 .* indices ./ n))
    elseif window_type == "hamming"
        window_values .= 0.54 .- 0.46 .* cos.(π_2 .* indices ./ n)
    elseif window_type == "blackman"
        window_values .= 0.42 .- 0.5 .* cos.(π_2 .* indices ./ n) .+ 0.08 .* cos.(π_4 .* indices ./ n)
    elseif window_type == "bartlett"
        window_values .= 1.0 .- abs.((indices .- n / 2.0) ./ (n / 2.0))
    elseif window_type == "blackman-harris"
        window_values .= 0.35875 .- 0.48829 .* cos.(π_2 .* indices ./ n) .+ 
                         0.14128 .* cos.(π_4 .* indices ./ n) .- 
                         0.01168 .* cos.(π_6 .* indices ./ n)
    elseif window_type == "flattop"
        window_values .= 1 .- 1.93 .* cos.(π_2 .* indices ./ n) .+ 
                            1.29 .* cos.(π_4 .* indices ./ n) .- 
                            0.388 .* cos.(π_6 .* indices ./ n) .+ 
                            0.032 .* cos.(π_8 .* indices ./ n)
    elseif window_type == "gaussian"
        sigma = 0.4  # Standard deviation
        window_values .= exp.(-0.5 .* ((indices .- n / 2.0) ./ (sigma .* n / 2.0)).^2)
    elseif window_type == "kaiser"
        alpha = 3.0  # Shape parameter
        denominator = 1.0 / (gamma(alpha + 1) * gamma(1 - alpha))
        ratio = (indices .- n / 2.0) ./ (n / 2.0)
        window_values .= gamma(alpha + 1) .* gamma(1 - alpha) .* denominator .* exp.(alpha .* sqrt.(1 .- ratio.^2))
    else
        println("Unknown window type. Using rectangular window.")
        fill!(window_values, 1.0)
    end

    return window_values
end

function stft(file_path, window_size, hop_size, window_type="hamming")
    data, fs = wavread(file_path)

    if window_size == 0
        window_size = round(Int, (fs / 2)^0.5) * 2
    end

    num_chunks = div(length(data) - window_size, hop_size) + 1
    half_window = div(window_size, 2)

    mag   = zeros(Float32, half_window + 1, num_chunks)
    phase = zeros(Complex{Float32}, half_window + 1, num_chunks)
    freq  = (0:half_window) * (fs / window_size)

    window_values = apply_window_function(window_size, window_type) # makes the function preiodic for the window

    for i in 1:num_chunks
        start_idx = (i - 1) * hop_size + 1
        chunk = view(data, start_idx:min(start_idx + window_size - 1, length(data)))

        if length(chunk) < window_size
            chunk = vcat(chunk, zeros(window_size - length(chunk)))
        end

        windowed_chunk = chunk .* window_values
        spectrum       = fft(windowed_chunk)[1:half_window+1]

        mag[:, i]      = abs.(spectrum)
        phase[:, i]    = angle.(spectrum)
    end

    return mag, phase, freq, fs
end
