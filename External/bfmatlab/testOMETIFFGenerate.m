function  testOMETIFFGenerate(  )
data_prep = h5read('/data/Lior/Multiscaler data/27 September 2017/FOV3_bispectral_gcamp_fitc/start_pmt1_stop1_lines_stop2_pmt2_unidir_power_15p_gain_850_850_zoom1_001.hdf5', '/Full Stack/Channel 1/');
data_prep = permute(sum(data_prep, 4), [3, 2, 1]);
data_prep = reshape(data_prep, 1024, 1024, 1, 1, 251);
data = int16(flip(data_prep, 5));
% replace path to BFMatlab Toolbox  for your own machine
addpath('/data/MatlabCode/PBLabToolkit/External/bfmatlab');

% verify that enough memory is allocated
bfCheckJavaMemory();

autoloadBioFormats = 1;

% load the Bio-Formats library into the MATLAB environment
status = bfCheckJavaPath(autoloadBioFormats);
assert(status, ['Missing Bio-Formats library. Either add loci_tools.jar '...
            'to the static Java path or add it to the Matlab path.']);

% initialize logging
loci.common.DebugTools.enableLogging('ERROR');

% this section just generates synthetic data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  sizeT = 3;
%  sizeZ = 2;
%             
%  sizeY = 1024;
%  sizeX = 1024;
%  
% % actual sizet (FLIM relative time)
% sizet = 251;
%  
% 
% data = int16(zeros(sizeX,sizeY,1,1,sizet));
% 
% 
% for t = 1:sizet
%     ii = 100 - (10 * t);
%     
%     % 0
%     z = 1;
%     data(:,:,z,1,t) = ii;
%     data(2:4,2,z,1,t) = 0;
%    
%     %1
%     z = 2;
%     data(1:5,2,z,1,t) = ii;
%     
%     %2
%     z = 3;
%     data(3:5,1,z,1,t) = ii;
%     data(1,1,z,1,t) = ii;
%     data(1:3,3,z,1,t) = ii;
%     data(5,3,z,1,t) = ii;
%     data(1:2:5,2,z,1,t) = ii;
%     
%      %3
%     z = 4;
%     data(:,:,z,1,t) = ii;
%     data(2,1:2,z,1,t) = 0;
%     data(4,1:2,z,1,t) = 0;
%     
%     
%      %4
%     z = 5;
%     data(1,1:2:3,z,1,t) = ii;
%     data(2,:,z,1,t) = ii;
%     data(3,3,z,1,t) = ii;
%     data(4,3,z,1,t) = ii;
%     data(5,3,z,1,t) = ii;
%     
% end

size(data)

% NB this line has been found to be crucial
java.lang.System.setProperty('javax.xml.transform.TransformerFactory', 'com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl');

metadata = createMinimalOMEXMLMetadata(data);


modlo = loci.formats.CoreMetadata();

modlo.moduloT.type = loci.formats.FormatTools.LIFETIME;
modlo.moduloT.unit = 'ps';
% replace with 'Gated' if appropriate
modlo.moduloT.typeDescription = 'TCSPC';
modlo.moduloT.start = 0;

%
step = 50;
modlo.moduloT.step = step;
sizet = 251;  % picoseconds
modlo.moduloT.end = (sizet -1) * step;


OMEXMLService = loci.formats.services.OMEXMLServiceImpl();

OMEXMLService.addModuloAlong(metadata,modlo,0);

% important to delete old versions before writing.
outputPath = [pwd  filesep 'output/trial_flim.ome.tiff']
if exist(outputPath, 'file') == 2
    delete(outputPath);
end
bfsave(data, outputPath, 'metadata', metadata);






end

