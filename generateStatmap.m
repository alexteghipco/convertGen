function generateStatmap(inCoords,outSpace,outNative,outFile,FSLDIR)
%takes TAL cords, converts them to MNI space mm, then MNI space voxels (for
%appropriate resolution), then draws these points on an MNI 'skeleton'
%file. This file is binarized. You can preserve intensity values as well.

%cords is matrix of TAL coordinates. 
%outFolder is output folder for file. Can be directory that exists, or
%script will create one.
%fileName is some name for the output file.
%resolution is either 1 or 2; output file resolution.
%FSLDIR: if you leave this variable blank (i.e. []) it will search for your
%fsl directory and set it for you. Alterantively put your own path here.
%Saves maybe two minute of processing time. If you have trouble wth findFSL
%set this variable manually to your fsl root directoy.
%intesityMat is a vector of intensity values where rows correspond to voxel
%identities of rows in cords. If this is left blank then intensity values
%will not be preserved.


%need to find way to use replaceVoxelsTemplate instead for speed. Currently no way of knowing
%coordinate identity for each intensity value under the hood using spm. 


%Alex Teghipco
%ateghipc@u.rochester.edu


%h = waitbar(0,'Starting analysis...code monkeys hard at work'); 
%% seperate intensity
if size(inCoords,2) == 4
    intensityMat = inCoords(:,4);
    inCoords(:,4) = [];
end

if exist(outputDir,'dir') == 0
    mkdir(outputDir)
end

%%%%%%%%%%%%%% Set all FSL variables
h = waitbar(0.2,'Looking for your FSL path');
if isempty(FSLDIR) == 1
    FSLDIR = findFSL;
end
FSLMATHS=[FSLDIR '/bin/fslmaths'];
setenv('FSLOUTPUTTYPE','NIFTI_GZ');
%%%%%%%%%%%%%%

%addpath([pwd '/Conversions']); % add conversion path
%timeStamp = clock;
%timeStamp = fix(timeStamp);
%outFile = [outputDir '/' baseName '_generatedStatmap_' num2str(timeStamp(5,1)) '_' num2str(timeStamp(4,1)) '_' num2str(timeStamp(3,1)) '_' num2str(timeStamp(2,1)) '_' num2str(timeStamp(1,1)) '_.nii.gz'];

if strcmp(outSpace,'MNI 2mm') == 1
    templateSpace = [FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz']; 
end

if strcmp(outSpace,'MNI 1mm') == 1
    templateSpace = [FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz']; 
end

if strcmp(outSpace,'native') == 1
    templateSpace = outNative; 
end

copyfile(templateSpace,[outputDir '/template.nii.gz']);
templateFile = [outputDir '/template.nii.gz'];

% gunzip(templateFile);
% checkSize=load_untouch_nii(templateFile(1:end-3));
% x = size(checkSize.img,1);
% y = size(checkSize.img,2);
% z = size(checkSize.img,3);
% niftiData=reshape(intensityMat,[x y z]);
% outNii = make_nii(niftiData, [2 2 2]); %img is 4D matrix (xyzt)
% save_nii(outNii, outFile);

%first convert to TAL
% if mmResolution == 2 %find standard space to use
%     standardSpace = [FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz']; 
% end
% if mmResolution == 1
%     standardSpace = [FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz'];
% end
%copyfile(standardSpace,[outputDir '/template.nii.gz']);
waitbar(0.5,h,'Making copies of template and zeroing...');
makeEmpty=[FSLMATHS ' ' templateFile ' -mul 0 ' outputDir '/templateEMPTY.nii.gz']; %make copy of standard space file empty
system(makeEmpty);
% waitbar(0.8,h,'Converting coordinates to MNI...');
% MNIcords = convertMM_TAL2MNI(inCoords); %convert TAL to MNI
% waitbar(0.9,h,'Converting MNI to mm...');
% MNIcordsmm = convertMM2Voxel_MNI(MNIcords,mmResolution,FSLDIR); %convert MNI to voxels 
% MNIcordsmm = unique(MNIcordsmm,'rows'); %remove duplicate rows
% 
%now draw ... one point at a time
waitbar(0,h,'Drawing voxels now...');
for i = 1:size(inCoords,1)
    waitbar((i / (size(inCoords,1))),h,'Drawing voxels...');
    if isempty(intensityMat) ~= 1
        intensityPoint=intensityMat(i);
    else
        intensityPoint=1;
    end
    drawPoint = [FSLMATHS ' ' outputDir '/templateEMPTY.nii.gz' -add ' num2str(intensityPoint) ' -roi ' num2str(inCoords(i,1)) ' 1 ' num2str(inCoords(i,2)) ' 1 ' num2str(inCoords(i,3)) ' 1 0 1 ' outputDir '/templatePOINT.nii.gz -odt float'];
    system(drawPoint);
    addPoint = [FSLMATHS ' ' outputDir '/templateEMPTY.nii.gz -add ' outputDir '/templatePOINT.nii.gz ' outputDir '/templateEMPTY.nii.gz'];
    system(addPoint);
end

if isempty(intensityMat) == 1
    binarizeImage=[FSLMATHS ' ' outputDir '/templateEMPTY.nii.gz -bin ' outputDir '/templateEMPTY.nii.gz'];
    system(binarizeImage);
end

waitbar(1,h,'Cleanup...');
copyfile([outputDir '/templateEMPTY.nii.gz'],outFile);
delete([outputDir '/templateEMPTY.nii.gz']);
delete([outputDir '/templatePOINT.nii.gz']);
delete([outputDir '/template.nii.gz']);
close(h)