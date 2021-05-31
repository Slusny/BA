load("horse_disparity_median.mat")
count = 0;
for i=1:size(mask_z,1)
    for j=1:size(mask_z,2)
        if(mask_z(i,j) )
            count = count + 1;
        end
    end
end
disp(count)