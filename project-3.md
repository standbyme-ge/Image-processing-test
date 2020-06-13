```
clc,clear,close all
%%
[fn,pn]=uigetfile('*.tif','chose image');
I=imread([pn,fn]);
[m,n]=size(I);
%%
alpha1=[-0.25,0.5,-0.25;0.5,0,0.5;-0.25,0.5,-0.25];
e=zeros(m-2,n-2);
for i=2:m-1
    for j=2:n-1
        s=double([I(i-1,j-1),I(i-1,j),I(i-1,j+1);
            I(i,j-1),I(i,j),I(i,j+1);
            I(i+1,j-1),I(i+1,j),I(i+1,j+1)]);
        e(i-1,j-1)=double(I(i,j))-sum(sum(alpha1.*s));
    end
end
p=exp(-(abs(e).^2));
imshow(I),figure,
imshow(p);
F_p=log(abs(fftshift(fft2(p))));%除去低频区域
[M, N] = size(F_p); 
F_p(M/2-9:M/2+10,N/2-9:N/2+10)=0;
figure,imshow(F_p,[]);

gamma = 2;%伽马变换 %F_p2=(255*(F_p/255)).^2
F_p2= abs(fftshift(fft2(p)));
[M, N] = size(F_p2); 
F_p2(M/2-9:M/2+10,N/2-9:N/2+10)=0;
F_p2=F_p2.^gamma;
figure,imshow(F_p2,[]);%伽马变换就是通过改变它的对比度来实现突出数值大的点
%%
F_p3=F_p2(1:M/2,N/2:end);
rectangle('position',[N/2,1,N/2,M/2],'edgecolor','g');
c=zeros(1,M/2);
for k=1:M/2
c(k)=sum(abs((F_p3(1:k)).^2))*(1.0/sum(sum(abs(F_p3).^2)));
end 
%F=find(max(c))
figure,plot(c)
sum(c)
```
