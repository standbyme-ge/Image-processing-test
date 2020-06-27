%{

1.ʹ�������㷨��ȡÿ�������������
2.ʹ�������㷨Ϊͼ�����������ֱ�ǩ
3.����ѵ��������Լ�����
4.�����ݽ������Ų�������һ������
5.������֤ѡ����Ѳ���C��gamma
6.ѵ��svmģ��
7.����ѵ������Ԥ����Լ�

ʹ��'%{ %} ��ѡ��ʹ��spam����mfr'��Ŀǰ��MFR

�Ĳ��֣�1.SVM���� 2.SPAM���� 3.MFR���� 4.�˲����ֺ���
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

%% ��������

matrix=[matrix;F];
L=med(I);
label=[label;L];
end

%% ���ݼ����
%1.train
train_matrix=matrix(1:divi,:);
train_label=label(1:divi,:);
%2.test
test_matrix=matrix(divi+1:end,:);
test_label=label(divi+1:end,:);
%% ��һ��
[Train_matrix,PS]=mapminmax(train_matrix');
Train_matrix=Train_matrix';
Test_matrix=mapminmax('apply',test_matrix',PS);
Test_matrix=Test_matrix';
%% 
%������֤-������c/g
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
%1.�鿴ѵ��Ч�� 2.�鿴����Ч��
[predict_label_1,accuracy_1,prob_estimate_1]=svmpredict(train_label,Train_matrix,model);
[predict_label_2,accuracy_2,prob_estimate_2]=svmpredict(test_label,Test_matrix,model);
result_1=[train_label predict_label_1];
result_2=[test_label predict_label_2];

%% ͼʾ

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

%% 4��ˮƽ/��ֱ����+4���ԽǾ���

%1.ˮƽ
D = I(:,1:end-1) - I(:,2:end);
L = D(:,3:end); C = D(:,2:end-1); R = D(:,1:end-2);
%M11:����M12:����
M11 = ComputerM(L,C,R,T);
M12 = ComputerM(-R,-C,-L,T);

%2.��ֱ
D = I(1:end-1,:)- I(2:end,:);
L = D(3:end,:); C = D(2:end-1,:); R = D(1:end-2,:);
M13 = ComputerM(L,C,R,T);
M14 = ComputerM(-R,-C,-L,T);

%3.��Խ�
D = I(1:end-1,1:end-1) - I(2:end,2:end);
L = D(3:end,3:end); C = D(2:end-1,2:end-1); R = D(1:end-2,1:end-2);
M21 = ComputerM(L,C,R,T);
M22 = ComputerM(-R,-C,-L,T);

%4.�ҶԽ�
D = I(2:end,1:end-1) - I(1:end-1,2:end);
L = D(1:end-2,3:end); C = D(2:end-1,2:end-1); R = D(3:end,1:end-2);
M23 = ComputerM(L,C,R,T);
M24 = ComputerM(-R,-C,-L,T);

%% ƽ������+ȡ��������F

F1 = (M11+M12+M13+M14)/4;
F2 = (M21+M22+M23+M24)/4;
F = [F1;F2];
end

function M = ComputerM(D1,D2,D3,T)

%ȥ���߽���Ԫ�ء�
D1(D1<-T)=-T; D1(D1>T)=T;
D2(D2<-T)=-T; D2(D2>T)=T;
D3(D3<-T)=-T; D3(D3>T)=T;

%��һ��
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
  
  %% 3x3��ֵ�˲���в�
  I_med = medfilt2(I,[3 3],'symmetric');
  I_mfr = I_med - I; %��в�
  
  %
  %% Z��ת��ͼ�� 
  I_mfr_z = I_mfr'; %ת�òв�
  I_mfr_d = flipud(I_mfr); %��ת�в�
  I_mfr(:,2:2:end) = I_mfr_d(:,2:2:end); %ȡ��ת�в�2�ı�����
  I_mfr_z_d = flipud(I_mfr_z); %��תת�òв�
  I_mfr_z(:,2:2:end) = I_mfr_z_d(:,2:2:end); %ȡת�õ�ת�в�2�ı�����
  
 %% ������ 
  I_mfr3=[I_mfr(:);I_mfr_z(:)]';%���������ݡ�תΪ1��
 
  %
  %I_mfr3=I_mfr(:)';%ȡ��Z�ַ�
  
 %% ����ARϵ����ȡorderά����
  aCof = arburg(I_mfr3,order); %�Իع�ģ��
   fea = aCof(2:end);
   
  %���´����ж��������Ƿ���NAN���ݣ����ΪNAN�����Ϊ0 
  nanflag=isnan(fea);
  if(sum(nanflag)~=0)
       fea=zeros(1,order);
  end    
end
%}

%% �˲����֣�����label
function L=med(img)
img2=medfilt2(img,[3 3],'symmetric');
[m,n]=size(img);
D_H=img2-img;
h0 = sum(D_H==0)/(n-1);%ÿ��ˮƽ�����
H=h0/(m*n);
saveF0=sum(H);
  if(saveF0<0.0012)
      L=1;
  else
      L=-1;
  end
end

