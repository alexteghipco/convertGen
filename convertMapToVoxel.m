function [outCoords] = convertMapToVoxel(maps,outputDir,fslDir)
% This will convert an input map into a text file N x 4 vector of
% coordinates, with column 1 2 and 3 corresponding to x y and z coordinates
% and the 4th column corresponding to intensity of that coordinate,

%FSL Params
FSLMEANTS=[fslDir '/bin/fslmeants'];
setenv('FSLOUTPUTTYPE','NIFTI_GZ');

for mapNum = 1:size(maps,1) %now loop over maps
    map = maps{mapNum,1};
    [mapPath,mapName,mapExt] = fileparts(map);
    outFile=[outputDir '/' mapName '_TS.txt'];
    extractTS=[FSLMEANTS ' -i ' map ' --showall --transpose -o ' outFile]; %generate timecourse for every voxel in the brain (NOT MM SPACE!!)
    system(extractTS);
    outCoords=dlmread(outFile);
end
