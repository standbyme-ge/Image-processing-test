(1):
为了测试对比度增强检测算法，使用幂定律变换

T（x）= 255(x/ 255)^γ          （11）

更改每个图像，并且γ值介于0.5到2.0之间。 
另外，每个图像都受到图3左上方显示的映射的影响，
该映射旨在在每个图像的最亮和最暗区域中展现细节。
然后将这些更改后的图像与原始图像集组合，以形成4092张图像的测试数据库。 
所提出的检测算法用于确定测试数据库中的每个图像是否都经过某种形式的对比度增强。
 在该模拟中，选择β（ω）为（4）中指定的形式，
其中截止参数参数c =7π/ 8。
通过分别计算:
正确分类的已更改图像的百分比
和错误分类的未更改图像的百分比，
可以确定给定阈值η的检测概率Pd和错误警报Pfa。 然后，将这些概率用于构建一系列接收器工作特性（ROC）曲线。
(2):
所提出的对比度增强检测算法可以概括如下：
1.获得图像的直方图h（x）。
2.使用（1）计算g（x）。
3.根据（3）变换到频域并获得高频量度F。
4.应用阈值测试以确定对比度增强是否发生。


%单图测试
%[fn,pn]=uigetfile('*tif');
%I=imread([pn,fn]);
%figure,subplot(2,1,1);imshow(I);
%subplot(2,1,2),imhist(I);
%imwrite(I_CE,strcat('对比度0.9-',fn));%单文件保存测试
%figure,subplot(2,1,1); imshow(I_CE);title('0.9'); 
%subplot(2,1,2),imhist(I_CE);  %显示对比增强处理后的图与直方图

clc,clear,close all

%%%对比度增强处理%%%

%1.导入图像集
FileList=dir('C:\Users\Administrator\Desktop\contrast-enhance\*tif');
[FM,FN] = size(FileList);

%2.循环体
for Fi=1:FM

%2.1 预处理

imx = strcat('C:\Users\Administrator\Desktop\contrast-enhance\',FileList(Fi).name);
I=im2double(imread(imx));
I1=I;
I2=I;

%2.2 对比度增强处理

X = 0.9;  %γ取值0.9 or 1.2
I_CE1=255*(I1/255).^X;  %幂定律变换

X = 1.2;  
I_CE2=255*(I2/255).^X;  %幂定律变换

imwrite(I_CE1,strcat('对比度0.9-',FileList(Fi).name));  %改名存储
imwrite(I_CE2,strcat('对比度1.2-',FileList(Fi).name));  %改名存储
end

%%%篡改检测%%%
