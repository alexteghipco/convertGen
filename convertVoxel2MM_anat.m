function [outCoords] = convertVoxel2MM_anat(inFile,inCoords,fslDir)

%points=dlmread(pointsFile);
if isempty(fslDir) == 1
    fslDir = findFSL;
end
FSLHD=[fslDir '/bin/fslhd'];
FSLCONVERTXFM=[fslDir '/bin/convert_xfm'];
setenv('FSLOUTPUTTYPE','NIFTI_GZ');

extractHD=[FSLHD ' ' inFile];
[status,textMat] = system(extractHD);
k = strfind( textMat , 'sto_xyz:1' );
k2 = strfind( textMat , 'sform_xorient' );
extractedMat=textMat(k:k2-1);
x = strfind( extractedMat , ':1' );
x2 = strfind( extractedMat , 'sto_xyz:2');
line1=(extractedMat(x+8:x2-1));
y2 = strfind( extractedMat , 'sto_xyz:3');
line2=extractedMat(x2+15:y2-1);
z=strfind( extractedMat , 'sto_xyz:4');
line3= extractedMat(y2+15:z-1);
line4= (extractedMat(z+15:end-1));
mat=[line1 line2 line3 line4];

% find which dimensions are of size 3
 dimdim = find(size(inCoords) == 3);

% 3x3 matrices are ambiguous
% default to coordinates within a row
if dimdim == [1 2]
  disp('input is an ambiguous 3 by 3 matrix')
  disp('assuming coordinates are row vectors')
  dimdim = 2;
end

% transpose if necessary
if dimdim == 2
  inCoords = inCoords';
end

% apply the transformation matrix
inCoords = [inCoords; ones(1, size(inCoords, 2))];
inCoords = mat * inCoords;

% format the outpoints, transpose if necessary
outCoords = fix(inCoords(1:3, :));
if dimdim == 2
  outCoords = outCoords';
end
