%������Ҫ�������ֵ�����
im1=imread('pic/source1.jpg');
figure(1);clf;%imshow(im1);
[BW,xi,yi]=roipoly(im1);
save('source.mat','BW','xi','yi');