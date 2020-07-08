% colonyIdentification.m
% Colonies identification in agar plate.
% Function 1: read colony RGB value, identify colony by color.
% Function 2: read colony pixel size, length of centroid and edge,
%             identify colony by area percentage(pixel_size/Rmax_size), 
%             cruve of C_E distance.

f4=imread('Picture1.jpeg');     % read picture file, 'f4' is in color picture format(1241x1755x3)
imshow(f4)                      % show this picture
a=rgb2gray(f4);                 % change RGB picture to gray, 'a'is in gray scale format
a_size = size(a);               % size(a), get array size
b = ones(a_size);               % ones(a_size) create an one array in a_size

for i =1:a_size(1)
    for j = 1:a_size(2)
        if a(i,j)>=0 && a(i,j)<=50
            b(i,j)=0;
        end
    end
end



B =[1 1 1 1;1 1 1 1;1 1 1 1;1 1 1 1];  %此模板的选择有待再考虑
b = imerode(b,B);

for i =1:a_size(1)
    for j = 1:a_size(2)
        if  b(i,j)==0
            a(i,j)=255;
        end
    end
end
imshow(a)

bw=edge(a,'prewitt');     %边缘检测   边缘检测结束后发现还是有一些鼓励的小点，不多它们没有形成闭合的曲线
[L,num] = bwlabel(bw);               %这里已经给每个区域标好号了，使用bwlabel的话会把鼓励的不成闭合曲线的点也算进去
%一些独立点的像素数量是比较少的，所以可以通过检测每一块区域的像素点大小来决定是不是要删除此像素块
for i= 1:num
        [r,c]=find(L==i);
        size_L = size([r,c]);
        if size_L(1,1)<30
            L(r,c)=0;
        end
end
L = logical(L);

se = strel('disk',4);   %创造一个平坦的圆盘型结构元素，其半径为2
L = imclose(L,se);    %关闭图像
[L,num1] = bwlabel(L);
L = rot90(L,3);
L = fliplr(L);
pixel = cell([num1,1]);
centre = zeros(num1,2);
size_L = size(L);
for i=1:num1

    [r,c]=find(L==i);
    pixel{i} = [r,c]; 
    hold on
    mean_pixel = mean(pixel{i});
    centre(i,:) = mean_pixel;         
    plot(mean_pixel(1,1),mean_pixel(1,2),'r*')
    size_r = size(r);
    distance = zeros(size_r);
    for j = 1:1:size_r(1)
            distance(j) = sqrt((r(j)-mean_pixel(1))^2 + (c(j)-mean_pixel(2))^2);
    end
    p=polyfit((1:size_r(1))',distance,7);
    x = (1:size_r(1))';
    y = p(1)*x.^7 + p(2)*x.^6 + p(3)*x.^5 + p(4)*x.^4 + p(5)*x.^3 + p(6)*x.^2 + p(7)*x.^1 + p(8);
              
    min_distance = min(distance);
    max_distance = max(distance);
    min_y        =  min(y);
    max_y        =  max(y);
    num_peaks    =  size(findpeaks(-y));
    if (max_distance - min_distance)<= 15 && (max_y - min_y) <= 15
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('Circle  %d',i))
    elseif num_peaks(1) == 2
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('Triangle  %d',i))
    else
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('Rectangle  %d',i))
    end

    hold off
    
    figure
    plot(x,distance,'o')
    hold on
    plot(x,y)
    hold off  
    
end


