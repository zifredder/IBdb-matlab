%% Preamble
% The setup: We have our data systematically organized in one directory, "myData":
%
% myData/
%     dataset.xlsx
%     dataset0
%     dataset1
%
% Where each data set is stored in a separate subfolder "dataset<id>", where <id> is a
% unique integer for each data set. The files (empty dummy files) in each subfolder are
% also systematically named:
%
% myData/dataset0/
%     ds0_data.dat
%     ds0_metadata.file
%     ds0_spiketrain.png
%     ds0_img.png
%
% myData/dataset0/confocal_stack/
%     ds0_1.jpeg
%     ds0_2.jpeg
%     ds0_3.jpeg
%
% Where "ds<id>" is a unique string identifier for a data set, composed of the prefix "ds"
% and the ID.
%
% We also have a spreadsheet file "myData/dataset.xlsx", which contains meta data of each
% data set. The code below will use these meta data to define the API requests for
% automatic data upload.

%%

% Note: For this script to work, MATLAB's current folder must be
% IBdb-matlab/examples/neuron_with_experiments/ and IBdb-matlab/ must be on MATLAB's
% search path.

% Import the meta data table
metadata = readtable("myData/dataset.xlsx", "TextType", "string");

% Full path of the "myData" directory. This will be used to compose the file paths
myDataDirFull = fullfile(cd, "myData");

nDataset = height(metadata);

if ~exist('obj', 'var') % In case this script is run repeatedly for testing
    obj = IBdb();
end

% Find the species ID of our species
speciesList = obj.species_query();
speciesId = speciesList(...
    {speciesList.scientific_name} == "Schistocerca gregaria").id;

% Find the ID of our experiment category
expCatgList = IBdb.experimentCategories_list;
expCategoryId = expCatgList.id(...
    expCatgList.value == "Intracellular Recording/Dye injection");

% Store IDs from data base responses
expIds = nan(nDataset, 1);
stackIds = nan(nDataset, 1);


% Loop through the meta data table rows
for j = 1:nDataset
    
    mdat = metadata(j, :); % Table row containing the meta data
    
    % Get data directory
    dataDir = fullfile(myDataDirFull, mdat.dataset_directory);
    
    idStr = mdat.dataset_idString; % String identifier
    
    % One could also use experiment_get_from_user_id(idStr) in order to check whether this
    % data set was already uploaded.
    
    % Compose file paths to the data files
    fnSpiketrain = fullfile(dataDir, idStr + "_spiketrain.png");
    fnData = fullfile(dataDir, idStr + "_data.dat");
    fnImg = fullfile(dataDir, idStr + "_img.png");
    fnMetadata = fullfile(dataDir, idStr + "_metadata.file");
    fnStackFiles = fullfile(dataDir, "confocal_stack", "*.jpeg");
    
    neuron_name = mdat.neuron_name;
    
    
    % Check whether a neuron with this name already exists. In this example, both data
    % sets correspond to the same neuron, so only one neuron should be created.
    neuronQueryResp = obj.neuron_query(...
        'name__icontains', neuron_name, 'species', speciesId);
    
    createNeuronTF = isempty(neuronQueryResp);
    
    if createNeuronTF
        
        % Add neuron
        dbResp_neuron = obj.neuron_post(...
            "name", neuron_name, "short_name", neuron_name, "species", speciesId, ...
            "hemisphere", mdat.morphology_hemisphere, "sex", IBdb.SEX_UNKNOWN);
        
        neuron_id = dbResp_neuron.id;
        
        
        % Add morphology data
        obj.neuron_morphology_post(neuron_id, ...
            "description", mdat.morphology_description);
        
        
        % Add neuron image
        obj.neuron_image_post(neuron_id, fnImg, ...
            "caption", idStr, "staining", IBdb.STAINING_INTRACELLULARFILL);
        
        
    else % Neuron already exists -> Use the ID from the query response
        
        % Note that the query response may contain more than 1 neuron
        assert(isscalar(neuronQueryResp), ...
            "This case needs to be handled outside this example.");
        
        neuron_id = neuronQueryResp.id;
        
    end
    
    
    % Add function entry
    
    % Checking whether a specific function entry already exists is rather tedious: One has
    % to check whether a function entry with the same parameter values already exists. For
    % simplicity, this is ignored here.
    
    obj.neuron_function_post(neuron_id, ...
        "description", mdat.function_description, ...
        "modality", mdat.function_modality, ...
        "response_class", mdat.function_response_class, ...
        "role", IBdb.FUNCTION_ROLE_UNKNOWN, ...
        "file", fnSpiketrain);
    
    
    % Add confocal stack
    dbResp_confocalStack = obj.neuron_confocal_stack_post(neuron_id, ...
        "description", idStr);
    
    confocalStack_id = dbResp_confocalStack.id;
    
    % Upload confocal stack files
    obj.neuron_confocal_stack_viewerFileUploader(...
        confocalStack_id, ...
        fnStackFiles);
    
    
    % It might be worthwile checking whether the data set has already been uploaded. In
    % this example, existing experiments with the same user_defined_id would be purged.
    
    expList = obj.experiments_query('user_defined_id', idStr);
    
    if ~isempty(expList)
        for jExp = 1:numel(expList) % May be non-scalar
            obj.experiment_delete(expList(jExp).id);
        end
    end
    
    % Create experiment
    dbResp_exp = obj.experiment_post(neuron_id, ...
        "category", expCategoryId, ...
        "user_defined_id", idStr);
    
    experiment_id = dbResp_exp.id;
    
    % Upload data files to experiment
    obj.experiment_fileUploader(experiment_id, fnData, "Main data file.");
    obj.experiment_fileUploader(experiment_id, fnMetadata, "Some meta data.");
    
    
    % Associate both neuron and experiment with DOI. It need not be checked whether the
    % DOI association already exists, because POSTing the same association multiple times
    % is allowed.
    
    obj.experiment_publication_post(experiment_id, mdat.doi);
    obj.neuron_publication_post(neuron_id, mdat.doi);
    
    
    expIds(j) = experiment_id;
    stackIds(j) = confocalStack_id;
end


% Open created neuron and experiment in browser
web(composeUrl("https://insectbraindb.org", "app", IBdb.NEURON, neuron_id));
for k = 1:nDataset
    web(composeUrl("https://insectbraindb.org", "app", "experiments", expIds(k)));
end

keyboard; % Pause this script; inspect the created data with the web interface

% Remove the test data from the data base. Note that a neuron cannot be deleted if there
% is data associated with it, such as experiments and confocal stacks.

for k = 1:nDataset
    obj.neuron_confocal_stack_delete(stackIds(k));
    obj.experiment_delete(expIds(k));
end

obj.neuron_delete(neuron_id);
