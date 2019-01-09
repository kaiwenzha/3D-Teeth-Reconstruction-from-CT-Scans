function denoising(inputDir, outputDir, thresh)
%Image denoising by Morphology-based Smoothing
%   inputDir: input image directory  
%   outputDir: output image directory
%   thresh: the threshold for binarizing(0~255)
imgDir  = dir([inputDir '*.png']); % 遍历目录内所有png格式文件
for i = 1:length(imgDir)          
    raw = imread([inputDir imgDir(i).name]); %读取每张图片
    binary = raw; 
    binary(binary>thresh) = 255;
    binary(binary<=thresh) = 0;
    se = strel('disk', 3);
    new = imclose(binary, se);
    new = imopen(new, se);
    new(new>0) = 255;
    imwrite(uint8(new), [outputDir imgDir(i).name]);
end
end

