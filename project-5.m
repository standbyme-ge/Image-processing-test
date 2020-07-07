%% 先进行中值滤波，并对中值滤波和原图进行JEPG压缩。
clc,clear;

%1.加载
FileList= dir('C:\Users\Administrator\Desktop\research\project-5\ucid_gray_tif\*tif');
[FM,FN] = size(FileList);
%2.循环体
for Fi=1:FM
imx = strcat('C:\Users\Administrator\Desktop\research\project-5\ucid_gray_tif\',FileList(Fi).name);

f=double(imread(imx));
T=dctmtx(8);
dct=@(block_struct)T*block_struct.data*T';
invdct=@(block_struct)T'*block_struct.data*T;
f_tf=blockproc(f,[8,8],dct);
qt_mtx=[16,11,10,16,24,40,51,61;...
12,12,14,19,26,58,60,55;...
14,13,16,24,40,57,69,56;...
14,17,22,29,51,87,80,62;...
18,22,37,56,68,109,103,77;...
24,35,55,64,81,104,113,92;...
49,64,78,87,103,121,120,101;...
72,92,95,98,112,100,103,99];
% quantization
f_qt=blockproc(f_tf,[8,8],@(block_struct)block_struct.data./qt_mtx);
f_qt=round(f_qt);
% restore the image
g=blockproc(f_qt,[8,8],@(block_struct)block_struct.data.*qt_mtx);
g=blockproc(g,[8,8],invdct);
%f=uint8(f);
g=uint8(g);
%imshow(f),title('original image');
%figure;
%imshow(g),title('compressed image');
%imwrite(g,'compressed_img.jpg');
imwrite(g,strcat('JPEG-',FileList(Fi).name)); %修改图名-47
end



%{

1.使用特征算法提取每张特征组成数组
2.使用区分算法为图像进行添加区分标签
3.分离训练集与测试集数据
4.对数据进行缩放操作：归一化处理
5.交叉验证选择最佳参数C与gamma
6.训练svm模型
7.测试训练集并预测测试集

使用'%{ %} 来选择使用spam或者mfr'，目前是MFR

四部分：1.SVM主体 2.SPAM函数 3.MFR函数 4.滤波区分函数
%}
clc,clear,close all
divi=1000;

FileList=dir('C:\Users\Administrator\Desktop\research\project-5\ucid_gray_tif\*tif');
[FM,FN] = size(FileList);
%                    1:1000:train-image     |    1001:FM:test-image

matrix=[];
label=[];

for Fi=1:FM
imx = strcat('C:\Users\Administrator\Desktop\research\project-5\ucid_gray_tif\',FileList(Fi).name);
I=double(imread(imx));

%% SPAM
%F=spam(I,3);
%F=F';

%% AR MODEL

F = MFR(I,10);

%% 矩阵整合

matrix=[matrix;F];
L=med(I);
label=[label;L];
end

%% 数据集拆分
%1.train
train_matrix=matrix(1:divi,:);
train_label=label(1:divi,:);
%2.test
test_matrix=matrix(divi+1:end,:);
test_label=label(divi+1:end,:);
%% 归一化
[Train_matrix,PS]=mapminmax(train_matrix');
Train_matrix=Train_matrix';
Test_matrix=mapminmax('apply',test_matrix',PS);
Test_matrix=Test_matrix';
%% 
%交叉验证-网格法找c/g
[c,g]=meshgrid(-3:4,-4:4);
[m,n]=size(c);
cg=zeros(m,n);
eps=10^(-4);
v=5;
bestc=1;
bestg=0.1;
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
clc 
%2.train-svm
model=svmtrain(train_label,Train_matrix,cmd);

%% test-svm
%1.查看训练效果 2.查看测试效果
[predict_label_1,accuracy_1,prob_estimate_1]=svmpredict(train_label,Train_matrix,model);
[predict_label_2,accuracy_2,prob_estimate_2]=svmpredict(test_label,Test_matrix,model);
result_1=[train_label predict_label_1];
result_2=[test_label predict_label_2];

%% 图示

figure
hold on
grid on
plot(1:length(test_label),predict_label_2,'ro')
plot(1:length(test_label),test_label,'b+')
legend('label','predict')
xlabel('test-number')
ylabel('test-category')
string={'RBF',['accuracy=',num2str(accuracy_2(1)),'%']};
title(string)

%% SPAM  
%{ 

function F=spam(I,T)

%% 4个水平/垂直矩阵+4个对角矩阵

%1.水平
D = I(:,1:end-1) - I(:,2:end);
L = D(:,3:end); C = D(:,2:end-1); R = D(:,1:end-2);
%M11:正向，M12:逆向
M11 = ComputerM(L,C,R,T);
M12 = ComputerM(-R,-C,-L,T);

%2.垂直
D = I(1:end-1,:)- I(2:end,:);
L = D(3:end,:); C = D(2:end-1,:); R = D(1:end-2,:);
M13 = ComputerM(L,C,R,T);
M14 = ComputerM(-R,-C,-L,T);

%3.左对角
D = I(1:end-1,1:end-1) - I(2:end,2:end);
L = D(3:end,3:end); C = D(2:end-1,2:end-1); R = D(1:end-2,1:end-2);
M21 = ComputerM(L,C,R,T);
M22 = ComputerM(-R,-C,-L,T);

%4.右对角
D = I(2:end,1:end-1) - I(1:end-1,2:end);
L = D(1:end-2,3:end); C = D(2:end-1,2:end-1); R = D(3:end,1:end-2);
M23 = ComputerM(L,C,R,T);
M24 = ComputerM(-R,-C,-L,T);

%% 平均矩阵+取特征向量F

F1 = (M11+M12+M13+M14)/4;
F2 = (M21+M22+M23+M24)/4;
F = [F1;F2];
end

function M = ComputerM(D1,D2,D3,T)

%去除边界外元素。
D1(D1<-T)=-T; D1(D1>T)=T;
D2(D2<-T)=-T; D2(D2>T)=T;
D3(D3<-T)=-T; D3(D3>T)=T;

%归一化
M = zeros(2*T+1,2*T+1,2*T+1);
for i=-T:T
    D22 = D2(D1==i);
    D32 = D3(D1==i);
    for j=-T:T
       D33 = D32(D22==j);
        for k=-T:T
            M(i+T+1,j+T+1,k+T+1) = sum(D33==k);
        end
    end
end
M = M(:)/sum(M(:));
end
%}

%% AR model MFR cofficients  |  %{

function fea = MFR( I,order)
  
  %% 3x3中值滤波求残差
  I_med = medfilt2(I,[3 3],'symmetric');
  I_mfr = I_med - I; %求残差
  
  %
  %% Z字转化图像 
  I_mfr_z = I_mfr'; %转置残差
  I_mfr_d = flipud(I_mfr); %倒转残差
  I_mfr(:,2:2:end) = I_mfr_d(:,2:2:end); %取倒转残差2的倍数列
  I_mfr_z_d = flipud(I_mfr_z); %倒转转置残差
  I_mfr_z(:,2:2:end) = I_mfr_z_d(:,2:2:end); %取转置倒转残差2的倍数列
  
 %% 向量化 
  I_mfr3=[I_mfr(:);I_mfr_z(:)]';%向量化数据。转为1行
 
  %
  %I_mfr3=I_mfr(:)';%取消Z字法
  
 %% 计算AR系数，取order维特征
  aCof = arburg(I_mfr3,order); %自回归模型
   fea = aCof(2:end);
   
  %以下代码判断特征中是否有NAN数据，如果为NAN则将其变为0 
  nanflag=isnan(fea);
  if(sum(nanflag)~=0)
       fea=zeros(1,order);
  end    
end
%}


