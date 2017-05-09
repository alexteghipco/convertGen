function [outCoords] = transformCoord(inCoords,inFile,destFile,trsfMat,FSLDIR,inType,trsfType)
%This script takes a bunch of x y z coordinates you give it, and applies a
%transformation matrix to bring it to a new space using FSL's img2img.

%%inPoints = [x y z; x y z] vector of any size
%%inFile = 'String to the space you are transforming from'
%%destFile = 'String to the space you are transforming to'
%%trsfMat = 'String to the transformation matrix OR warp field'
%%spaceType = 'voxel' (keep it at this)
%%warpType = 'either warp or xfm'
%%FSLDIR = 'your directory here' OR FSLDIR = [] and it will find directory
%%where fsl lives.

%Alex Teghipco
%ateghipc@u.rochester.edu
%April 2016

%% find fsl
if isempty(FSLDIR) == 1
    FSLDIR = findFSL;
end
IMG2IMG=[FSLDIR '/bin/img2imgcoord'];
setenv('FSLOUTPUTTYPE','NIFTI_GZ');

%% set output/input type
% if strcmp(inType,'voxels') > 0
spaceArgument = ['-vox'];
% else
%     spaceArgument = ['-mm'];
end

%% find standard space
if strcmp(inFile,'MNI 2mm') == 1
    inFile = [FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz'];
end
if strcmp(inFile,'MNI 1mm') == 1
    inFile = [FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz'];
end
if srcmp(destFile,'MNI 2mm') == 1
    destFile = [FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz'];
end
if srcmp(destFile,'MNI 1mm') == 1
    destFile = [FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz'];
end

%% seperate intensity
if size(inCoords,2) == 4
    intensityMat = inCoords(:,4);
    inCoords(:,4) = [];
end

%% first, convert any inType into voxel coordinates
if strcmp(inType,'mm') == 1
    outVoxel = convertMM2Voxel_anat(anatomyFile,points,FSLDIR);
else
    outVoxel = inCoords;
end

%% Now start main loop

outCoords= zeros(size(outVoxel,1));
for i = 1:size(outVoxel,1);
    x = outVoxel(i,1);
    y = outVoxel(i,2);
    z = outVoxel(i,3);
    if strcmp(trsfType,'.mat') == 1
        convert = ['echo ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' | ' IMG2IMG ' -src ' inFile ' -dest ' destFile ' -xfm ' trsfMat ' ' spaceArgument];
        [ignore , outcord] = system(convert);
    else
        convert = ['echo ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' | ' IMG2IMG ' -src ' inFile ' -dest ' destFile ' -warp ' trsfMat ' ' spaceArgument];
        [ignore , outcord] = system(convert);
    end
    
    %digitOut = outcord(isstrprop(outcord,'digit'));
    
    %     if strcmp(inType,'voxels') == 1
    outCoords(i,:) = str2num(outcord(47:end));
    %     end
    
end

%%add to output intensity vector
if exist('intensityMat','var') == 1
    outCoords = horzcat(outCoords,intensityMat);
end

     
     
     