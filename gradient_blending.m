imA=imread('pic/source1.jpg');
maskA=load('source.mat','BW'); maskA=maskA.BW; maskA=double(maskA);
imB=imread('pic/bg.jpg');
imA=double(imA);

szA = size(imA); if(size(imA,3) == 1), szA(3) = 1; end
szB = size(imB); if(size(imB,3) == 1), szB(3) = 1; end
sz = max([szA(:) szB(:)],[],2);

% 对图像A和模板maskA进行Padding
if(szA(1) < sz(1))
    imA_pad = vertcat(imA, zeros(sz(1)-szA(1), szA(2), szA(3)));
    maskA_pad = vertcat(maskA, zeros(sz(1) - szA(1), szA(2)));
else
    imA_pad = imA;
    maskA_pad = maskA;
end
if(szA(2) < sz(2))
   imA_pad =  horzcat(imA_pad, zeros(size(imA_pad,1), sz(2) - szA(2), szA(3)));
   maskA_pad = horzcat(maskA_pad, zeros(size(imA_pad,1), sz(2) - szA(2)));
end
if(szA(3) < sz(3))
    imA_pad = repmat(imA_pad,[1 1 3]);
end

% 对图像B进行Padding
if(szB(1) < sz(1))
    imB_pad = vertcat(imB, zeros(sz(1)-szB(1), szB(2), szB(3)));
else
    imB_pad = imB;
end
if(szB(2) < sz(2))
   imB_pad =  horzcat(imB_pad, zeros(size(imB_pad,1), sz(2) - szB(2), szB(3)));
end
if(szB(3) < sz(3))
    imB_pad = repmat(imB_pad,[1 1 3]);
end

figure(1);imshow(uint8(imB_pad));
[xshift,yshift] = ginput(1);

% 获取原始图像中
maskPoints = load('source.mat', 'xi', 'yi');
xshift = (xshift - mean(maskPoints.xi));
yshift = (yshift - mean(maskPoints.yi));

% 将图像A和它的模板都进行平移
imA_pad = imtranslate(imA_pad, [xshift, yshift],'nearest');
maskA_pad = imtranslate(maskA_pad, [xshift, yshift],'nearest');

figure;imshow(uint8(imA_pad));
figure;imshow(uint8(maskA_pad)*255);

%求原图像的拉普拉斯图像
G=[0 -1 0;-1 4 -1;0 -1 0];
imA_grat=zeros(size(imA_pad));
for i=1:3
    imA_grat(:,:,i)=conv2(imA_pad(:,:,i),G,'same');
end

%imshow(imA_grat.*maskA_pad);

%标记待求解像素，tag 为标记矩阵
[r,c,v]=find(maskA_pad);
len=size(r,1);
tag=zeros(sz(1),sz(2));
for i=1:len
    tag(r(i),c(i))=i;
end
%构建拉普拉斯对应算子矩阵A
for j=1:3
    A=zeros(len,len);
    b=zeros(len,1);
    for i=1:len
        b(i)=imA_grat(r(i),c(i),j);
    end
    for i=1:len
        mid=tag(r(i),c(i));
        left=tag(r(i),c(i)-1);
        right=tag(r(i),c(i)+1);
        top=tag(r(i)-1,c(i));
        bottom=tag(r(i)+1,c(i));
        A(i,mid)=4;
        num=0;
        if left==0
            b(i)=b(i)+imB_pad(r(i),c(i)-1,j);
        else
            A(i,left)=-1;
        end
        if right==0
            b(i)=b(i)+imB_pad(r(i),c(i)+1,j);
        else
            A(i,right)=-1;
        end
        if top==0
            b(i)=b(i)+imB_pad(r(i)-1,c(i),j);
        else
            A(i,top)=-1;
        end
        if bottom==0
            b(i)=b(i)+imB_pad(r(i)+1,c(i),j);
        else
            A(i,bottom)=-1; 
        end
    end
    f=A\b;
    %回填
    for i=1:len
        imB_pad(r(i),c(i),j)=f(i);
    end  
end
figure,imshow(imB_pad);