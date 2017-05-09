function [outpoints] = convertMM2Voxel_MNI(points,mmSpace,FSLDIR)
% --------------------------------------------------------
% This script uses algorithm 'img2stdcoords' to convert mm coordinates
% to voxel coordinates in FSL. This script will work with 2mm standard space only.

%   mm space is either 1 or 2
% --------------------------------------------------------
% Alex Teghipco -- ateghipc@u.rochester.edu -- 2015
% --------------------------------------------------------

% Update: 
% include functionality for applying transform for anat space, 1mm space,
% DTI space, etc.

if isempty(FSLDIR) == 1
    FSLDIR = findFSL;
end

%FSLDIR = '/Applications/fsl';
FSLIMG=[FSLDIR '/bin/img2stdcoord'];
setenv('FSLOUTPUTTYPE','NIFTI_GZ');

for i =1:size(points,1);
    x=points(i,1);
    y=points(i,2);
    z=points(i,3);
    
    disp(['Working on coord ' num2str(i) ' of ' num2str(size(points,1))]);

    if mmSpace == 1
        Comm=['echo ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' | ' FSLIMG ' -mm -img ' FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz -v -std ' FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz'];
    else
        Comm=['echo ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' | ' FSLIMG ' -mm -img ' FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz -v -std ' FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz'];
    end
  
    [status,voxel]=system(Comm);
    Key   = ':';
    Index = strfind(voxel, Key);
    Index = Index(end);
    Value = voxel(Index(1) + length(Key):end);
    Value = str2num(Value);
    outpoints(i,1) = fix(Value(1,1));
    outpoints(i,2) = fix(Value(1,2));
    outpoints(i,3) = fix(Value(1,3));
end