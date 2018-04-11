function [k, lambda_pixel, lambda_grad, S] = blind_deconv_main_2(blur_B, k, ...
    lambda_pixel, lambda_grad, threshold, opts,num_scales)

pars.BC = 'periodic';
pars.MAXITER =20;
pars.lambda = 1e-10;%9e-5;%4e-5;%1e-2,5e-3
pars.gammax = 1e-2;
pars.gammak = 1e-5;
pars.mu = 0.013;%0.015;%0.02;%LBFGS_lambda=0.1;GD = 0.13,2,0.002
pars.mu1 =0;%0.001;%0.001;%0.0005;%0.0001;%0.0001;%0.0001;%0.0001;
pars.beta = 1.03;%1.035;%1.06;
pars.beta_mu1 = 1;% 0.95;% 0.9;
pars.L=4;

pars.noise_level =15;
pars.method = 3;
pars.i = 1;
pars.j = 1;

lambda = pars.lambda;
gammak = pars.gammak;
L = pars.L;
global itercount;
global iterKernelSSIM;

H = size(blur_B,1);    W = size(blur_B,2);
blur_B_w = wrap_boundary_liu(blur_B, opt_fft_size([H W]+size(k)-1));
blur_B_tmp = blur_B_w(1:H,1:W,:);
[m,n]=size(blur_B_tmp);
[Bx ,By] = gradient(blur_B_tmp);

ppb=1.1;
W_ = @dct2;
WT = @idct2;

if num_scales==1
         opts.xk_iter=opts.xk_iter;
end

for iter = 1:opts.xk_iter
    itercount=itercount+1;
    %=============================
    Sbig = psf2otf(k,[m,n]);
%      lambda_=8e-7;
    lambda_=8e-5;
%     lambda_=8e-4;
    FKernel=psf2otf(k,size(blur_B_tmp));
    KtK=abs(FKernel).^2;
    if iter==1
        if num_scales==1
%             Bx=L0Smoothing(Bx,8e-5);
%             By=L0Smoothing(By,8e-5);
        end
        Sx_=Bx;
        Sy_=By;
    end
    Sx=real(ifft2((...
        lambda_*fft2(Sx_)+...
        conj(FKernel).*fft2(Bx))./...
        (KtK+lambda_)));
    Sy=real( ifft2 ((...
        lambda_*fft2(Sy_)+...
        conj(FKernel).*fft2(By))...
        ./(KtK+lambda_)));
    %%%%%%%%%%%%%%%%%%%%%%
    %--------------------------------------------------------------------------------------
%     figure(2);subplot(1,3,1);imshow(Sx+Sy,[]);title(num2str(num_scales));
    %--------------------------------------------------------------------------------------
    Sx_=Sx;
    Sy_=Sy;
    %=============================
    k = estimate_psf(Bx, By, Sx, Sy, 2, size(k));
    %--------------------------------------------------------------------------------------
%     figure(2);subplot(1,3,2);imshow(imresize(k,4),[]);title('First Estimate')
    %---------------------------------------------------------------------------------------
    if lambda_pixel~=0
        if max(size(blur_B_w))<512
            S = L0Deblur_whole(blur_B_w, k, lambda_pixel, lambda_grad, 2.0);
        else
            S = L0Deblur_whole_fast(blur_B_w, k, lambda_pixel, lambda_grad, 2.0);
        end
        S = S(1:H,1:W,:);
    else
        S = L0Restoration(blur_B, k, lambda_grad, 2.0);
    end
    latent_x=net_compute(S,opts.net_x,1);
    latent_y=net_compute(S,opts.net_y,1);
    latent_x = grad_prox_gradh(latent_x,Bx,Sbig,W_,WT,L,lambda);
    latent_y = grad_prox_gradv(latent_y,By,Sbig,W_,WT,L,lambda);
%         latent_x=L0Smoothing(latent_x,8e-5);
%         latent_y=L0Smoothing(latent_y,8e-5);
    [latent_x,latent_y] = threshold_pxpy_my(latent_x,latent_y,max(size(k)),threshold);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    k_prev = k;
    k = estimate_psf(Bx, By, latent_x, latent_y, 2, size(k_prev));
    k = prox_kernel_gradx(Bx, By, latent_x, latent_y,k,L);
    %-----------------------------------------------------------------------------------------------------------------------------------
%     figure(2);subplot(1,3,3);imshow(imresize(k,4),[]);title(['Second Estimate' ' | ' 'Iter=' num2str(iter)]);drawnow;
    %-----------------------------------------------------------------------------------------------------------------------------------
    CC = bwconncomp(k,8);
    for ii=1:CC.NumObjects
        currsum=sum(k(CC.PixelIdxList{ii}));
        if currsum<.1
            k(CC.PixelIdxList{ii}) = 0;
        end
    end
    k(k<0) = 0;
    k=k/sum(k(:));
    
    %% Parameter updating
    if lambda_pixel~=0;
        lambda_pixel = max(lambda_pixel/ppb, 1e-4);
    else
        lambda_pixel = 0;
    end
    lambda_pixel = lambda_pixel/ppb;  %% for natural images
    if lambda_grad~=0;
        lambda_grad = max(lambda_grad/ppb, 1e-4);
    else
        lambda_grad = 0;
    end
    S(S<0) = 0;
    S(S>1) = 1;
    
end;
k(k<0) = 0;
k = k ./ sum(k(:));
