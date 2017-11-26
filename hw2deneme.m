close all; clear; clc;

images = ls('*.jpg');
%num_array = zeros(size(images,1),1);

for i = 1:size(images,1)
%     inty = 16
%     if i < inty && i > inty - 2
    img_orig = imread(images(i,:));
    figure; imshow(img_orig);
    img_gray = rgb2gray(img_orig);
    img_blur = imgaussfilt(img_gray,1);
    
    [Gxb Gyb] = imgradientxy(img_blur);
    
    [BWv,Thresv] = edge(Gxb,'Sobel',[],'vertical');
    [BWh,Thres] = edge(Gyb,'Sobel',[],'horizontal'); 
    BWh2 = BWh;
    BWh = imopen(BWh2,strel('rectangle',[1 4]));
    figure;imshow(BWh);title('horizontal');
    figure;imshow(BWv);title('vertical');
    figure;imshow((BWh+BWv)/2);title('sum');
    
    sumOfRowsGxb = zeros(1,size(Gxb,1));
    for k = 1:size(BWv,1)
        for p = 1:size(BWv,2)
            sumOfRowsGxb(1,k) = sumOfRowsGxb(1,k) + BWv(k,p);
        end
    end
    sumOfRowsGyb = zeros(1,size(Gyb,1));
    for k = 1:size(BWh,1)
        for p = 1:size(BWh,2)
            sumOfRowsGyb(1,k) = sumOfRowsGyb(1,k) + BWh(k,p);
        end
    end
    sumOfColsGyb = zeros(1,size(Gyb,2));
    for k = 1:size(BWh,2)
        for p = 1:size(BWh,1)
            sumOfColsGyb(1,k) = sumOfColsGyb(1,k) + BWh(p,k);
        end
    end
%     [pks, locs] = findpeaks(sumOfCols,'MinPeakHeight',max(sumOfCols));
    [pks, locs] = findpeaks(sumOfColsGyb);
    disp(pks);disp(locs);
    figure;imshowpair(img_gray,img_blur,'montage'); hold on;
    plot(sumOfColsGyb);
    %Finding interval
    car_candidate = zeros(2,size(pks,2));
    car_start = false;
    car_end = false;
    car_idx = 1;
    for peak = 3:size(pks,2)-2
        if(pks(1,peak)-pks(1,peak-2) > pks(1,peak)*0.2) && ~car_start 
            car_candidate(1,car_idx) = locs(1,peak);
            car_start =true;
            car_end = false;
        end
        if(pks(1,peak)-pks(1,peak+2) > pks(1,peak)*0.3) && ~car_end
            car_candidate(2,car_idx) = locs(1,peak);
            car_end = true;
            car_start = false;
            car_idx = car_idx +1;
        end
    end
    for pos = 1:size(car_candidate,2)
        if(car_candidate(1,pos)~=0 && car_candidate(2,pos)~=0)
            %if difference between end point and start point of car is too
            %small, then merge the car candidate with next one.
            if(car_candidate(2,pos) - car_candidate(1,pos)< 10 && car_candidate(2,pos+1)~=0)
               car_candidate(2,pos) = car_candidate(2,pos+1);
               car_candidate(1:end,pos+1) = 0;
            end
            
            rectangle('Position',[car_candidate(1,pos),20,car_candidate(2,pos)-car_candidate(1,pos),200],'EdgeColor','r','LineWidth',2 );
            
        end
    end
    hold off
%     fprintf('%d\n',Thres);
%     figure;imshow(BWv);
%     BWh = edge(Gyb>30,'Canny');
%     figure;imshow(BWh);
    if(i == 12) break;end
%     end
end