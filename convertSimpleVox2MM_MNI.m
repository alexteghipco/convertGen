for i = 1:size(inCoords,1)
    outCoords(i,1) = ((-2*(inCoords(i,1)))+90);
    outCoords(i,2) = -1*((-2*(inCoords(i,2)))+126);
    outCoords(i,3) = -1*((-2*(inCoords(i,3)))+72);
end