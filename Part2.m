function image = rubberSheetNormalisation(img, xPosPupil, yPosPupil, rPupil , xPosIris , yPosIris , rIris , varargin )
        
    % Note that internally matrix coordinates are used
    xp = yPosPupil;
    yp = xPosPupil; 
    rp = rPupil;
    xi = yPosIris;
    yi = xPosIris;
    ri = rIris;
    angleSamples = 360
    RadiusSamples = 360;
    debug = DebugMode;
    interpolateQ = UseInterpolation;
    
    % Initialize samples 
    angles = (0:pi/angleSamples:pi-pi/angleSamples) + pi/(2*angleSamples);%avoiding infinite slope
    r = 0:1/RadiusSamples:1;
    nAngles = length(angles);
    
    % Calculate pupil points and iris points that are on the same line
    x1 = ones(size(angles))*xi;
    y1 = ones(size(angles))*yi;
    x2 = xi + 10*sin(angles);
    y2 = yi + 10*cos(angles);
    dx = x2 - x1;
    dy = y2 - y1;
    slope = dy./dx;
    intercept = yi - xi .* slope;
    
    xout = zeros(nAngles,2);
    yout = zeros(nAngles,2);
    for i = 1:nAngles
        [xout(i,:),yout(i,:)] = linecirc(slope(i),intercept(i),xp,yp,rp);
    end
       
    % Get samples on limbus boundary
    xRightIris = yi + ri * cos(angles);
    yRightIris = xi + ri * sin(angles);
    xLeftIris = yi - ri * cos(angles);
    yLeftIris = xi - ri * sin(angles);
    
    
    % Get samples in radius direction
    xrt = (1-r)' * xout(:,1)' + r' * yRightIris;
    yrt = (1-r)' * yout(:,1)' + r' * xRightIris;
    xlt = (1-r)' * xout(:,2)' + r' * yLeftIris;
    ylt = (1-r)' * yout(:,2)' + r' * xLeftIris;
    
    % Create Normalized Iris Image
    if interpolateQ
        image = uint8(reshape(interp2(double(img),[yrt(:);ylt(:)],[xrt(:);xlt(:)]),length(r), 2*length(angles))');
    else
        image = reshape(img(sub2ind(size(img),round([xrt(:);xlt(:)]),round([yrt(:);ylt(:)]))),length(r), 2*length(angles));
    end
       
    % Show all points on original input image
    if debug
        
        img = insertShape(img, 'circle', [yrt(:),xrt(:),2*ones(size(xrt(:)))],'Color','r');
        img = insertShape(img, 'circle', [ylt(:),xlt(:),2*ones(size(xrt(:)))],'Color','r');
        
        figure('name','Sample scheme of the rubber sheet normalization');
        imshow(img);
        drawnow;
        
    end
    
end