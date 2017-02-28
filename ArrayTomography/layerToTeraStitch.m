%convert


um_per_pixel = 0.1090;

numStacks = 2;

%% Generate XML

docNode = com.mathworks.xml.XMLUtils.createDocument('TeraStitcher');
domImpl = docNode.getImplementation();
doctype = domImpl.createDocumentType('TeraStitcher', 'SYSTEM', 'TeraStitcher.DTD');
docNode.appendChild(doctype);
docRootNode = docNode.getDocumentElement;
docRootNode.setAttribute('volume_format','TiledXY|2Dseries')
%%
% % add attributes to TeraStitcher node
% volume_format = docNode.createAttribute();
% volume_format.setNodeValue();
% docNode.addEventListener (volume_format);

%%
STACKS = docNode.createElement('STACKS');

docNode.getDocumentElement.appendChild(STACKS);



for iST = 1 : numStacks;
    stacks_node = docNode.createElement('stacks');
    STACKS.appendChild(stacks_node);
    
    stacks_node.setAttribute('ROW','1');
    
    %these data nodes will be appended to each stack node
    NORTH_displacements = docNode.createElement('NORTH_displacements');
    EAST_displacements = docNode.createElement('EAST_displacements');
    SOUTH_displacements = docNode.createElement('SOUTH_displacements');
    WEST_displacements = docNode.createElement('WEST_displacements');
    
    
    stacks_node.appendChild(NORTH_displacements);
    stacks_node.appendChild(EAST_displacements);
    stacks_node.appendChild(SOUTH_displacements);
    stacks_node.appendChild(WEST_displacements);
    clear stacks_node
end



%% export and view
xmlwrite('xml_import.xml',docNode);
type('xml_import.xml');
