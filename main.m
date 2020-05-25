%%算法主体

clc,clear;
%1.读入
[fn,pn]=uigetfile('*.tif','chose image');
I=imread([pn,fn]);

%2.判断

 %2.1 预设数据
[ROW,COL]=size(I);	%获取行列值
test=zeros(ROW,COL);  %创建三个0矩阵
median_test=zeros(ROW,COL);
mean_test=zeros(ROW,COL);
 
 %2.2 均值+中值算法3x3
for r=2:ROW-1 %行中心点
  for c=2:COL-1 %列中心点
    median=[I(r-1,c-1),I(r-1,c),I(r-1,c+1);
            I(r,c-1),I(r,c),I(r,c+1);
            I(r+1,c-1),I(r+1,c+1),I(r+1,c+1)];  %3x3滤波器
    test(r,c)=I(r,c); %存中间值
    mean_test(r,c)=(I(r-1,c-1)+I(r-1,c)+I(r-1,c+1)+I(r,c-1)+I(r,c)+...
    I(r,c+1)+I(r+1,c-1)+I(r+1,c)+I(r+1,c+1))/9; %存计算均值
    sort1=sort(median,2,'descend');
    sort2=sort([sort1(1),sort1(4),sort1(7)],'descend');
    sort3=sort([sort1(2),sort1(5),sort1(8)],'descend');
    sort4=sort([sort1(3),sort1(6),sort1(9)],'descend');
    mid=sort([sort2(3),sort3(2),sort4(1)],'descend');
    median_test(r,c)=mid(2);  %存计算中值
  end
end    
%2.3 if语句判断图像。
if(test==mean_test)
   imwrite(I,strcat('均值-',fn));
else if(test==median_test)
      imwrite(I,strcat('中值-',fn));
     else
     imwrite(I,strcat('原图',fn));
     end
end
figure,plot(I);	%显示直方图
figure,imhist(I);	
