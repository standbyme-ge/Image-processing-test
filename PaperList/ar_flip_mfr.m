%% --->---|
%% |---<---|
%% |----->       首先z字型向量化图片，然后计算其AR系数，能得到最好效果。
function [ fea ] = ar_flip_mfr( file,order)
%   order控制自回归的阶数，fea 返回特征，特征的维数为order;
if ischar(file), 
    im = double(imread(file));
else
    im = file;
    clear file,
end
  
  mf = medfilt2(im,[3 3],'symmetric');
 mfr = (mf - im); %求残差
  im = mfr;
  
  imT = im';
  imud = flipud(im);
  im(:,2:2:end) = imud(:,2:2:end);
  %%%%%%%%%%
  imud = flipud(imT);
  imT(:,2:2:end) = imud(:,2:2:end);
  
  im = [im(:);imT(:)]';
  aCof = arburg(im,order);
   fea = aCof(2:end);
   
  %以下代码判断特征中是否有NAN数据，如果为NAN则将其变为0 
  nanflag=isnan(fea);
  if(sum(nanflag)~=0)
       fea=zeros(1,order);
  end    
end