function [outCoords] = convertCoords(inCoords,inSpace,outSpace,inType,outType,fslDir)
%FOR CREATE NIFTI
%timeStamp = clock
%timeStamp = fix(timeStamp)
%outFile = [outputDir '/' baseName '_converted_' inSpace '_To_' outSpace '_' num2str(timeStamp(5,1)) '_' num2str(timeStamp(4,1)) '_' num2str(timeStamp(3,1)) '_' num2str(timeStamp(2,1)) '_' num2str(timeStamp(1,1))];

%First, convert any inType into mm coordinates
if size(inCoords,2) == 4
    intensityMat = inCoords(:,4);
    inCoords(:,4) = [];
end

if strcmp(inType,'voxels') == 1 && (strcmp(inSpace,'MNI 1mm') == 1 || strcmp(inSpace,'MNI 2mm') == 1)
    inMm = convertVoxel2MM_MNI(inCoords,str2double(inSpace(5:5)),fslDir);
end

if strcmp(inType,'voxels') == 1 && strcmp(inSpace,'TAL') == 1
    inMm = convertVoxel2MM_TAL(inCoords);
end

if strcmp(inType,'mm') == 1 && (strcmp(inSpace,'MNI 1mm') == 1 || strcmp(inSpace,'MNI 2mm') == 1)
    inMm = inCoords;
end

if strcmp(inType,'mm') == 1 && strcmp(inSpace,'TAL') == 1
    inMm = inCoords;
end

%Then, convert mm to mm from inType to outType
if strcmp(inSpace,'TAL') == 1 && (strcmp(outSpace,'MNI 1mm') == 1 || strcmp(outSpace,'MNI 2mm') == 1)
    outMm = convertMM_TAL2MNI(inMm);
end

if (strcmp(inSpace,'MNI 1mm') == 1 || strcmp(inSpace,'MNI 2mm') == 1) && strcmp(outSpace,'TAL') == 1
    outMm = convertMM_MNI2TAL(inMm);
end

if strcmp(inSpace,'MNI 1mm') == 1 && strcmp(outSpace,'MNI 2mm') == 1
    outMm = inMm;
end

%Finally, keep transformed coordinates either in mm space, or convert to voxels.
if strcmp(outType,'voxels') == 1 && strcmp(outSpace,'TAL') == 1
    outVoxels = convertMM2Voxel_TAL(outMm);
end

if strcmp(outType,'voxels') == 1 && strfind(outSpace,'MNI') == 1
    outVoxels = convertMM2Voxel_MNI(inCoords,str2double(outSpace(5:5)),fslDir);
end

%Now find which matrix is used for outCoords.
if exist('outVoxels','var') == 1 && exist('outMm','var') == 0
    outCoords = outVoxels;
end

if exist('outMm','var') == 1 && exist('outVoxels','var') == 0
    outCoords = outMm;
end

if exist('intensityMat','var') == 1
    outCoords = horzcat(outCoords,intensityMat);
end
