%%
%{
本次测试实现的是：
1）通过19维特征向量实现重采样检测。
    1.导入经过不同重采样率重采样的图像
    2.进行带内核K的拉普拉斯滤波器处理
    3.进行离散型傅里叶变换
    4.设置截止频率Wc
    5.通过不同窗口大小来计算归一化能量密度
    6.输出19维的特征变量
2）svm多分类
    1.提取19维特征
    2.组成数组和对应标签
    3.分离训练集与测试集数据
    4.对数据进行缩放操作：归一化处理
    5.交叉验证选择最佳参数C与gamma
	6.训练svm模型
    7.测试训练集并预测测试集
%}
%%
clc,clear,close all

FileList=dir('C:\Users\Administrator\Desktop\research\project-6\resample-ucid\*tif');
[FM,FN] = size(FileList);


matrix=[];
%使用label 中的 1=0.6；2=0.8；3=1；4=1.2；5=1.8
label=[1*ones(1,1338),2*ones(1,1338),3*ones(1,1338),4*ones(1,1338),5*ones(1,1338)];
label=label(:);

for Fi=1:FM
imx = strcat('C:\Users\Administrator\Desktop\research\project-6\resample-ucid\',FileList(Fi).name);
I=imread(imx);

%% 19维特征
F=f_19_D(I);
%%
matrix=[matrix;F];
end

%% 数据集拆分
%1.train
MA1=matrix(1:1000,:);                 LA1=label(1:1000,:);    %0.6
MA2=matrix(1338+1:1338+1000,:);       LA2=label(1338+1:1338+1000,:);%0.8
MA3=matrix(1338*2+1:1338*2+1000,:) ;  LA3=label(1338*2+1:1338*2+1000,:);%1
MA4=matrix(1338*3+1:1338*3+1000,:) ;  LA4=label(1338*3+1:1338*3+1000,:);%1.2
MA5=matrix(1338*4+1:1338*4+1000,:) ;  LA5=label(1338*4+1:1338*4+1000,:);%1.8

train_matrix=[MA1;MA2;MA3;MA4;MA5];
train_label=[LA1;LA2;LA3;LA4;LA5];

%2.test
MB1=matrix(1001:1338,:);               LB1=label(1001:1338,:); %0.6
MB2=matrix(1001+1338:1338+1338,:);     LB2=label(1001+1338:1338+1338,:);%0.8
MB3=matrix(1001+1338*2:1338+1338*2,:); LB3=label(1001+1338*2:1338+1338*2,:);%1 
MB4=matrix(1001+1338*3:1338+1338*3,:); LB4=label(1001+1338*3:1338+1338*3,:);%1.2
MB5=matrix(1001+1338*4:1338+1338*4,:); LB5=label(1001+1338*4:1338+1338*4,:);%1.8

test_matrix=[MB1;MB2;MB3;MB4;MB5];
test_label=[LB1;LB2;LB3;LB4;LB5];
%% 归一化
[Train_matrix,PS]=mapminmax(train_matrix');
Train_matrix=Train_matrix';
Test_matrix=mapminmax('apply',test_matrix',PS);
Test_matrix=Test_matrix';
%% 
%交叉验证-网格法找c/g
%{
[c,g]=meshgrid(-4:4,-4:4);
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
cmd=['-t 2 -c 16 -g 1 -h 0 -q'];
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
plot(1:length(test_label),predict_label_2,'r+')
plot(1:length(test_label),test_label,'bo')
legend('label','predict')
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
legend('label','predict')
xlabel('test-number')
ylabel('test-category')
string={'RBF',['accuracy=',num2str(accuracy_2(1)),'%']};
title(string)
%}


%% 重采样-19维特征

function En=f_19_D(I)
k=[-1 -1 -1;-1 8 -1;-1 -1 -1];
I=filter2(k,I,'same');
F=abs(fftshift(fft2(I)));%dft频谱,log(abs())仅仅是为了现实，计算时不用
[M,~]=size(F);
Wc=fix(M/2);
s=0.05:0.05:0.95;
En=zeros(1,19);
Fsquare=F.^2;
Ed_wc=sum(Fsquare(:));%求总的能量
for i=1:19
    Ed_w=ED(F,Wc,fix(Wc*s(i)));
    En(i)=(1/(s(i)*s(i)))*Ed_w/Ed_wc;
end

function E=ED(F,Wc,wc)
Fsquare2=F(Wc-wc:Wc+wc,Wc-wc:Wc+wc).^2;
E=sum(Fsquare2(:));

end
end
