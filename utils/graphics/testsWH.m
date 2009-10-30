

freq=.05:.01:.3;  %20 seconds down to 3.33 seconds period
freq=.05:.01:.2;  %20 seconds down to 5 seconds period
sigsq=(.01).^2;
fcenter=1/12.5; 
[freq,spec]=MakeSpectrum(.05,.2,.001,1/12.5,.005,2);
[T,H,Phi]=mimicspectrum(freq,spec);
%[T,H,Phi]=mimicspectrum(SpecStruct(9),20);
%freq=SpecStruct(9).freq;
%spec=SpecStruct(9).spec;
lambda=findwavelength(12,30);
c=lambda./T;
N=2000;
tf=N;
DelT=tf/(3*N);
t=0:DelT:tf;
for j=1:length(t);
    eta(j)=sum(H.*sin(2*pi./lambda.*(c.*t(j))+Phi));
end
disp(['Significant Wave Height = ' num2str(AnalyzeSWH(eta)) ]);
figure(2);
clf
subplot(411)
hist(abs(eta),30)
title('distribution of amplitudes')
subplot(412)


a=(diff(eta));
a=a./abs(a);
a=[0 diff(a) 0];
ii=(a==-2 | a==2);
jjj=1:(length(eta));
plot(jjj,eta,jjj(ii),eta(ii),'x')
subplot(413)
hold off
Nbin=40;
[N,X]=hist(abs(2*eta(ii)),Nbin);  %factor of 2 to give swh
hist(abs(2*eta(ii)),Nbin);  %factor of 2 to give swh
DelX=X(2)-X(1);
hold on
x=0:.1:10;
[h1,h2]=analyzeswh(eta);
R=(h2/1.42)^2;
plot(x,2*x/R.*exp(-x.^2/(R))*length(eta(ii))*DelX);


%figure
a=ifft(eta);
N=length(eta);
s=2*N*abs(a(1:round(N/2))).^2;
delf=1/N;
swh=4*sqrt(sum(s)*delf)



[freq_real,spec_real,swh]=testrealization(T,H,Phi);
subplot(414)
plot(freq,spec,freq_real,spec_real);



