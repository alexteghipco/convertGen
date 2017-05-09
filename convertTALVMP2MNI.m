function convertVMP2MNI(inVMP,inVOI,outDir,mm)

%take in either a VMP or a VOI. If VOI use template VMP to print data. If
%VMP go through non-zero voxels. 

%if you select VOI without VMP then resulting map will be binarized. If you
%select VMP intensities will be preserved. If you want to have intensity
%values preserved please select either VOI with VMP, or VMP. Selecting a
%VOI with VMP will constrain conversion only to VOI voxels. 


if isempty(inVMP) == 1
    inVMP = uipickfiles('Prompt','You need at least a VMP file to perform conversion...')';
end

inFile = BVQXfile(inVMP);

for i = 1:inFile.NrOfMaps
    map = inFile.Map(i).VMPData;
    fileName = inFile.Map(i).Name;
    
    case isempty(inVOI) == 0
    voi = BVQXfile('/cantlonUsers/ateghipc/Movies/FINALMTG/final/groupCT/TAL/individualSubs/ForBrad/Searchlight_VOI.voi');
    inMat = voi.VOI.Voxels;
    inMatSys = -1*(inMat)+128; %get intensity so convert to sys
    inMatSys_Flipped(:,1) = inMatSys(:,2) +1;
    inMatSys_Flipped(:,2) = inMatSys(:,3) +1;
    inMatSys_Flipped(:,3) = inMatSys(:,1) +1;
    
    for n = 1:size(inMatSys_Flipped)
        sysX = inMatSys_Flipped(n,1);
        sysY = inMatSys_Flipped(n,2);
        sysZ = inMatSys_Flipped(n,3);
        inMat(n,4) = map(sysX,sysY,sysZ);
    end
        
    mniMat = convertMM_TAL2MNI(inMat(:,1:3));
    mniMatFix = fix(mniMat);
    oneMMMat(:,1) = -1*(mniMatFix(:,1)) + 90;
    oneMMMat(:,2) = 126 + mniMatFix(:,2);
    oneMMMat(:,3) = mniMatFix(:,3) + 72;
    
    oneMMMat = fix(oneMMMat/2);
    
    template=load_untouch_nii('/Volumes/mahonPatientData/AlteredBrain/Tools/DTI/toolboxScripts/tractstatsScripts/2mmTemplate.nii');
    outMat = zeros(size(template.img));
    
    %ints=inMat(:,4);
    oneMMMatIntensity = horzcat(oneMMMat,inMat(:,4));
    
    for w = 1:size(oneMMMatIntensity,1)
        x = oneMMMatIntensity(w,1);
        y = oneMMMatIntensity(w,2);
        z = oneMMMatIntensity(w,3);
        %int = converted(i,4);
        [rs cs] = find(oneMMMatIntensity(:,1) == x & oneMMMatIntensity(:,2) == y & oneMMMatIntensity(:,3) == z);
        for n = 1:size(rs,1)
            toAvg = oneMMMatIntensity(rs,4);
            outMat(x,y,z) = mean(toAvg);
        end
    end
    
    niftiData=single(outMat);
    template.img=niftiData;
    save_untouch_nii(template,['/Volumes/mahonPatientData/AlteredBrain/Tools/DTI/toolboxScripts/tractstatsScripts/' fileName '_MNI']);
    clear mniMat
    clear mniMatFix
    clear oneMMMat
    clear oneMMMatIntensity
    clear inMat
    clear toAvg
    clear outMat
    clear rs
    clear cs
    clear toAvg
    clear niftiData
    clear inMatSys_Flipped
    clear inMat
    clear inMatSys
end

    
    
    
    
    
    
    %replace with this for non VMP translation
    
    
    
    
    
    %[voxelRow voxelCol voxelV] = ind2sub(size(map),find(map ~= 0)); %use
    %this when dealing with vmp directly
    %talMat = zeros(size(voxelRow,1),3);
    %intMat = zeros(size(voxelRow,1),1);
    %sysMat = zeros(size(voxelRow,1),3);
    %for n = 1:size(voxelRow,1)
%         xSys = voxelRow(n);
%         ySys = voxelCol(n);
%         zSys = voxelV(n);
%         
%         sysMat(n,1) = xSys;
%         sysMat(n,2) = ySys;
%         sysMat(n,3) = zSys;
%         
%         intMat(n,1) = map(xSys,ySys,zSys);
%     end
%     talMat = 128-sysMat;
%     talMatFlipped(:,1) = (talMat(:,3));
%     talMatFlipped(:,2) = (talMat(:,1));
%     talMatFlipped(:,3) = (talMat(:,2));
    
    mniMat = convertMM_TAL2MNI(talMatFlipped);
    mniMatFix = fix(mniMat);
    %oneMMMat = convertMM2Voxel_MNI(mniMatFix,1,'/Applications/fsl-5.0.7');
    
    %MANUAL CONVERT STANDARD SPACE
    oneMMMat(:,1) = -1*(mniMatFix(:,1)) + 90;
    oneMMMat(:,2) = 126 + mniMatFix(:,2);
    oneMMMat(:,3) = mniMatFix(:,3) + 72;
    
    %attach intensity
    oneMMMatIntensity = horzcat(oneMMMat,intMat);
    
    %load in nifti template
    template=load_untouch_nii('/Volumes/mahonPatientData/AlteredBrain/Tools/DTI/toolboxScripts/tractstatsScripts/1mmTemplate.nii');
    outMat = zeros(size(template.img));
    
    %remove identical rows
    for w = 1:size(oneMMMatIntensity,1)
        x = oneMMMatIntensity(w,1);
        y = oneMMMatIntensity(w,2);
        z = oneMMMatIntensity(w,3);
        %int = converted(i,4);
        [rs cs] = find(oneMMMatIntensity(:,1) == x & oneMMMatIntensity(:,2) == y & oneMMMatIntensity(:,3) == z);
        for n = 1:size(rs,1)
            toAvg = oneMMMatIntensity(rs,4);
            outMat(x,y,z) = mean(toAvg);
        end
    end
    
    %replace nifit data matrix intensities
    niftiData=single(outMat);
    template.img=niftiData;
    save_untouch_nii(template,['/Volumes/mahonPatientData/AlteredBrain/Tools/DTI/toolboxScripts/tractstatsScripts/PCs' fileName]);
end


for j = 1:size(allMat,1)
    if (allMat(j,1) == 125 && allMat(j,2) == 102 && allMat(j,3) == 127)
        found = j
    end
end
