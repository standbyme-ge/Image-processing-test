%% ！！！不完整，应该直接使用 4.2.1 /4.2.2 后面滤波器，求近似解。以绿色通道为例：
%{
mykernel = np.array([[0, 0, -0.001, 0.001, 0.001, 0.001, -0.001, 0, 0],
                     [0, 0, 0.003, 0.005, -0.004, 0.005, 0.003, 0, 0],
                     [0, 0.003, 0.009, -0.022, -0.029, -0.022, 0.009, 0.003, 0],
                     [0, 0.005, -0.022, -0.072, 0.165, -0.072, -0.022, 0.005, 0],
                     [0, -0.004, -0.029, 0.165, 0.835, 0.165, -0.029, -0.004, 0],
                     [0, 0.005, -0.022, -0.072, 0.165, -0.072, -0.022, 0.005, 0],
                     [0, 0.003, 0.009, -0.022, -0.029, -0.022, 0.009, 0.003, 0],
                     [0, 0, 0.003, 0.005, -0.004, 0.005, 0.003, 0, 0],
                     [0, 0, -0.001, 0.001, 0.001, 0.001, -0.001, 0, 0]])
anti = cv2.filter2D(img, -1, kernel=mykernel, borderType=cv2.BORDER_CONSTANT)
%}
%然后用anti中的一半像素替换img中对应位置的像素，这样就可以得到反取证图片了
% 1.对图像进行导入
% 2.red channel
%     提取Bayer模式下yR
%     通过O,E组成Ha
%     利用kron得到H
%     通过矩阵转化得到的H+与y相乘得出x
%     x与H相乘最后得出结果
%%

clc,clear
%
[fn,pn]=uigetfile('*');
I=double(imread([pn,fn]));


I=I(1:100,1:100,:);
%  figure,imshow(uint8(I));
%% red
%define
[m,n,~]=size(I);
I_r=I(:,:,1);
y=I_r(:);

k=fix((m+1)/2);
l=fix((n+1)/2);
yR=zeros(k,l);%提取Red“真实”（即非插值）样本。
for i=1:k*l
    j=2*i+floor((i-1)/k)*(m-1)-1;   
    yR(i)=y(j);
end

%通用H,define (2v-1)*v matrices of O,E
% e.g.
%
v=n;
O=zeros(2*v-1,v);
E=zeros(2*v-1,v);
for i=1:2*v-1
    for j=1:v
        if i==2*j-1
            O(i,j)=1;
        end
        if i==2*j || i==2*j-2
            E(i,j)=1;
        end
    end
end
H_12=O+(1/2)*E;
 H=kron(H_12(1:n,1:l),H_12(1:m,1:k));
%%
%  X=H_12(1:n,1:l);
%  Y=H_12(1:m,1:k);
% X_x=X'*X;
% Y_x=Y'*Y;
% X_x2=(X_x^-1)*X';
% Y_x2=(Y_x^-1)*Y';
% H_add=kron(X_x2,Y_x2);
% x=H_add*y;
 x=(((H'*H)^-1)*H')*y;
 y1=H*x;
 y1=reshape(y1,m,n);
 figure,imshow(uint8(y1))
 
 
 

 %% green
I_g=I(:,:,2);
k_g=fix(m/2);
l_g=fix(n/2);
k_g1=fix(m/2)+1;
y=I_g(:);
for i=1:m*n+2
    if i>=1 && i<=k_g1
        j=i;
    else
        if i>k_g1 && i<=(n+1)*k_g1
            j=2*(i-k_g1)-col((i-k_g1),k_g1)+k_g1;
        else
            j=i+fix((m*n)/2);
        end
    end
%     yG(i)=y(j);
end

function cc=col(k,m)
    cc=floor((k-1)/m)+1;
end
%{ 
function vv1=vec(i,j,m)
vv1=i+m*(j-1);
end

function [vv21,vv22]=vec2(k,m)
vv21=k-m*floor((k-1)/m);
vv22=floor((k-1)/m)+1;
end
%}
