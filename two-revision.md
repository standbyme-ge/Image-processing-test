```
二次改进步骤：
1.循环体加载文件
2.副本进行二次中值滤波
3.变精度原-副本做差，统计未变化位置个数
4.统计每张图做差0比率。
5.通过判断大于未变化率0.55。可初步认为51张图为中值滤波处理图像。
```


```
%改进2次

clc,clear;
close all

%1.加载
FileList= dir('C:\Users\Administrator\Desktop\fil - 副本\*tif');
[FM,FN] = size(FileList);
TF = zeros(1,FM);%记录0比例率

%2.循环体
for Fi=2:FM %第一张图明显为篡改图。从2开始
imx = strcat('C:\Users\Administrator\Desktop\fil - 副本\',FileList(Fi).name);
I=imread(imx);
%2.1 预设数据
[ROW,COL]=size(I);	%获取行列值
test_double=I;  %中值滤波图预设

%二次中值滤波，个人感觉也可使用matlab中值滤波medfilt2()。

%2.2 中值算法3x3
for r=2:ROW-1 %行中心点
  for c=2:COL-1 %列中心点
    median=[test_double(r-1,c-1),test_double(r-1,c),test_double(r-1,c+1);
            test_double(r,c-1),test_double(r,c),test_double(r,c+1);
            test_double(r+1,c-1),test_double(r+1,c+1),test_double(r+1,c+1)];  %3x3滤波器
    sort1=sort(median,2,'descend');
    sort2=sort([sort1(1),sort1(4),sort1(7)],'descend');
    sort3=sort([sort1(2),sort1(5),sort1(8)],'descend');
    sort4=sort([sort1(3),sort1(6),sort1(9)],'descend');
    mid=sort([sort2(3),sort3(2),sort4(1)],'descend');
    test_double(r,c)=mid(2);  %中值处理
  end
end
%二次循环体
for r=2:ROW-1 %行中心点
  for c=2:COL-1 %列中心点
    median=[test_double(r-1,c-1),test_double(r-1,c),test_double(r-1,c+1);
            test_double(r,c-1),test_double(r,c),test_double(r,c+1);
            test_double(r+1,c-1),test_double(r+1,c+1),test_double(r+1,c+1)];  %3x3滤波器
    sort1=sort(median,2,'descend');
    sort2=sort([sort1(1),sort1(4),sort1(7)],'descend');
    sort3=sort([sort1(2),sort1(5),sort1(8)],'descend');
    sort4=sort([sort1(3),sort1(6),sort1(9)],'descend');
    mid=sort([sort2(3),sort3(2),sort4(1)],'descend');
    test_double(r,c)=mid(2);  %中值处理
  end
end

%2.3 做差
sub=zeros(ROW,COL);
sub=double(I)-double(test_double);  %变化值可大可小，图矩阵做差需变换精度
sum_rate_zeros=length(find(sub==0))/(ROW*COL);%求未变化位置所占比例
TF(Fi)=sum_rate_zeros;
end

%3.判断中值图像个数
original=0;
for i=2:FM
   if(TF(i)>0.55)   %0.5 为59,0.51为58,0.55为51
       original=original+1;
       imwrite(imx,strcat('篡改-',FileList(Fi).name)); %修改图名
   end
end
```
