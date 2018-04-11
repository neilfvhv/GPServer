function run(input_filename, output_filename)

    %%%%%%%%%%%%%%%%%%%%%%% add path %%%%%%%%%%%%%%%%%%%%%%%%%%
    addpath(genpath('whyte_code'));
    addpath(genpath('cho_code'));
    addpath(genpath('fina_deconvolution_code'));

    %%%%%%%%%%%%%%%%%%%%%%% image preprocessing %%%%%%%%%%%%%%%
    y = imread(input_filename);
    y = im2double(y);
    sigma = 0;
    y = y + sigma * randn(size(y));
    if size(y, 3) == 3
        yg = rgb2gray(y);
    end

    %%%%%%%%%%%%%%%%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%%%%
    lambda_p = 0;
    lambda_g = 4e-3;

    %%%%%%%%%%%%%%%%%%%%%%% options %%%%%%%%%%%%%%%%%%%%%%%%%%
    opts.prescale = 1;
    opts.xk_iter = 5;
    opts.gamma_correct = 1.0;
    opts.k_thresh = 20;
    opts.kernel_size = 31;
    opts.usegpu = 1;
    net_x = LoadNet('model_Noisy_15_to_Direct_ClearGradient_X', 75, opts.usegpu);
    net_y = LoadNet('model_Noisy_15_to_Direct_ClearGradient_Y', 75, opts.usegpu);
    opts.net_x = net_x;
    opts.net_y = net_y;

    %%%%%%%%%%%%%%%%%%%%%%% running %%%%%%%%%%%%%%%%%%%%%%%%%%%
    [kernel, interim_latent] = blind_deconv_2(yg, lambda_p, lambda_g, opts);
    x1 = whyte_deconv(y, kernel);

    %%%%%%%%%%%%%%%%%%%%%%% saving %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    imwrite(x1, output_filename);

end
