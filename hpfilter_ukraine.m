clc
clear all
close all

% load the data
startdate = ['01/01/1990'];
enddate = ['01/01/2019'];
f = fred
UY = fetch(f,'RGDPNAUAA666NRUG',startdate,enddate)
JY = fetch(f,'RGDPNAJPA666NRUG',startdate,enddate)
uy = log(UY.Data(:,2));
jy = log(JY.Data(:,2));
q = UY.Data(:,1);

T = size(uy,1);

% Hodrick-Prescott filter
lam = 6.75; 
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauUKGDP = A\uy;
tauJPGDP = A\jy;

% detrended GDP
uytilde = uy-tauUKGDP;
jytilde = jy-tauJPGDP;

% plot detrended GDP
dates = 1954:1/4:2019.1/4; zerovec = zeros(size(uy));
figure
title('Detrended log(real GDP) 1954Q1-2019Q1'); hold on
plot(q, uytilde,'y', q, zerovec,'k')
plot(q, jytilde,'r', q, zerovec,'k')
datetick('x', 'yyyy-qq')

% compute sd(uy), sd(jy), rho(uy), rho(jy), corr(uy,jy) (from detrended series)
uysd = std(uytilde)*100;
jysd = std(jytilde)*100;
uyrho = corrcoef(uytilde(2:T),uytilde(1:T-1)); uyrho = uyrho(1,2);
jyrho = corrcoef(uytilde(2:T),uytilde(1:T-1)); jyrho = jyrho(1,2);
corruyjy = corrcoef(uytilde(1:T),jytilde(1:T)); corruyjy = corruyjy(1,2)

disp(['Percent standard deviation of detrended log real UKGDP: ', num2str(uysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real JPGDP: ', num2str(jysd),'.']); disp(' ')
disp(['Serial correlation of detrended log real UKGDP: ', num2str(uyrho),'.']); disp(' ')
disp(['Serial correlation of detrended log real JPGDP: ', num2str(jyrho),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real UKGDP and JPGDP: ', num2str(corruyjy),'.']);