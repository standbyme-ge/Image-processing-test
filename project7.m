%{
常用的CMOS图像传感器没有表达颜色的功能，只能输出亮度值，所以图片都是黑白的。

通常在黑白传感器前面添加按照Bayer模式排列的色彩滤波矩阵，
使得每个像素点能够获取RBG中的一个色彩值，由于损失另外两个色彩，所以得到的是一幅马赛克图像。

通过色彩插值的方法利用每个像素点周围的色彩值来预估损失的两个色彩值，就可以得到全彩色图像。

1.什么是Demosaic

Demosaic就是一种利用每个像素点周围的色彩值来预估另外两个色彩值的处理方法。

论文中：对原始图像应用Demosaic算法来估计每个颜色分量的像素值。

2.相机中为什么会有demosaic

由于相机传感器成本昂贵，使用三个传感器获取全部的RBG值成本高昂，所以一般就使用单个传感器，生成单通道图像，就需要
Demosaic来恢复全彩色图像。因此没有Demosaic就会得到马赛克一般的或者单色的图像。

3.demosaic对像素进行了怎样的处理？

双线性法，已知（3,3）位置为R值，则B值就等于3x3范围4个B值相加取均值，G值同样取3x3范围4个G值合取均值。从而使得改点
恢复RGB色彩。

论文中：丢失的颜色值由相邻像素加权线性组合确定。先使用高通滤波除去低频，再通过假设每个位置上的方差，如（3,3）位置方
差等于5x5范围水平与垂直方向4个位置方差均值加上1/2的（3,3）范围4个对角方差值，最后减去3倍的（3,3）的方差值来得到图
像传感器中与原图绿色对应位置的点经过高通算子处理找到假设的方差。

%}
%%
%1.导入数据
%2.进行滤波处理去低频
%3.通过求卷积后对角线的平均值代替方差
%4.进行DFT处理求得特征s
%5.导入SVM训练

%%
clc,clear,close all

FileList=dir('E:\research\project-7\svm\*jpg');
[FM,FN] = size(FileList);


matrix=[];
label=[1*ones(1,1200),2*ones(1,800)];%1200-CG,800-PIM
label=label(:);

for Fi=1:FM
imx = strcat('E:\research\project-7\svm\',FileList(Fi).name);
I=imread(imx);

%% 19维特征
F=Demo(I);
%%
matrix=[matrix;F];
end

%% 数据集拆分
%1.train
MA1=matrix(1:1000,:);                 LA1=label(1:1000,:);    %1000-CG
MA2=matrix(1201:1800,:);               LA2=label(1201:1800,:);%600-PIM

train_matrix=[MA1;MA2];
train_label=[LA1;LA2];

%2.test
MB1=matrix(1001:1200,:);               LB1=label(1001:1200); %200-CG
MB2=matrix(1801:2000,:);                LB2=label(1801:2000,:);%200-PIM

test_matrix=[MB1;MB2];
test_label=[LB1;LB2];
%% 归一化
[Train_matrix,PS]=mapminmax(train_matrix');
Train_matrix=Train_matrix';
Test_matrix=mapminmax('apply',test_matrix',PS);
Test_matrix=Test_matrix';
%% 
%交叉验证-网格法找c/g
%{
[c,g]=meshgrid(-10:0.2:10,-10:0.2:10);
[m,n]=size(c);
cg=zeros(m,n);
eps=10^(-4);
v=5;
bestc=1;
bestg=1;
bestacc=0;
for i=1:m
    for j=1:n
        cmd=['-t 2',' -v ',num2str(v),' -c ',num2str(2^c(i,j)),' -g ',num2str(2^g(i,j)),' -h 0',' -q'];
        cg(i,j)=svmtrain(train_label,Train_matrix,cmd);
        if cg(i,j)>bestacc
            bestacc=cg(i,j);
            bestc=10^c(i,j);
            beatg=2^g(i,j);
        end
        if abs(cg(i,j)-bestacc)<=eps && bestc>2^c(i,j)
            bestacc=cg(i,j);
            bestc=2^c(i,j);
            beatg=2^g(i,j);
        end
    end
end
cmd=['-t 2',' -c ',num2str(bestc),' -g ',num2str(bestg),' -h 0'];
%}
cmd=['-t 2 -c 891.4438 -g 1 -h 0'];
%2.train-svm
model=svmtrain(train_label,Train_matrix,cmd);

%%test-svm
%1.查看训练效果 2.查看测试效果
[predict_label_1,accuracy_1,prob_estimate_1]=svmpredict(train_label,Train_matrix,model);
[predict_label_2,accuracy_2,prob_estimate_2]=svmpredict(test_label,Test_matrix,model);
result_1=[train_label predict_label_1];
result_2=[test_label predict_label_2];

%% 图示
%{1
figure
hold on
grid on
plot(1:length(train_label),predict_label_1,'r+')
plot(1:length(train_label),train_label,'bo')
legend('predict','label')
xlabel('train-number')
ylabel('train-category')
string={'RBF',['accuracy=',num2str(accuracy_1(1)),'%']};
title(string)
%

figure
hold on
grid on
plot(1:length(test_label),predict_label_2,'r+')
plot(1:length(test_label),test_label,'bo')
legend('predict','label')
xlabel('test-number')
ylabel('test-category')
string={'RBF',['accuracy=',num2str(accuracy_2(1)),'%']};
title(string)
%}


function s=Demo(I)
% figure,
% subplot(2,2,1),imshow(I);
I=I(:,:,2);
h=[0 1 0;1 -4 1; 0 1 0]; %HP
%I1=filter2(h,I,'same');%滤波图像
% subplot(2,2,2),imshow(I1,[]);
[x,y]=size(I);
n=length(-x+1:y-1);
I2=imfilter(I,h,'same','conv');%卷积
for d=0:n-1
    m(d+1)=sum(abs(diag(I2,d-x+1)))/length(diag(I2,d-x+1));%对角线的绝对值的平均值
end
% subplot(2,2,3),plot(m);
F=abs(fft2(m));
L=length(F);
s=F(round(L/2))/median(F(2:end));
% figure,
% subplot(2,2,4),plot((0:length(F)-1)/length(F),log(F))
end
