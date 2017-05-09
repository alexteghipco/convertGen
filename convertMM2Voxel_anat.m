function [outCoords] = convertMM2Voxel_anat(inFile,inCoords,fslDir)

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
%line3= str2num(extractedMat(y2+9:z-1));
line3= extractedMat(y2+15:z-1);
line4= (extractedMat(z+15:end-1));
%mat=vertcat(line1,line2,line3,line4);
mat=[line1 line2 line3 line4];
fid = fopen([inFile(1:end-7) '_sqform.txt'],'w');
fprintf(fid,mat);
fclose(fid);
copyfile([inFile(1:end-7) '_sqform.txt'],[inFile(1:end-7) '_sqform.mat']);
delete([inFile(1:end-7) '_sqform.txt']);

cmd=[FSLCONVERTXFM ' -omat ' inFile(1:end-7) '_sqform_INVT.mat -inverse ' inFile(1:end-7) '_sqform.mat']; 
system(cmd);
invtMat=dlmread([inFile(1:end-7) '_sqform_INVT.mat']);

%mat = inv(mat)';

% find which dimensions are of size 3
 dimdim = find(size(inCoords) == 3);
% if isempty(dimdim)
%   error('input must be a N by 3 or 3 by N matrix')
% end

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

% Transformation matrices, different for each software package
%mat = [0.9464 0.0034 -0.0026 -1.0680
		   %-0.0083 0.9479 -0.0580 -1.0239
           % 0.0053 0.0617  0.9010  3.1883
           % 0.0000 0.0000  0.0000  1.0000];

% apply the transformation matrix
inCoords = [inCoords; ones(1, size(inCoords, 2))];
inCoords = invtMat * inCoords;

% format the outpoints, transpose if necessary
outCoords = fix(inCoords(1:3, :));
if dimdim == 2
  outCoords = outCoords';
end






