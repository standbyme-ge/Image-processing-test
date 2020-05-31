# Image-processing-test
2020-5-25
```
压缩文件中里面有101张图片，50张原始图片，50张经过中值或均值滤波的图片， 还有一张是两者拼接出来的图片。
1）试试能不能把原始图片找出来。
2）用第一问的算法来定位拼接图片的篡改区域。
可以用任何一种语言来实现，要有算法的解释
```
%%%%%%%%%%%%%%%%%%%%%%%
大概的研究方向：图像篡改检测。
%%%%%%%%%%%%%%%%%%%%%%%
1. Yuan H D. Blind forensics of median filtering in digital images. IEEE Trans Inf Foren Sec, 2011, 6: 1335–1345
2. Chen C L, Ni J Q, Huang R B, et al. Blind median filtering detection using statistics in difference domain. In:Information Hiding. Berlin: Springer, 2012. 1–15
3. Kirchner, M., Fridrich, J.: On detection of median filtering in digital images. In:
Proceedings SPIE, Electronic Imaging, Media Forensics and Security II, vol. 7541,
pp. 1-12, (2010)
3. Cao, G., Zhao, Y., Ni, R., Yu, d., Tian, H.: Forensic detection of median filtering in digital images. In: Proceedings of the 2010 IEEE International Conference on
Multimedia and Expo (ICME), pp. 89-94, (2010)
4. Yuan, H.: Blind Forensics of Median Filtering in Digital Images. In: IEEE Transactions on Information Forensics and Security, vol. 6, no. 4, pp. 1335-1345, (2011)
```
知识储备：

矩阵运算代替for循环：

中值滤波：一种非线性平滑法。对一个滑动的窗口内的灰度值排序，用中值代替窗口中心像素值的灰度值的滤波方法.

均值滤波：一种线性滤波算法。在图像上对目标像素给一个模板，（以目标像素为中心的周围8个像素，
构成一个滤波模板，即不包括目标像素本身），再用模板中的全体像素的平均值来代替原来像素值。
```
```
plot与imhist区别：
hist是给定一堆数据，统计数据在某一值的个数。
plot是散点图，给定横/纵坐标向量，描绘点列。
```
```
sort排序函数
sort（A）：对A这个矩阵或者行列向量进行默认各列升序排列。
sort（A,dim）:dim=1 为各列，dim=2为各行升序。
sort(A,dim,'descend')是降序排序。
```
```
解决思想：
1. 因为无论是中值还是均值都对原图像进行像素灰度值进行趋中操作，所以试试判断灰度值变化范围来区分原图。
2. 使用均值或者中值原理进行判断，通过构建滤波器模仿其原理遍历全部，判断中间值是否为四周值均值，或者为周围值中值。

XXX 2.错误。原因：中值遍历会产生二次变化，对处理后的中值图像再进行中值判断时，会二次影响中心值得变化。因此失败。

```
```
1.算法实现:入读图像，收集1:x 上y的变化最大值，最小值，判断差值超出阈值，则为原图，并改名+原。

2.算法实现：（错误）
（1）了解原理代码。编写中值滤波和均值滤波代码。
（2）流程：传入图像，if（判断是否为中值滤波），else if（判断是否为均值滤波），else 原图。
```
```
 %1.读入
[fn,pn]=uigetfile('*.tif','chose image');
I=imread([pn,fn]);
figure,plot(I);	%显示直方图
figure,imhist(I);	

[ROW,COL]=size(I);	%获取行列值


%中值算法3x3
for r = 2:ROW-1	%以1x3中心为定位
   for c = 2:COL-1	%以3x1中心为定位
      median3x3 =[I(r-1,c-1) I(r-1,c) I(r-1,c+1)
         	  I(r,c-1)   I(r,c)   I(r,c+1)
         	  I(r+1,c-1) I(r+1,c) I(r+1,c+1)];	%建立3x3滤波器
         sort1 = sort(median3x3, 2, 'descend');	%各行降序
     	 sort2 = sort([sort1(1), sort1(4), sort1(7)], 'descend');	%median第一列降序
         sort3 = sort([sort1(2), sort1(5), sort1(8)], 'descend');	%第二列
         sort4 = sort([sort1(3), sort1(6), sort1(9)], 'descend');	%第三列
         mid_num = sort([sort2(3), sort3(2), sort4(1)], 'descend');	
						%取最小列的最大，中列中值，大列最小。进行降序。
        median_Img(r,c) = mid_num(2);	%取中值	
   end
end

%均值算法3x3
for r = 2:1:ROW-1
   for c = 2:1:COL-1
       Mean_Img(r,c) = (imgn(r-1, c-1) + imgn(r-1, c) + imgn(r-1, c+1) + imgn(r, c-1) + imgn(r, c) 
        + imgn(r, c+1) + imgn(r+1, c-1) + imgn(r+1, c) + imgn(r+1, c+1)) / 9;	%对滤波器内9个数求和取均值
   end
end
```
