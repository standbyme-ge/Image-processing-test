clc,clear,close all

FileList=dir('C:\Users\Administrator\Desktop\research\project-4\JPEG_tif\*tif');
[FM,FN] = size(FileList);
OR=0;JPEG=0;
%test_l=zeros(100,1); %测试是否区分正确
%tt=0;
for Fi=1:FM

imx = strcat('C:\Users\Administrator\Desktop\research\project-4\JPEG_tif\',FileList(Fi).name);
I=double(imread(imx));
[m,n]=size(I);

i=1:8:m-8;
j=1:8:n-8;
 z1=abs(I(3+i,3+j)-I(3+i,4+j)-I(4+i,3+j)+I(4+i,4+j));
 z2=abs(I(7+i,7+j)-I(7+i,8+j)-I(8+i,7+j)+I(8+i,8+j));

h1=imhist(uint8(z1));h1=h1/(m*n);
h2=imhist(uint8(z2));h2=h2/(m*n);
%plot(h1,'r');hold on
%plot(h2,'k');

k=sum(abs(h1-h2));
if(k<0.0039)                  %经验值判断
    OR=OR+1;
    %tt=tt+1;
    %test_l(tt)=1;
else
    JPEG=JPEG+1;
   % tt=tt+1;
   % test_l(tt)=0;
end
end


修改意见：
Ij = double(imread(imx));
dct_BlockbyBlock= blkproc (Ij,[8,8],'dct2(x)');
Y11 = round(dct_BlockbyBlock(2:8:end,2:8:end));
% 以下的20自己根据想观察的直方图范围设置，
[N,X] = hist(Y11(:),0:20);
figure,bar(0:20,N)
