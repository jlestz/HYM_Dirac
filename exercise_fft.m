% this is an example to determine how FFT central value shifts
% due to a simple growing wave envelope

function fpeak=exercise_fft(w,g,nperiods)

if nargin < 1
    w=.1;
end
if nargin < 2
    g=[0, .001*w, .01*w,.1*w,.2*w,.3*w,.4*w,.5*w,.6*w,.7*w,.8*w,.9*w,w];
end

if nargin < 3
    nperiods=30;
end


T=2*pi/w;
dt=T/100;
t=0:dt:nperiods*T;
nt=numel(t);
nfft=nt*100;

Fs=1/dt;
freq=0:(Fs/nfft):(Fs -Fs/nfft);
freq=2*pi*freq;

gstr=g/w;
ng=numel(g);

ymax=1e100;
fpeak=zeros(ng,1);
phands=fpeak;

f=figure; F=figure;
for i=1:ng
    y=sin(w*t).*exp(g(i)*t);
    
    maxdex=min([find(y>ymax,1,'first') nt]);
    drange=1:maxdex;
    Y=abs(fft(y,nfft));
    Y=Y/sum(Y);
    
    % do the Hilbert transform method as a numerical check
    %     env=abs(hilbert(y));
    %     fitdex=1:length(env);
    %     tpeaks=t(fitdex);
    %     ypeaks=y(fitdex);
    %     hfit=polyfit(tpeaks,log(abs(ypeaks)),1);
    %     yenv=exp(hfit(1)*tpeaks+hfit(2));
    %     yh=ypeaks./yenv;
    %     Z=abs(fft(yh,nfft));
    %     Z=Z/max(Z);
    
    figure(f);
    s=plot(t(drange)/T,y(drange)); hold all;
    %     plot(t/T,yh,'color',get(s,'color'));
    
    figure(F);
    phands(i)=plot(freq/w,Y); hold all;
    fpeak(i)=min(freq(Y==max(Y)));
    %     plot(freq/w,Z,'color',get(phands(i),'color'));
end

legcell={};
for i=1:ng
    legcell{i}=sprintf('%1.3f w_0',gstr(i));
end

figure(f)
hold off
legend(legcell);
xlabel('Time/\tau_0');
title('y(t)=exp(\gamma t)sin(\omega_0 t)');

figure(F)
hold off
legend(legcell);

for i=1:ng
    figure(F); hold all;
    plot(fpeak(i)/w,1,'color',get(phands(i),'color'),'marker','o');
end

xlabel('Frequency/\omega_0');
title('Normalized FFT');
legend(phands,legcell);
xlim([0 2]);

q=figure;
plot(g/w,(w-fpeak)/w,'o');
xlabel('\gamma/\omega_0');
ylabel('(\omega_0 - \omega_{FFT})/\omega_0');
title('Percent Shift');
end

