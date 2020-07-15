%% --->---|
%% |---<---|
%% |----->       ����z����������ͼƬ��Ȼ�������ARϵ�����ܵõ����Ч����
function [ fea ] = ar_flip_mfr( file,order)
%   order�����Իع�Ľ�����fea ����������������ά��Ϊorder;
if ischar(file), 
    im = double(imread(file));
else
    im = file;
    clear file,
end
  
  mf = medfilt2(im,[3 3],'symmetric');
 mfr = (mf - im); %��в�
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
   
  %���´����ж��������Ƿ���NAN���ݣ����ΪNAN�����Ϊ0 
  nanflag=isnan(fea);
  if(sum(nanflag)~=0)
       fea=zeros(1,order);
  end    
end