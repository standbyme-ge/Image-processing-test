(1):
为了测试对比度增强检测算法，使用幂定律变换

T（x）= 255(x/ 255)^γ          （11）

(2):
所提出的对比度增强检测算法可以概括如下：
1.获得图像的直方图h（x）。
2.使用（1）计算g（x）。
3.根据（3）变换到频域并获得高频量度F。
4.应用阈值测试以确定对比度增强是否发生。


%单图测试部分代码
%[fn,pn]=uigetfile('*tif');
%I=imread([pn,fn]);
%figure,subplot(2,1,1);imshow(I);
%subplot(2,1,2),imhist(I);
%imwrite(I_CE,strcat('对比度0.9-',fn));%单文件保存测试
%figure,subplot(2,1,1); imshow(I_CE);title('0.9'); 
%subplot(2,1,2),imhist(I_CE);  %显示对比增强处理后的图与直方图

clc,clear,close all

%%% 一、对比度增强处理 %%%

%1.导入图像集
FileList=dir('C:\Users\Administrator\Desktop\contrast-enhance\*tif');
[FM,FN] = size(FileList);

%2.循环体
for Fi=1:FM

%2.1 预处理

imx = strcat('C:\Users\Administrator\Desktop\contrast-enhance\',FileList(Fi).name);
I=im2double(imread(imx));
I2=I;

%2.2 对比度增强处理

X = 2;  % γ=0.6时 threshold=8.1 刚好均分。 γ=2时，threshold=9 原图多一张
I_CE2=(255*(I2/255)).^X;  %幂定律变换

imwrite(I_CE2,strcat('对比度2-',FileList(Fi).name));  %改名存储
end

%%% 二、篡改检测%%%

clc,clear,close all

%1.载图+阈值设置

FileList=dir('C:\Users\Administrator\Desktop\contrast-enhance\*tif');
[FM,FN] = size(FileList);
threshold=9; %γ=0.6时 threshold=8.1 刚好均分。 γ=2时，threshold=9 原图多一张
I_original=0;
I_enhance=0;

%2.循环体

for Fi=1:FM

imx = strcat('C:\Users\Administrator\Desktop\contrast-enhance\',FileList(Fi).name);
I=im2double(imread(imx));

%2.1 公式（1） g(x)=p(x)*h(x)

[Iy,Ix]=size(I); %为N提供图像总像素点
[h,x]=imhist(I); %获取x的直方图h(x)
[m,n]=size(h);  %获取直方图横纵向量数
p=zeros(m,n);  %p(x)预设空间
for i=1:m  %公式（2）p(x)相关的不等式
if(i<=4)  %NP宽为4个像素
    p(i)=0.5-0.5*cos((i*pi)/4);
else
    if(i>=252)
        p(i)=0.5+0.5*cos((pi*(i-252))/4);
    else
        p(i)=1;
    end
end
end
g=p.*h;  %公式（1）

%2.2 公式（3）F=（1/N）*sum(abs(BT(w)*G(w)))
N=Iy*Ix;  %N为像素总数
G=fft(g); %傅里叶变换
BT=zeros(m,n);  %β（w）属于0~1的加权函数
C=pi*7/8;  %论文给定先验值C
BT=(abs(G)>C); %公式（4）不等式
F=(1/N)*sum(abs(BT.*G));  %公式（3） 加权度量F
if(F>threshold)  %判断F与阈值大小以断定是否进行对比度增强。
    I_enhance=I_enhance+1;
else
    I_original=I_origin+1;
end
end
I_original,I_enhance

Pd=I_enhance/50  %正确分类已篡改个数
Pfa=abs(50-I_original)/50  %不正确分类未篡改个数
