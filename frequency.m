% to determine frequency from fort.17 data
% fort.17 generated by hist.x from history.d data 
% previous iterations of this file were frequency_test.m
% or frequency_test_16.m 
% 
% components are which columns of the fort.17 data to use: 
% 2-4, delta b_||,db_r,db_perp2 (edge)
% 5-7, same, (core)
% 8, delta n (core)
% default is to use the deltab components in the core (5:7)

function [fpeaks,Fs]=frequency(n,l,v,sfx,components,do_plot)

if varIsEmpty(components) 
    components = 5:8; 
end 

if varIsEmpty(do_plot) 
    do_plot = 0; 
end 

% set to 1 to interpolate for the fft 
% interp_sample is the sampling rate 
do_interp=0;
interp_sample=10;

% set to 1 to print messages to the console 
write_out=0;

% set to 1 to normalize all signals to 1 
% (may help visualize, but also obscures dominant signal) 
do_norm=0;

% set to 1 to ttempt to fit the envelope of the signal in order to 
% divide out the non-periodic growth, which theoretically 
% interferes with the FT via the convolution theorem
% though this method may not have been validated as reliable, and 
% this effect may not have much of an impact on the fft peak
do_envelope_fit=0;

% set to 1 to make extra plots for diagnostic purposes 
do_diag_plots=1;

run = getRunID(n,l,v,sfx); 

dir='fort.17/';
fend='.fort.17';
fname=[dir run fend] ;

% get the time cutoff (important for when runs go beyond df regime)
dat20=read_dat20(n,l,v,sfx);
ten=dat20(:,1);
en=dat20(:,2);
enlim=1e-1;
mindex=find(en==min(en),1,'first');
maxdex=find(en>enlim,1,'first');

mint=ten(mindex); 
maxt=ten(maxdex); 

dat=load(fname);

t=dat(:,1); 
mindex=find(t>mint,1,'first'); 
% (sloppy solution)
if ~isempty(maxt)
    maxdex=find(t<maxt,1,'last'); 
else 
    maxdex=[];
end

if ~isempty(maxdex)
    t=dat(mindex:maxdex,1);
    dat=dat(mindex:maxdex,:);
%     en=en(mindex:maxdex);
else
    t=dat(mindex:end,1);
    dat=dat(mindex:end,:);
%     en=en(mindex:end);
end

% find and remove duplicates (from restarts?)
matchdex=find(diff(t)==0);
for i =1:numel(matchdex)
    dex=matchdex(i);
    % adjust the other indices to compensate deleting entries
    matchdex=matchdex-1;
    
    t=t([1:dex-1,dex+1:end]);
%     en=en([1:dex-1,dex+1:end]);
    dat=dat([1:dex-1,dex+1:end],:);
end

% since dat(:,8) is density, which is unsigned, in order for it to be
% visible with the other signed quantities, subtract off its mean
dat(:,8)=dat(:,8)-mean(dat(:,8));

% normalize dat so they can be easily plotted
% (though this obscures which quantity is largest, it still shows which
% grows the most)
if do_norm
    for i = 1:size(dat,2)
        dat(:,i)=dat(:,i)/max(abs(dat(:,i)));
    end
end
ymax=max(max(abs(dat(:,2:end))));

% make plots
ncomp=numel(components);
yhands=zeros(ncomp,1);
fbounds=zeros(ncomp,2);
fpeaks=zeros(ncomp,1);
legstr={'','\delta B_{||}^{edge}','\delta B_{r}^{edge}','\delta B_{3}^{edge}',...
    '\delta B_{||}^{core}','\delta B_{r}^{core}','\delta B_{3}^{core}','\delta n^{core}'};
if do_plot
    fig_0=figure('units','normalized','outerposition',[0 0 1 1]);
