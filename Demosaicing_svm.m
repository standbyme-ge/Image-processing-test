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