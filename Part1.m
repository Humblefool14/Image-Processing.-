sh=imread('D:\Image Processing\Eyes.jpg');
% imshow(sh)
a=sh;
%// changing the image to grey scale
se=rgb2gray(a);
%imshow(se)
se=double(se);
% Changing the image to Inverted binary image by thresholding at a value 
T=0.9;
 for i=1:480
    for j=1:640
         se(i,j)= 255-se(i,j);   
    end 
 end
% Converting the image to binary  
 for i=1:480
    for j=1:640
        se(i,j)=(se(i,j)./255);
        if(se(i,j)>= T)
            se(i,j)=1;
        end 
       if(se(i,j)< T)
             se(i,j)=0;
       end
    end
 end 
%imshow(se);


figure();
SE = strel('disk',5);
I = imerode(se,SE);
%imshow(I)
%Image after erosion

% remove all object containing fewer than 30 pixels
I = bwareaopen(I,30);
% fill a gap in the pen's cap
se = strel('disk',2);
I = imclose(I,se);
I = imfill(I,'holes');
imshow(I)

%% Finding the external boundaries           
[B,L] = bwboundaries(I,'noholes');

% Display the label matrix and draw each boundary
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

%%
stats = regionprops(L,'Area','Centroid');

threshold = 0.94;

% loop over the boundaries
for k = 1:length(B)

  % obtain (X,Y) boundary coordinates corresponding to label 'k'
  boundary = B{k};

  % compute a simple estimate of the object's perimeter
  delta_sq = diff(boundary).^2;    
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % obtain the area calculation corresponding to label 'k'
  area = stats(k).Area;
  
  % compute the roundness metric
  metric = 4*pi*area/perimeter^2;
  
  % display the results
  metric_string = sprintf('%2.2f',metric);

  % mark objects above the threshold with a black circle
  if metric > threshold
    centroid = stats(k).Centroid;
    plot(centroid(1),centroid(2),'ko');
  end
  
  text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y',...
       'FontSize',14,'FontWeight','bold');
  
end

title(['Metrics closer to 1 indicate that ',...
       'the object is approximately round']);
   
   
[centers, radii] = imfindcircles(im5, [10 15],'ObjectPolarity','bright','Sensitivity', .98);
viscircles(centers, radii);