end
iter=0;
for iy=components
    iter=iter+1;
    y=dat(:,iy);
    
    if do_interp
        t1=t(1); t2=t(end);
        tint=linspace(t1,t2,interp_sample*length(t));
        yint=interp1(t,y,tint,'spline');
    else
        tint=t;
        yint=y;
    end
    
    % label A (where to reinject commented out blocks at end)
    
    % try to fit the envelope
    if do_envelope_fit
        % fit from the energy minimum (approximate earliest time when mode
        % is growing) 
        env=abs(hilbert(yint)); 
        % this method of trying to just grab the peaks/intersection 
        % is sometimes worse than using the full
        % set of Hilbert transform points
        %fitdex=find(abs(env-abs(yint))<(1e-1)*abs(yint)); 
        fitdex=1:length(env); 
        tpeaks=tint(fitdex);
        ypeaks=yint(fitdex);
        
        % use this to determine where to start and end the fitting 
        % set these to 0 and 1 to use the full range 
        start_frac=0.05;
        end_frac=1; 
        h1=max([floor(start_frac*numel(tpeaks)) 1]); 
        h2=floor(end_frac*numel(tpeaks)); 
        htrange=intersect(find(tint>=tpeaks(h1)),find(tint<=tpeaks(h2)));
        th=tint(htrange);
        
        % this is the fitted envelope
        hfit=polyfit(tpeaks(h1:h2),log(abs(ypeaks(h1:h2))),1); 
        yenv=exp(hfit(1)*th+hfit(2)); 
        
        % see what happens if you don't impose exponential fit
        % very good at decreasing beating effects
        % but if there are beats, they are physical and we ought to keep
        % them...
        % yenv=env(htrange);
        
        % now get the envelope-normalized signal 
        % another way would just be to divide by spline-interped envelope
        % though this risks losing some physical beating?
        yh=yint(htrange)./yenv;
        
        Fsh=1/max(diff(th));
        nffth=numel(th)*100;
        Y=abs(fft(yh,nffth));
        fh=0:(Fsh/nffth):(Fsh-Fsh/nffth);
        fh=fh(2:nffth/2); % this excludes the "constant" bin, also the duplicates
        fh=2*pi*fh ; % convert to omega units
        Y=Y(1:length(fh));
        Y=Y/max(Y);
        
        if do_diag_plots
        fig_2=figure; 
        figure(fig_2);
        subplot(2,1,1);
        plotyy(tint,yint,th,yh); hold all 
        plot(tpeaks,ypeaks,'o');  
        ptemp=plot(th,yenv); 
        plot(th,-yenv,'color',get(ptemp,'color')); hold off; 
        subplot(2,1,2);
        plot(fh,Y);
        end
    end
    
    if do_plot
        figure(fig_0);
        h1=subplot(2,1,1);
        yhands(iter)=plot(tint,yint,get_sty(iy)); hold on
        if do_envelope_fit
            thissty=get_sty(iy);
            plot(tpeaks,ypeaks,[thissty(1) 'o']);
            plot(th,-1*yenv,thissty(1)); 
            plot(th,yenv,thissty(1)); 
%             plot([th ; th],[-1*ones(numel(th),1) ; ones(numel(th),1)].*[yenv ; yenv],[thissty(1)]); 
        end
        % plot(t,y,get_sty(iy),'marker','o');
        % plot(tlist,ylist,'g.'); hold off
        xlim([tint(1) tint(end)]);
        xlabel('time (t/\omega_{ci}^{-1})');
        ylabel('\delta B');
        % ylim([-1 1]);
        ylim([-ymax ymax]);
        title(['n = ' n ' , \lambda = ' lam ' , v = ' v]);
    end
    
    % label B (where to reinject commented out blocks at end)
    
    % take the FT: fit the whole signal with tint,yint
    Fs=1/max(diff(tint));
    nyq=Fs/2;
    nfft=numel(tint)*100;
    X=abs(fft(yint,nfft));
    f=0:(Fs/nfft):(Fs-Fs/nfft);
    f=f(2:nfft/2); % this excludes the "constant" bin, also the duplicates
    f=2*pi*f ; % convert to omega units
    X=X(1:length(f));
    X=X/max(X);
    
    tol=1e-8;
    % for noisy ones, make sure to take f < 1
    % as it is likely larger peaks are unphysical
    fcutoff=1;
    Xphys=X(f<fcutoff); 
    Xphys=Xphys/max(Xphys);
    fmax=mean(f(abs(Xphys-1)<tol)); % should only be exactly equal if neighboring
    if isempty(fmax) || isnan(fmax)
        error('isnan');
    end
    ylow=.05;
    if do_envelope_fit 
       Yphys=(Y(fh<fcutoff));
       fhmax=mean(fh(abs(Yphys-1)<tol)); 
       if isempty(fhmax) || isnan(fhmax) 
           error('fhmax isnan'); 
       end
       fmax=fhmax;
    end
    fpeaks(iy)=fmax;
    fdex=f(X > ylow);
    fleft=min(fdex);
    fright=max(fdex);
    
    fbounds(iter,:)=[fleft fright];
    
    if do_plot
        h2=subplot(2,1,2);
        plot(f,X,get_sty(iy)); hold on;
        if do_envelope_fit 
            thissty=get_sty(iy);
            plot(fh,Y,[thissty(1) 'o']); 
        end
        xlabel('frequency (\omega/\omega_{ci})');
        ylabel('FFT/FFT_{max}');
    end
    
    % report the peak frequency found
    % (maybe a measure of spread would be a good addition)
    if write_out
        fprintf(['w' num2str(iy) ' = %.4f \n'],fmax);
    end
    
end

fpeaks=fpeaks(components);

if write_out
    fprintf(['W  = %.4f +/- %.4f \n'],mean(fpeaks),std(fpeaks));
end

if do_plot
    subplot(2,1,1) ; hold off ;
    
    subplot(2,1,2)
    xlim([min(fbounds(:,1)) max(fbounds(:,2))]);
    h=legend(h2,yhands,legstr(components),'location','east');
    set(h,'fontsize',10);
    hold off ;
end

end
