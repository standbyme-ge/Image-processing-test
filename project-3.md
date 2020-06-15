```


%1.预设置

clc,clear,close all

  %[fn,pn]=uigetfile('*.tif','chose image');
  %I=imread([pn,fn]);

FileList=dir('C:\Users\Administrator\Desktop\RStest\*tif');
[FM,FN] = size(FileList);
OR=0;RS=0;                   %预设原图和重采样图量

%2.总循环

for Fi=1:FM

imx = strcat('C:\Users\Administrator\Desktop\RStest\',FileList(Fi).name);
I=imread(imx);
[m,n]=size(I);

%2.1 预设权重α值

h=[-0.25,0.5,-0.25;0.5,0,0.5;-0.25,0.5,-0.25];
  
                             %循环版（时间复杂度过高），使用矩阵运算代替
  %e=zeros(m-2,n-2);
  %for i=2:m-1
  %    for j=2:n-1
  %        s=double([I(i-1,j-1),I(i-1,j),I(i-1,j+1);
  %            I(i,j-1),I(i,j),I(i,j+1);
  %            I(i+1,j-1),I(i+1,j),I(i+1,j+1)]);
  %        e(i-1,j-1)=double(I(i,j))-sum(sum(h.*s));
  %    end
  %end
  
                             %矩阵运算：imfilter()代替
g=imfilter(I,h);             %利用权重α滤波处理
e=double(I)-double(g);       %预测误差
  
%2.2 重采样检测

p=exp(-(abs(e).^2));         %p-map
  %imshow(I),figure,
  %imshow(p);
F_p=log(abs(fftshift(fft2(p))));       %傅里叶变换频谱
[M, N] = size(F_p); 
F_p(M/2-9:M/2+10,N/2-9:N/2+10)=0;      %除去低频区域
  %figure,imshow(F_p,[]);
F_p1=abs(fftshift(fft2(p)));     
[M, N] = size(F_p1); 
F_p1(M/2-9:M/2+10,N/2-9:N/2+10)=0;   
gamma = 2;                   %伽马变换 % 幂定理:F_p2=(255*(F_p/255)).^2;
F_p2=F_p1.^gamma;             %伽马变换就是通过改变它的对比度来实现突出数值大的点
  %figure,imshow(F_p2,[]);

F_p3=F_p2(1:M/2,N/2:end);    %取第一象限P
  %rectangle('position',[N/2,1,N/2,M/2],'edgecolor','r');       %红框标记
c=zeros(1,M/2); 
  %预设c 、0-f:f为C函数中位置、0-b:第一象限全部、b=M/2；
for k=1:M/2
c(k)=sum(abs((F_p3(1:k)).^2))*(1.0/sum(sum(abs(F_p3).^2)));     %公式（23）
end 
%2.3 检测判断
F_c=sum(c);

if(F_c>0.25)                  %经验值判断
    OR=OR+1;
else
    RS=RS+1;
end

end

```
