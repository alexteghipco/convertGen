function [outpoints] = convertMM2Voxel_TAL(points)
                                                    
% --------------------------------------------------------
% This script converts a vector with three columns 
% (i.e. 'points' with x, y, and z coordinate columns) 
% from BV SYSTEM space to Talairach space.
% This will only work if the coordinates of the vector are in
% SYS space and have been derived from already talairached data.
% 
% The SYS space in BV is analogous to MM space in FSL. 
% --------------------------------------------------------
% Alex Teghipco -- ateghipc@u.rochester.edu -- 2015

for i =1:size(points,1)
    disp(['working on ' num2str(i)])
    outpoints(i,1)=round(256+points(i,1)-128);
    outpoints(i,2)=round(256+points(i,2)-128);
    outpoints(i,3)=round(256+points(i,3)-128);
end
