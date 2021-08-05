classdef IBdb < handle
    %IBdb API request handler for insectbrainDB.org
    % For details, see README.md
    %
    %
    %   obj = IBdb();
    %   obj = IBdb(tokenAuthString);
    %   obj = IBdb(credentialsFilename);
    %
    %
    %
    %
    %
    % Author:
    % Frederick Zittrell (2021)
    
    
    

    properties
        
        % File name pointing to the local file with the database user credentials.
        credentialsFilename (1,1) string
        
        % Stores the authentication token string.
        tokenAuth (1,1) string
        
        % Stores the authentication token time stamp. This is possibly relevant because
        % tokens have an expiration time (currently 24 h).
        tokenTimeStamp (1,1) datetime
        
        
        default_experimenter (1,1) string
        
        default_reconstructionCreator (1,1) string
        
        default_groupHead (1,1) string
        
        default_species {IBdb.mustBeEmpytOrScalarInteger}
        
        
        % WEBOPTIONS used for WEBWRITE and WEBREAD calls. Defines request parameters such
        % as request method and headers, incl. authentication.
        webopts (1,1) weboptions
        
    end
    
    properties (SetAccess = immutable)
        
        % Indicating whether there is a Python installation that can be used to state
        % requests
        hasPy = false
        
    end

    properties (Constant)
        
        api = "https://insectbraindb.org/api/v2/"
        
        
        %% Enumeration-like strings for URLs
        % These are parts of endpoints and are supposed to be used to compose the URL for
        % requests. Use composeUrl() for this.
        
        TOKEN = "token"

        NEURON = "neuron"
        
        FUNCTION = "function"
        FUNCTIONS = "functions"

        NEURON_RECONSTRUCTION = "neuron-reconstruction"

        BRAIN_STRUCTURE = "brain-structure"

        SPECIES_RECONSTRUCTION = "species-reconstruction"

        SPECIES = "species"
        
        EXPERIMENT = "experiment"
        
        CATEGORY = "category"
        
        FILE = "file"
        FILES = "files"
        
        MORPHOLOGY = "morphology"
        
        GROUP = "group"
        
        PUBLICATION = "publication"
        
        ARBORIZATION_REGION = "arborization_region"
        ARBORIZATION_REGIONS = "arborization_regions"
        
        SUPERTYPE = "supertype"
        FAMILY = "family"
        CLASS = "class"
        
        
        
        %% Enumeration-like strings that correspond to database enumerations
        % Properties named validate*Enums are supposed to be used in validation functions
        % for the respective enumerations.
        
        SEX_MALE = "MALE"
        SEX_FEMALE = "FEMALE"
        SEX_UNKNOWN = "UNKNOWN"
        validEnums_SEX = [
            IBdb.SEX_UNKNOWN
            IBdb.SEX_FEMALE
            IBdb.SEX_MALE
            ]

        HEMISPHERE_LEFT = "LEFT"
        HEMISPHERE_RIGHT = "RIGHT"
        HEMISPHERE_UNPAIRED = "UNPAIRED"
        validEnums_HEMISPHERE = [
            IBdb.HEMISPHERE_LEFT
            IBdb.HEMISPHERE_RIGHT
            IBdb.HEMISPHERE_UNPAIRED
            ]
        
        STAINING_INTRACELLULARFILL = "Intracellular Fill"
        STAINING_EXTRACELLULARFILL = "Extracellular Fill"
        STAINING_GOLGI = "Golgi Stain"
        STAINING_GENETICALLYLABELED = "Genetically Labeled Neuron"
        STAINING_IMMUNOSTAINED = "Immunostained Neuron"
        validEnums_STAINING = [
            IBdb.STAINING_INTRACELLULARFILL
            IBdb.STAINING_EXTRACELLULARFILL
            IBdb.STAINING_GOLGI
            IBdb.STAINING_GENETICALLYLABELED
            IBdb.STAINING_IMMUNOSTAINED
            ]
        
        FUNCTION_RESPONSE_CLASS_SENSORY = "SENSORY"
        FUNCTION_RESPONSE_CLASS_MOTOR = "MOTOR"
        FUNCTION_RESPONSE_CLASS_UNKNOWN = "UNKNOWN"
        validEnums_FUNCTION_RESPONSE_CLASS = [
            IBdb.FUNCTION_RESPONSE_CLASS_SENSORY
            IBdb.FUNCTION_RESPONSE_CLASS_MOTOR
            IBdb.FUNCTION_RESPONSE_CLASS_UNKNOWN
            ]
        
        FUNCTION_MODALITY_UNKNOWN = "UNKNOWN"
        FUNCTION_MODALITY_NONE = "NONE"
        FUNCTION_MODALITY_VISUAL = "VISUAL"
        FUNCTION_MODALITY_MECHANOSENSORY = "MECHANOSENSORY"
        FUNCTION_MODALITY_OLFACTORY = "OLFACTORY"
        FUNCTION_MODALITY_CHEMOSENSORY = "CHEMOSENSORY"
        FUNCTION_MODALITY_AUDITORY = "AUDITORY"
        FUNCTION_MODALITY_MULTIMODAL = "MULTIMODAL"
        validEnums_FUNCTION_MODALITY = [
            IBdb.FUNCTION_MODALITY_NONE
            IBdb.FUNCTION_MODALITY_UNKNOWN
            IBdb.FUNCTION_MODALITY_VISUAL
            IBdb.FUNCTION_MODALITY_OLFACTORY
            IBdb.FUNCTION_MODALITY_MECHANOSENSORY
            IBdb.FUNCTION_MODALITY_CHEMOSENSORY
            IBdb.FUNCTION_MODALITY_AUDITORY
            IBdb.FUNCTION_MODALITY_MULTIMODAL
            ]
        
        FUNCTION_ROLE_UNKNOWN = "UNKNOWN"
        FUNCTION_ROLE_INHIBITORY = "INHIBITORY"
        FUNCTION_ROLE_EXCITATORY = "EXCITATORY"
        validEnums_FUNCTION_ROLE = [
            IBdb.FUNCTION_ROLE_UNKNOWN
            IBdb.FUNCTION_ROLE_INHIBITORY
            IBdb.FUNCTION_ROLE_EXCITATORY
            ]
        
        ARBORIZATION_FIELDSIZE_UNKNOWN = "UNKNOWN";
        ARBORIZATION_FIELDSIZE_SMALL = "SMALL";
        ARBORIZATION_FIELDSIZE_WIDE = "WIDE";
        validEnums_ARBORIZATION_FIELDSIZE = [
            IBdb.ARBORIZATION_FIELDSIZE_UNKNOWN
            IBdb.ARBORIZATION_FIELDSIZE_SMALL
            IBdb.ARBORIZATION_FIELDSIZE_WIDE
            ]
        
        ARBORIZATION_DIRECTION_NOT_DEFINED = "NOT_DEFINED";
        ARBORIZATION_DIRECTION_MIXED = "MIXED";
        ARBORIZATION_DIRECTION_INPUT = "INPUT";
        ARBORIZATION_DIRECTION_OUTPUT = "OUTPUT";
        validEnums_ARBORIZATION_DIRECTION = [
            IBdb.ARBORIZATION_DIRECTION_NOT_DEFINED
            IBdb.ARBORIZATION_DIRECTION_MIXED
            IBdb.ARBORIZATION_DIRECTION_INPUT
            IBdb.ARBORIZATION_DIRECTION_OUTPUT
            ]
        
        BRAINSTRUCTURE_TYPE_SUBREGION = "subregion"
        BRAINSTRUCTURE_TYPE_SUPERCATEGORY = "supercategory"
        BRAINSTRUCTURE_TYPE_NEUROPIL = "neuropil"
        validEnums_BRAINSTRUCTURE_TYPE = [
            IBdb.BRAINSTRUCTURE_TYPE_SUBREGION
            IBdb.BRAINSTRUCTURE_TYPE_SUPERCATEGORY
            IBdb.BRAINSTRUCTURE_TYPE_NEUROPIL
            ]
        
        
        %%
        
        % Date format for date specifications.
        dateFormatSpec = "yyyy-MM-dd" % 2020-01-30

    end

    properties (GetAccess = protected)
        dbUsername % Login credentials: user name
        dbPassword % Login credentials: password
    end

    methods
        %% Constructor
        function self = IBdb(tokenAuthStr_or_filename)
            
            arguments
                tokenAuthStr_or_filename (1,1) string = ""
            end
            
            self.hasPy = IBdb.checkForPython();
            
            if nargin > 0 && ~isempty(tokenAuthStr_or_filename)
                
                if isfile(tokenAuthStr_or_filename)
                    
                    self.credentialsFilename = tokenAuthStr_or_filename;
                    self.token_create;
                    
                else
                    
                    self.tokenAuth = tokenAuthStr_or_filename;
                    
                end
                
            else
                
                self.token_create();
                
            end
            
        end

        
        %% api communication wrappers for http requests
        
        
        function [resp, respPy] = request(self, method, url, key, value)
            %request State an HTTP request.
            % This is an abstract wrapper for different request functions. Which one is
            % used depends on whether Python is available and the METHOD. Developer's
            % note: Use this function in specific request functions.
            %
            %   [resp, respPy] = obj.request(method, url, key1, value1, keyN, valueN);
            %
            % Input:
            %
            % method -- Request method; one out of ["post","get","put","patch","delete"]
            % Scalar string
            %
            % url -- Request URL
            % Scalar string
            % This URL is appended to the API's URL
            %
            % key, value -- Request parameter key/value pairs
            %
            %
            % Output:
            %
            % resp -- Server response
            % struct
            % May be empty if the server's response is empty.
            %
            % respPy -- Server response as retrieved from Python's REQUESTS package
            % struct
            % May be empty if the server's response is empty. Is always empty if Python is
            % not installed. This is useful for debugging.
            %
            arguments
                self
                
                method (1,1) string ...
                    {mustBeMember(method, ["post","get","put","patch","delete"])}
                
                url (1,1) string
            end
            
            arguments (Repeating)
                key
                value
            end
            
            
            % Compose parameters
            query = [key; value];
            query = query(:);
            
            
            
            if self.hasPy
                
                [resp, respPy] = self.pyRequest(method, url, query{:});
                
            else
                
                respPy = [];
                
                if method == "get"
                    
                    resp = self.webreadApi(url, self.webopts, query{:});
                    
                else
                    
                    opts = self.webopts;
                    opts.RequestMethod = method;
                    
                    resp = self.webwriteApi(url, opts, query{:});
                    
                end
                
            end
            
        end
        

        function resp = webreadApi(self, url, options, key, value)
            %webreadApi Wrapper for WEBREAD
            % 
            %
            %   resp = obj.webreadApi(url, options, key, value)
            
            
            arguments
                self
                url (1,1) string
                options (1,1) weboptions = self.webopts
            end
            
            arguments (Repeating)
                key
                value
            end
            
            
            % Pack into array (cell) with alternating name and value input.
            query = [key; value];
            query = query(:);
            
            
            resp = webread(composeUrl(self.api, url), query{:}, options);
            
        end


        function resp = webwriteApi(self, url, options, key, value)
            %webwriteApi Wrapper for WEBWRITE
            %
            %
            %   resp = obj.webwriteApi(url, options, key, value)
            
            arguments
                self
                url (1,1) string
                options (1,1) weboptions = self.webopts
            end
            
            arguments (Repeating)
                key
                value
            end
            
            
            query = [key; value];
            query = query(:);
            
            
            resp = webwrite(composeUrl(self.api, url), query{:}, options);
            
        end
        
        
        
        function [resp, respPy] = pyRequest(self, method, url, key, value)
            %pyRequest Uses Python's REQUESTS package to send API requests.
            % This is advantageous compared to WEBREAD and WEBWRITE because the server
            % response is more detailed and the requests are easier to debug. The
            % tokenAuth string is taken from the WEBOPTS property for authentication.
            % "file" and "files" are special keys whose values are expected to be a file
            % name (incl. path). If provided, the specified file is uploaded.
            %
            %   resp = obj.pyRequest(method, url, key1, value1, keyN, valueN)
            %
            % Example:
            %
            %   resp = obj.pyRequest('get', 'neuron/123');
            
            arguments
                self
                
                method (1,1) string ...
                    {mustBeMember(method, ["post","get","put","patch","delete"])}
                
                url (1,1) string
            end
            
            arguments (Repeating)
                key (1,1) string
                value
            end
            
            
            url = composeUrl(self.api, url);
            
            % Make doubles that represent integers actual integers. Else, the request may
            % fail because 42.0 instead of 42 is passed by Python. This is rather
            % UNPLEASANT. Doing the integer check like this is advised by MATLAB (doc
            % isinteger).
            for iV = 1:numel(value)
                
                v = value{iV};
                
                if isnumeric(v) && all(round(v) == v)
                    value{iV} = int64(v);
                end
            end
            
            
            
            % Catch file upload parameter
            uploadFileKeyTF = contains(lower(string(key)), ["file", "files"]);
            
            assert(nnz(uploadFileKeyTF) <= 1, "IBDB:pyRequest:MultipleFileKeysProvided", ...
                "For file upload, specify either ""file"" or ""files"", not both.");
            
            uploadFileTF = any(uploadFileKeyTF);
            
            if uploadFileTF
                
                fullFileName = string(value(uploadFileKeyTF));
                
                % Remove from query
                key(uploadFileKeyTF) = [];
                value(uploadFileKeyTF) = [];
                
                
                assert(isscalar(fullFileName), "Upload of multiple files not implemented.");
                % Probably just implement a loop for the py.dict?
                
                [~, fn, ext] = fileparts(fullFileName);
                fnExt = append(fn, ext);
                
                
                files = py.dict(...
                    pyargs('file', {fnExt, py.open(fullFileName, 'rb')} ));
                
                
            else
                
                files = "";
            end
            
            
            
            
            % Compose query parameters
            query = [key; value];
            query = query(:);
            
            if ~isempty(query)
                payload = py.dict(pyargs(query{:}));
            else
                payload = "";
            end
            
            % Get authentication token from WEBOPTS header
            if ~isempty(self.webopts.HeaderFields)
                headers = py.dict(pyargs(self.webopts.HeaderFields{:}));
            else
                headers = "";
            end
            
            
            switch method
                case "get"
                    payloadArgname = 'params'; % For queries
                    
                otherwise
                    payloadArgname = 'data';
            end
            
            respPy = py.requests.request(method, url, ...
                pyargs('headers', headers, payloadArgname, payload, 'files', files));
            
            
            % Throw exception if the request was unsuccesful
            try
                respPy.raise_for_status;
                
            catch ME
                
                % Add details from the response
                causeME = MException(...
                    "IBDB:pyRequest:HTTPError", ...
                    string(respPy.text));
                
                ME = addCause(ME, causeME);
                ME.rethrow;
            end
            
            
            if py.len(respPy.content) > 0
                
                % Convert response to MATLAB data types
                resp = py2mat(respPy.json);
                
            else
                resp = [];
            end
            
        end
        



        %%

        function [n, p] = getLoginCredentials(self)
            %getLoginCredentials Handles getting data base login credentials.
            % First asks for a file that stores the credentials. If none provided, the
            % user is asked to type in the credentials. If aborted, no login is attempted.

            % remember directory
            persistent lastDir

            if isempty(lastDir)
                lastDir = '*.*'; end
            

            if isfile(self.credentialsFilename)

                [n,p] = IBdb.readCredentialsFile(self.credentialsFilename);

            else

                disp("Choose a text file containing user credentials in the form " + ...
                    "'username,password' (without quotes, single line).");

                [fn,fp] = uigetfile(lastDir, 'MultiSelect', 'off');

                if ischar(fn)

                    self.credentialsFilename = fullfile(fp, fn);

                    [n,p] = IBdb.readCredentialsFile(self.credentialsFilename);

                    lastDir = fullfile(p, '*.*');

                else % aborted

                    [n,p] = IBdb.readCredentialsUserInput;

                end

            end


        end



        function token_create(self)
            %token_create Retrieves the tokenAuth string using the data base login
            %credentials.

            [n,p] = self.getLoginCredentials;

            if n == ""
                warning("IBDB:token_create:NoCredentialsProvided", ...
                    "No token was requested from the database because no user " + ...
                    "credentials were provided.");
            else

                response = webwrite(...
                    composeUrl(self.api, self.TOKEN), ...
                    "username", n, ...
                    "password", p);

                self.tokenAuth = response.token;
                self.tokenTimeStamp = datetime(response.created, ...
                    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.S''Z');
            end
        end

        
        function set.tokenAuth(self, token)
            
            if ~startsWith(token, "Token")
                warning('IBDB:setTokenAuth:MissingPrefix', ...
                    "The tokenAuth string should be starting with ""Token"".")
            end
            
            self.tokenAuth = token;

            % Pack token in the header of the WEBOPTIONS that is used for requests
            self.webopts.HeaderFields = ['Authorization', self.tokenAuth];
        end
        
        
        
        %% Request functions
        
        function [resp, respPy] = neuron_get(self, id)

            id = IBdb.validate_id(id);

            [resp, respPy] = self.request('get', composeUrl(self.NEURON, id));
            
        end
        

        function [resp, respPy] = neuron_delete(self, id)
            
            id = IBdb.validate_id(id);
            
            [resp, respPy] = self.request('delete', ...
                composeUrl(IBdb.NEURON, id));
        end


        function [resp, respPy] = neuron_post(self, NameValue)

            arguments
                self
                
                NameValue.name (1,1) string
                NameValue.short_name (1,1) string
                
                NameValue.public {IBdb.mustBeEmptyOrLogical}
                NameValue.species {IBdb.mustBeEmpytOrScalarInteger} = self.default_species

                
                NameValue.archived {IBdb.mustBeEmptyOrLogical}
                NameValue.archived_notes string {IBdb.mustBeEmptyOrScalarText}

                NameValue.hemisphere string {IBdb.mustBeEmptyOrScalarText}
                
                NameValue.reconstruction_creator string {IBdb.mustBeEmptyOrScalarText} = ...
                    self.default_reconstructionCreator
                
                NameValue.sex string {IBdb.mustBeEmptyOrScalarText} = IBdb.SEX_UNKNOWN
                
                NameValue.group_head string {IBdb.mustBeEmptyOrScalarText} ...
                    = self.default_groupHead
                
                NameValue.experimenter string {IBdb.mustBeEmptyOrScalarText}...
                    = self.default_experimenter
                
                NameValue.super_type {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.neuron_family {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.neuron_class {IBdb.mustBeEmpytOrScalarInteger}
            end
            

            NameValue.sex = IBdb.validate_SEX(NameValue.sex);
            
            if isfield(NameValue, 'hemisphere')
                NameValue.hemisphere = IBdb.validate_HEMISPHERE(NameValue.hemisphere);
            end


            query = namedargs2cell(NameValue);

            [resp, respPy] = self.request("post", IBdb.NEURON, query{:});
            
        end


        function [resp, respPy] = neuron_patch(self, neuron_id, NameValue)

            arguments
                self
                neuron_id
                NameValue.name string {IBdb.mustBeEmptyOrScalarText}
                NameValue.short_name string {IBdb.mustBeEmptyOrScalarText}
                NameValue.sex string {IBdb.mustBeEmptyOrScalarText}
                NameValue.reconstruction_creator string {IBdb.mustBeEmptyOrScalarText}
                NameValue.group_head string {IBdb.mustBeEmptyOrScalarText}
                NameValue.experimenter string {IBdb.mustBeEmptyOrScalarText}
                NameValue.public {IBdb.mustBeEmptyOrLogical}
                NameValue.hemisphere string {IBdb.mustBeEmptyOrScalarText}
                NameValue.species {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.super_type {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.neuron_family {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.neuron_class {IBdb.mustBeEmpytOrScalarInteger}
            end

            neuron_id = IBdb.validate_id(neuron_id);

            if isfield(NameValue, 'sex')
                NameValue.sex = IBdb.validate_SEX(NameValue.sex);
            end

            if isfield(NameValue, 'hemisphere')
                NameValue.hemisphere = IBdb.validate_HEMISPHERE(NameValue.hemisphere);
            end

            query = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request('patch', ...
                composeUrl(IBdb.NEURON, neuron_id), query{:});
            
        end



        function [resp, respPy] = experiment_post(self, neuron_id, NameValue)
            
            arguments
                self
                neuron_id
                
                NameValue.description string {IBdb.mustBeEmptyOrScalarText}
                NameValue.experimenter ...
                    string {IBdb.mustBeEmptyOrScalarText} = self.default_experimenter
                NameValue.date string {IBdb.mustBeEmptyOrScalarText}
                NameValue.comments string {IBdb.mustBeEmptyOrScalarText}
                NameValue.category {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.user_defined_id string {IBdb.mustBeEmptyOrScalarText}
            end
            
            neuron_id = self.validate_id(neuron_id);
            
            if isfield(NameValue, 'category')
                NameValue.category = ...
                    IBdb.validate_experimentCategory(NameValue.category);
            end
            
            
            postArgs = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request("post", ...
                composeUrl(IBdb.EXPERIMENT, IBdb.NEURON, neuron_id), ...
                postArgs{:});
            
        end
        
        
        
        function [resp, respPy] = neuron_classification_get(self, classification_type)
            %neuron_classification_get List all entries in the data base of the specified
            %classification type.
            %
            
            
            arguments
                self
                
                classification_type (1,1) string ...
                    {mustBeMember(classification_type, ["class","family","supertype"])}
            end
            
            
            [resp, respPy] = self.request('get', ...
                composeUrl(IBdb.NEURON, classification_type));
            
        end
        
        
        function [resp, respPy] = neuron_classification_post(self, classification_type, value)
            
            arguments
                self
                classification_type (1,1) string ...
                    {mustBeMember(classification_type, ["class","family","supertype"])}
                value (1,1) string
            end
            
            
            [resp, respPy] = self.request('post', ...
                composeUrl(IBdb.NEURON, classification_type), ...
                "value", value);
            
        end
        
        
        function [resp, respPy] = neuron_classification_delete(self, classification_type, id)
            
            arguments
                self
                classification_type (1,1) string ...
                    {mustBeMember(classification_type, ["class","family","supertype"])}
                id
            end
            
            id = IBdb.validate_id(id);
            
            [resp, respPy] = self.request('delete', ...
                composeUrl(IBdb.NEURON, classification_type, id));
            
        end
        
        function id = neuron_classification_get_id(self, classification_type, value, createIfMissing)
            %neuron_classification_get_id Returns the ID of a specific classification
            %type. The entry is matched case insensitively with the specified value.
            %
            %   id = obj.neuron_classification_get_id(classification_type, value)
            %   id = obj.neuron_classification_get_id(classification_type, value, createIfMissing)
            %
            % Input:
            % classification_type -- One of ["class","family","supertype"]
            % Scalar string
            %
            % value -- The value of the entry
            % Scalar string
            %
            % createIfMissing (optional) -- Add entry with this name if not found
            % false (default) | true
            % If the specified entry is not found in the database, and this parameter
            % is set to TRUE, the entry is created and the new entry's ID is returned.
            %
            % Output:
            % id -- Entry ID
            % Scalar double
            % If no entry with the specified value is found and createIfMissing is FALSE,
            % ID is empty.
            %
            % Example:
            %   id = obj.neuron_classification_get_id("supertype", "delta7")
            %
            
            arguments
                self
                
                classification_type (1,1) string ...
                    {mustBeMember(classification_type, ["class","family","supertype"])}
                
                value (1,1) string
                
                createIfMissing (1,1) logical = false
            end
            
            
            entries = self.request('get', ...
                composeUrl(IBdb.NEURON, classification_type));
            
            matchTF = strcmpi(string({entries.value}), value);
            
            if any(matchTF)
                
                id = entries(matchTF).id;
                
            elseif createIfMissing
                
                resp = self.neuron_classification_post(...
                    classification_type, value);
                
                id = resp.id;
                
                logMsg("New neuron %s created: %s (ID %i)", ...
                    classification_type, value, id);
                
            else
                id = [];
            end
            
        end
        
        
        
        function [resp, respPy] = publication_post(self, type, id, doi)
            %publication_post Add a publication (via DOI) to an experiment or neuron.
            
            arguments
                self
                type (1,1) string {mustBeMember(type, ["experiment", "neuron"])}
                id
                doi (1,1) string
            end
            
            id = self.validate_id(id);
            
            
            [resp, respPy] = self.request("post", ...
                composeUrl(type, id, IBdb.PUBLICATION), ...
                'doi', doi);
            
        end
        
        
        function [resp, respPy] = publication_delete(self, type, type_id, publication_id)
            %publication_delete Remove a publication entry of an experiment or neuron. The
            %publication is identified by it's ID, which can be retrieved from the
            %experiment's/neuron's metadata.
            %
            %   [resp, respPy] = publication_delete(self, type, doi_id)
            
            arguments
                self
                type (1,1) string {mustBeMember(type, ["experiment", "neuron"])}
                type_id
                publication_id (1,1) {mustBeInteger}
            end
            
            type_id = self.validate_id(type_id);
            
            
            [resp, respPy] = self.request("delete", ...
                composeUrl(type, type_id, IBdb.PUBLICATION, publication_id) );
            
        end
        
        
        function [resp, respPy] = experiment_publication_post(self, experiment_id, doi)
            
            [resp, respPy] = self.publication_post('experiment', experiment_id, doi);
            
        end
        
        
        function [resp, respPy] = experiment_publication_delete(self, experiment_id, doi_id)
            
            [resp, respPy] = self.publication_delete('experiment', experiment_id, doi_id);
            
        end
        
        
        function [resp, respPy] = neuron_publication_post(self, neuron_id, doi)
            
            [resp, respPy] = self.publication_post('neuron', neuron_id, doi);
            
        end
        
        
        function [resp, respPy] = neuron_publication_delete(self, neuron_id, doi_id)
            
            [resp, respPy] = self.publication_delete('neuron', neuron_id, doi_id);
            
        end
        
        
        function [resp, respPy] = neuron_arborization_region_get(self, neuron_id)
            
            neuron_id = IBdb.validate_id(neuron_id);
            
            [resp, respPy] = self.request('get', ...
                composeUrl(IBdb.NEURON, neuron_id, IBdb.ARBORIZATION_REGIONS));
            
        end
        
        
        
        
        
        function [resp, respPy] = neuron_morphology_get(self, id)
            
            id = IBdb.validate_id(id);
            
            [resp, respPy] = self.request('get', ...
                composeUrl(IBdb.NEURON, IBdb.MORPHOLOGY, id) );
            
        end
        
        
        function [resp, respPy] = neuron_morphology_post(self, neuron_id, NameValue)
            
            arguments
                self
                neuron_id
                
                NameValue.soma_location string {IBdb.mustBeEmptyOrScalarText}
                NameValue.fiber_bundles double {mustBeInteger}
                NameValue.description string {IBdb.mustBeEmptyOrScalarText}
            end
            
            neuron_id = self.validate_id(neuron_id);
            
            NameValue.neuron = neuron_id;
            
            query = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request('post', ...
                composeUrl(IBdb.NEURON, IBdb.MORPHOLOGY), ...
                query{:});
            
        end
        
        function [resp, respPy] = neuron_morphology_patch(self, neuron_id, NameValue)
            arguments
                self
                neuron_id
                NameValue.soma_location {IBdb.mustBeEmptyOrScalarText}
                NameValue.fiber_bundles {mustBeInteger}
                NameValue.description {IBdb.mustBeEmptyOrScalarText}
            end
            
            neuron_id = self.validate_id(neuron_id);
            
            query = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request('patch', ...
                composeUrl(IBdb.NEURON, IBdb.MORPHOLOGY, neuron_id), ...
                query{:});
            
        end
        
        
        
        function [resp, respPy] = neuron_morphology_delete(self, neuron_id)
            arguments
                self
                neuron_id
            end
            
            
            neuron_id = self.validate_id(neuron_id);
            
            [resp, respPy] = self.request('delete', ...
                composeUrl(IBdb.NEURON, IBdb.MORPHOLOGY, neuron_id));
        end
        
        
        
        function [resp, respPy] = arborization_region_delete(self, arborization_region_id)
            
            arborization_region_id = IBdb.validate_id(arborization_region_id);
            
            [resp, respPy] = self.request('delete', ...
                composeUrl(IBdb.NEURON, IBdb.ARBORIZATION_REGION, arborization_region_id));
            
        end
        
        
        
        function [resp, respPy] = experiment_get(self, experiment_id)
            %experiment_get Retrieve meta data of an experiment.
            
            arguments
                self
                experiment_id
            end
            
            experiment_id = self.validate_id(experiment_id);
            
            [resp, respPy] = self.request("get", ...
                composeUrl(IBdb.EXPERIMENT, experiment_id) );
            
        end
        
        
        function [exp_id, obj_id, exp_data, obj_data] = experiment_get_from_user_id(self, user_defined_id)
            %experiment_get_from_user_id Retrieves data of an experiment based on
            %user_defined_id
            %
            % [exp_id, obj_id, exp_data, obj_data] = obj.experiment_get_from_user_id(user_defined_id)
            %
            % Input:
            % user_defined_id -- Search for experiments with this field value for
            %   "user_defined_id"
            %
            % Output: If there was no experiment found, all output arguments are empty
            % exp_id -- Integer ID of the experiment
            % obj_id -- Integer ID of the associated object (e. g., a neuron)
            % exp_data -- Struct containing all retrieved experiment metadata
            % obj_data -- Struct containing all retrieved associated-object metadata
            
            
            user_defined_id = IBdb.validate_id(user_defined_id);
            
            exp_data = self.experiments_query('user_defined_id', user_defined_id);
            
            if isempty(exp_data)
                exp_id = [];
                obj_id = [];
                obj_data = [];
                return
            end
            
            obj_data = exp_data.associated_object;
            obj_id = obj_data.object_id;
            exp_id = exp_data.id;
            
        end
        
        
        
        function [resp, respPy] = experiment_file_delete(self, experiment_id, file_uuid)
            %experiment_file_delete Delete a file that is associated with an experiment.
            
            arguments
                self
                experiment_id
                file_uuid (1,1) string
            end
            
            experiment_id = self.validate_id(experiment_id);
            
            [resp, respPy] = self.request('delete', ...
                composeUrl(...
                IBdb.EXPERIMENT, experiment_id, self.FILE, file_uuid));
            
        end
        
        
        
        function [resp, respPy] = usergroup_associateExperiment(self, varargin)
            
            [resp, respPy] = self.usergroup_post("experiment", varargin{:});
            
        end
        
        
        function [resp, respPy] = usergroup_associateNeuron(self, varargin)
            
            [resp, respPy] = self.usergroup_post("neuron", varargin{:});
            
        end
        
        
        function [resp, respPy] = usergroup_post(self, entityType, NameValue)
            %usergroup_post Associate neuron or experiment to user group.
            
            arguments
                self
                
                entityType (1,1) string {mustBeMember(entityType, ["experiment", "neuron"])}
                
                NameValue.id
                NameValue.group
                NameValue.editable (1,1) {mustBeNumericOrLogical}
            end
            
            NameValue.id = self.validate_id(NameValue.id);
            NameValue.group = self.validate_id(NameValue.group);
            
            % Rename 'id' input to 'experiment' or 'neuron', because these are the input
            % fields for ID
            NameValue.(entityType) = NameValue.id;
            NameValue = rmfield(NameValue, 'id');
            
            
            query = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request("post",  ...
                composeUrl(IBdb.GROUP, entityType), query{:});
            
            
        end
        
        
        function [resp, respPy] = usergroup_associateEntityToGroup(self, entityType, entity_id, groupId, editableTF, NameValue)
            %usergroup_associateEntityToGroup Verbose wrapper for usergroup_post
            %
            %
            % dbResp = obj.usergroup_associateEntityToGroup(entityType, id, groupId, editableTF, 'dryRun', tf)
            
            arguments
                self
                entityType (1,1) string {mustBeMember(entityType, ["experiment", "neuron"])}
                entity_id
                groupId
                editableTF (1,1) {mustBeNumericOrLogical}
                NameValue.dryRun (1,1) logical = false
            end
            
            
            % IDs must be typcast to double because the API returns integers for IDs
            
            entity_id = str2double( IBdb.validate_id(entity_id) );
            groupId = str2double( IBdb.validate_id(groupId) );
            
            logMsg("Trying to add %s %i to user group %i.", ...
                entityType, entity_id, groupId)
            
            % check whether neuron/experiment is already associated with group
            entityInGroup = self.usergroup_get(entityType);
            
            if isfield(entityInGroup, 'group')
                entityInGroup = entityInGroup([entityInGroup.group] == groupId);
            end
            
            entityInGroup_data = [entityInGroup.(entityType)]; % entity meta data
            entityInGroup_ids = [entityInGroup_data.id]; % ID in database
            
            entityIsInGroup = ismember(entity_id, entityInGroup_ids);
            
            if entityIsInGroup
                % IDs of entity->group link
                linkIds = [entityInGroup.id];
                
                logMsg(...
                    "Aborting: %s is already associated to group (database link ID %i).", ...
                    entityType, linkIds(entity_id == entityInGroup_ids) );
                
            else
                
                if ~NameValue.dryRun
                    [resp, respPy] = idb.usergroup_post(entityType, 'id', entity_id, ...
                        'group', groupId, 'editable', editableTF);
                else
                    resp = struct;
                    resp.id = nan;
                    respPy = [];
                end
                
                logMsg("Added %s %i to group %i (database link ID %i).", ...
                    entityType, entity_id, groupId, resp.id);
                
            end
            
            logMsg("Done.");
            
        end
        
        
        
        function [resp, respPy] = usergroup_get(self, type, id)
            %usergroup_get Retrieve experiments or neurons that are associated with a user
            %group. If ID is omitted or specified as empty, all experiments are listed.
            
            arguments
                self
                
                type (1,1) string {mustBeMember(type, ["experiment", "neuron"])}
                
                id (1,1) = ""
            end
            
            id = self.validate_id(id);
            
            [resp, respPy] = self.request('get', composeUrl(IBdb.GROUP, type, id) );
            
        end
        
        
        
        
        function [resp, respPy] = neuron_query(self, NameValue)
            %neuron_query Retrieve a list of neurons in the data base.
            
            arguments
                self
                
                NameValue.arborization_region__structure {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.arborization_region__structure__abbreviation string {IBdb.mustBeEmptyOrScalarText}
                NameValue.arborization_region__structure__abbreviation__icontains string {IBdb.mustBeEmptyOrScalarText}
                NameValue.name string {IBdb.mustBeEmptyOrScalarText}
                NameValue.name__icontains string {IBdb.mustBeEmptyOrScalarText}
                NameValue.sex string {IBdb.mustBeEmptyOrScalarText}
                NameValue.sex__icontains string {IBdb.mustBeEmptyOrScalarText}
                NameValue.short_name string {IBdb.mustBeEmptyOrScalarText}
                NameValue.short_name__icontains string {IBdb.mustBeEmptyOrScalarText}
                NameValue.species {IBdb.mustBeEmpytOrScalarInteger}
                
            end
            
            query = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request('get', IBdb.NEURON, query{:} );
        end


        function [resp, respPy] = species_query(self)
            %species_query Retrieve a list of species.
            
            [resp, respPy] = self.request('get', IBdb.SPECIES);
        end
        
        
        function [resp, respPy] = experiment_files_get(self, experiment_id)
            %experiment_files_get Retrieve a list of the files associated with an
            %experiment.
            
            experiment_id = IBdb.validate_id(experiment_id);
            
            [resp, respPy] = self.request("get", ...
                composeUrl(IBdb.EXPERIMENT, experiment_id, IBdb.FILE) );
            
        end
        
        
        function [resp, respPy] = experiments_query(self, NameValue)
            %experiments_query Retrieve experiments.
           
            arguments
                self
                
                NameValue.uploaded_by {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.user_defined_id string {IBdb.mustBeEmptyOrScalarText}
            end
            
            query = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request("get", ...
                IBdb.EXPERIMENT, query{:} );
            
        end
        
        
        function [dbResp, awsResp] = neuron_image_post(self, neuron_id, fullFileName, NameValue)
            
            arguments
                self
                neuron_id
                
                fullFileName (1,1) string = ""
                
                NameValue.caption string {IBdb.mustBeEmptyOrScalarText}
                NameValue.staining string {IBdb.mustBeEmptyOrScalarText} = ""
                NameValue.can_download {IBdb.mustBeEmptyOrLogical}
            end
            
            
            neuron_id = IBdb.validate_id(neuron_id);
            NameValue.staining = IBdb.validate_STAINING(NameValue.staining);
            
            if fullFileName == ""
                [f,p] = uigetfile('*.*', 'MultiSelect', 'off');
                
                fullFileName = fullfile(p, f);
                
            else
                
                validateattributes(fullFileName, {'string', 'char'}, {'scalartext'});
                
            end
            
            assert(isfile(fullFileName), "Specified file '%s' not found.", fullFileName);
            
            [~, fn, ext] = fileparts(fullFileName);
            fnExt = append(fn, ext);
            
            query = namedargs2cell(NameValue);
            query = [query, {'file_name', fnExt}];
            
            dbResp = self.request("post",  ...
                composeUrl(IBdb.NEURON, neuron_id, "add_image"), ...
                query{:});
            
            awsResp = IBdb.uploadAws(...
                dbResp.upload_url.url, dbResp.upload_url.fields, fullFileName, fnExt);
        end
        
        
        function [resp, respPy] = neuron_images_get(self, neuron_id)
            
            arguments
                self
                neuron_id
            end
            
            neuron_id = IBdb.validate_id(neuron_id);
            
            [resp, respPy] = self.request('get',  ...
                composeUrl(IBdb.NEURON, neuron_id, "list_images"));
            
            
        end
        
        
        function [resp, respPy] = neuron_function_post(self, neuron_id, NameValue)
            %neuron_function_post Add a function entry to a neuron. If parameter pairs
            %["file", "<filename>"] are provided, this file is uploaded as a
            %representative neural response.
            % 
            
            arguments
                self
                neuron_id
                
                NameValue.description string {IBdb.mustBeEmptyOrScalarText}
                NameValue.response_class string {IBdb.mustBeEmptyOrScalarText}
                NameValue.modality string {IBdb.mustBeEmptyOrScalarText}
                NameValue.background_firing_rate_min {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.background_firing_rate_max {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.role string {IBdb.mustBeEmptyOrScalarText}
                NameValue.role_proven {IBdb.mustBeEmptyOrLogical}
                NameValue.archived {IBdb.mustBeEmptyOrLogical}
                NameValue.neurotransmitter {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.cotransmitter {mustBeInteger}
                
                % Representative neural response
                NameValue.file string {IBdb.mustBeEmptyOrScalarText}
            end
            
            neuron_id = IBdb.validate_id(neuron_id);
            NameValue.neuron = neuron_id;
            
            if isfield(NameValue, 'response_class')
                NameValue.response_class = ...
                    IBdb.validate_FUNCTION_RESPONSE_CLASS(NameValue.response_class);
            end
            
            if isfield(NameValue, 'modality')
                NameValue.modality = IBdb.validate_FUNCTION_MODALITY(NameValue.modality);
            end
            
            if isfield(NameValue, 'role')
                NameValue.role = IBdb.validate_FUNCTION_ROLE(NameValue.role);
            end
            
            
            % Catch file specification
            fileUploadTF = isfield(NameValue, 'file');
            if fileUploadTF
                responseFilename = NameValue.file;
                NameValue = rmfield(NameValue, 'file');
            end
            
            query = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request('post', ...
                composeUrl(IBdb.NEURON, IBdb.FUNCTION), ...
                query{:});
            
            
            if fileUploadTF
                self.neuron_function_representative_response_post(...
                    resp.uuid, responseFilename);
            end
            
        end
        
        
        function [resp, respPy] = neuron_functions_get(self, neuron_id)
            %neuron_functions_get Retrieve function entries of a neuron.
            
            neuron_id = IBdb.validate_id(neuron_id);
            
            [resp, respPy] = self.request('get', ...
                composeUrl(IBdb.NEURON, neuron_id, IBdb.FUNCTIONS));
            
        end
        
        
        function [resp, respPy] = neuron_function_representative_response_post(self, uuid, fullFileName)
            
            arguments
                self
                uuid (1,1) string
                fullFileName string {IBdb.mustBeEmptyOrScalarText} = ""
            end
            
            
            if isempty(fullFileName) || fullFileName == ""
                [f,p] = uigetfile('*.*', 'MultiSelect', 'off');
                
                fullFileName = fullfile(p, f);
            end
            
            url = composeUrl(IBdb.NEURON, IBdb.FUNCTION, uuid, IBdb.FILES);
            
            if self.hasPy
                
                [resp, respPy] = self.pyRequest("post", ...
                    url, ...
                    'file', fullFileName);
                
            else
                
                respPy = [];
                
                fp = matlab.net.http.io.FileProvider(fullFileName, 'r');
                
                mp = matlab.net.http.io.MultipartFormProvider('file', fp);
                
                reqMsg = matlab.net.http.RequestMessage('POST', ...
                    matlab.net.http.HeaderField(self.webopts.HeaderFields{:}), ...
                    mp);
                
                resp = reqMsg.send(composeUrl(IBdb.api, url));
                
                % TODO Properly handle HTTP errors
                assert(resp.Completed, resp.string);
                
            end
            
        end
        
        
        
        function [dbResp, awsResp] = experiment_file_upload(self, experiment_id, fullFileName, description)
            %experiment_file_upload Add a file to an experiment.
            % Requires Python and the REQUESTS package.
            %
            %   obj.experiment_file_upload(experiment_id)
            %   obj.experiment_file_upload(experiment_id, fullFileName, description)
            %   [dbResp, awsResp] = obj.experiment_file_upload(_)
            
            arguments
                self
                experiment_id {IBdb.mustBeEmpytOrScalarInteger}
                fullFileName string {IBdb.mustBeEmptyOrScalarText} = ""
                description string {IBdb.mustBeEmptyOrScalarText} = ""
            end
            
            experiment_id = IBdb.validate_id(experiment_id);
            
            if fullFileName == ""
                [f,p] = uigetfile('*.*', 'MultiSelect', 'off');
                
                fullFileName = fullfile(p, f);
                
            end
            
            assert(isfile(fullFileName), "Specified file '%s' not found.", fullFileName);
            
            [~, fn, ext] = fileparts(fullFileName);
            fnExt = append(fn, ext);
            
            % Create file entry in data base. The data from this response is then used to
            % upload the actual file.
            
            dbResp = self.request("post",  ...
                composeUrl(self.EXPERIMENT, experiment_id, self.FILE), ...
                "description", description, "file_name", fnExt);
            
            awsResp = IBdb.uploadAws(...
                dbResp.url, dbResp.fields, fullFileName, fnExt);
            
        end
        
        
        
        function [fnUpload, dbResp, awsResp] = experiment_fileUploader(self, experiment_id, fnDir, description, NameValue)
            %experiment_fileUploader Wrapper for experiment_file_upload with some
            %convenient options.
            
            
            arguments
                self
                experiment_id
                fnDir (1,1) string
                description (1,1) string
                
                NameValue.dryRun (1,1) logical = false
                NameValue.uploadAllFoundTF (1,1) logical = false
                NameValue.deleteExistingFilesTF (1,1) logical = true
                NameValue.skipExistingFilesTF (1,1) logical = true
                
                NameValue.storeExperimentMetadataTF (1,1) logical = false
                
            end
            
            experiment_id = IBdb.validate_id(experiment_id);
            
            
            t = tic;
            
            
            % Store experiment ID and metadata between calls in order to reduce redundant
            % API requests.
            persistent last_experiment_id expFiles expFiles_names
            
            
            % Always update variables if storeExperimentMetadataTF is FALSE; otherwise, do
            % it if this is the first time calling this function or if the experiment_id
            % has changed.
            if ~NameValue.storeExperimentMetadataTF || ...
                    isempty(last_experiment_id) || ...
                    str2double(experiment_id) ~= str2double(last_experiment_id)
                
                last_experiment_id = experiment_id;
                
                expFiles = self.experiment_files_get(experiment_id);
                
                if isempty(expFiles)
                    expFiles_names = {};
                else
                    expFiles_names = {expFiles.file_name};
                end
                
            end
            
            
            logMsg("Gathering info for file %s (%s)", fnDir, description)
            
            fInfo = dir(fnDir);
            
            if isempty(fInfo)
                logMsg("File not found on disk; skipping.")
                fnUpload = '';
                dbResp = struct;
                awsResp = struct;
                return
            end
            
            
            if ~NameValue.uploadAllFoundTF && ~isscalar(fInfo)
                logMsg("Multiple files found on disk, using the first one:");
                disp(string({fInfo.name})')
                
                fInfo = fInfo(1);
            end
            
            
            for jFile = 1:numel(fInfo)
                
                cFileInfo = fInfo(jFile);
                
                fnUpload = fullfile(cFileInfo.folder, cFileInfo.name);
                
                
                % Check whether file was already uploaded
                hasSameFilename = ismember(expFiles_names, cFileInfo.name);
                
                if any(hasSameFilename)
                    
                    logMsg("File %s already found in the data base.", cFileInfo.name);
                    
                    if NameValue.skipExistingFilesTF
                        logMsg("Skipping upload of file %s.", cFileInfo.name);
                        dbResp = struct;
                        awsResp = struct;
                        return
                    end
                    
                    if NameValue.deleteExistingFilesTF
                        logMsg("Deleting existing file(s) with the same name from experiment.");
                        
                        file_uuid = {expFiles(hasSameFilename).uuid};
                        
                        if ~NameValue.dryRun
                            cellfun(@(uuid) ...
                                self.experiment_file_delete(experiment_id, uuid), file_uuid);
                        end
                    end
                    
                end
                
                logMsg("Starting upload.")
                
                if NameValue.dryRun
                    dbResp = struct;
                    awsResp = struct;
                else
                    [dbResp, awsResp] = self.experiment_file_upload(...
                        experiment_id, fnUpload, description);
                end
                
                if ismember('persistent_file_uuid', fieldnames(dbResp))
                    logMsg("New file UUID: %s", dbResp.persistent_file_uuid);
                end
                
                logMsg("Done (took %.1f min).", toc(t)/60)
                
            end
            
            
        end
        
        


        function [resp, respPy] = species_get(self, id)
            %species_get Retrieve species meta data.
            
            id = IBdb.validate_id(id);
            
            [resp, respPy] = self.request("get", composeUrl(IBdb.SPECIES, id) );
        end
        

        
        

        function [resp, respPy] = neuron_reconstruction_get(self, id)
            id = IBdb.validate_id(id);
            
            [resp, respPy] = self.request("get", ...
                composeUrl(IBdb.NEURON_RECONSTRUCTION, id) );
        end
        

        function [resp, respPy] = neuron_reconstruction_query(self, NameValue)
            arguments
                self
                NameValue.default {IBdb.mustBeEmptyOrLogical}
                NameValue.neuron {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.neuron__species {IBdb.mustBeEmpytOrScalarInteger}
            end

            query = namedargs2cell(NameValue);

            [resp, respPy] = self.request("get", ...
                IBdb.NEURON_RECONSTRUCTION, query{:} );
            
        end
        
        
        function [resp, respPy] = neuron_arborization_region_post(self, neuron_id, NameValue)
            
            arguments
                self
                neuron_id
                
                NameValue.structure
                NameValue.hemisphere string {IBdb.mustBeEmptyOrScalarText}
                NameValue.pass_through {IBdb.mustBeEmptyOrLogical}
                NameValue.fieldsize string {IBdb.mustBeEmptyOrScalarText} = IBdb.ARBORIZATION_FIELDSIZE_UNKNOWN
                NameValue.direction string {IBdb.mustBeEmptyOrScalarText} = IBdb.ARBORIZATION_DIRECTION_NOT_DEFINED
            end
            
            neuron_id = IBdb.validate_id(neuron_id);
            
            NameValue.neuron = neuron_id;
            
            NameValue.structure = IBdb.validate_id(NameValue.structure);
            
            if isfield(NameValue, 'hemisphere')
                NameValue.hemisphere = IBdb.validate_HEMISPHERE(NameValue.hemisphere);
            end
            
            NameValue.direction = IBdb.validate_ARBORIZATION_DIRECTION(NameValue.direction);
            NameValue.fieldsize = IBdb.validate_ARBORIZATION_FIELDSIZE(NameValue.fieldsize);
            
            query = namedargs2cell(NameValue);
            
            [resp, respPy] = self.request("post",  ...
                composeUrl(IBdb.NEURON, IBdb.ARBORIZATION_REGION), ...
                query{:});
            
        end
        
        
        
        
    end



    methods (Static)
        
        %% argument validation functions
        function mustBeEmpytOrScalarInteger(in)
            %mustBeInteger Validate integer input. May be empty or a scalar integer.
            % Use this for argument validation as in 
            % arguments
            %   arg {IBdb.mustBeEmpytOrScalarInteger}
            % end
            % Note that there is no size validation in the ARGUMENTS block because empty
            % values are explicitly allowed.
            
            if ~isempty(in)
                validateattributes(in, {'numeric'}, {'scalar', 'integer'});
            end
            
        end
        
        function mustBeEmptyOrScalarText(in)
            
            if ~isempty(in)
                validateattributes(in, {'char','string'}, {'scalartext'});
            end
            
        end
        
        function mustBeEmptyOrLogical(in)
            
            if ~isempty(in)
                validateattributes(in, {'logica'}, {'scalar'});
            end
            
        end
        
        
        %%
        function id = validate_id(id)
            %validate_id Input validation for ID. Accepts a scalar integer and scalar
            %text. Always returns the input ID as a string.
            %
            %   id = IBdb.validate_id(id);
            
            if isnumeric(id)
                validateattributes(id, {'numeric'}, {'scalar', 'integer'});
                id = num2str(id);
            else
                validateattributes(id, {'char', 'string'}, {'scalartext'});
                if ischar(id)
                    id = string(id);
                end
            end
            
        end
        
        
        function str = validate_SEX(str)
            str = validatestring(str, IBdb.validEnums_SEX);
        end

        function str = validate_HEMISPHERE(str)
            str = validatestring(str, IBdb.validEnums_HEMISPHERE);
        end
        
        function str = validate_ARBORIZATION_DIRECTION(str)
            str = validatestring(str, IBdb.validEnums_ARBORIZATION_DIRECTION);
        end
        
        function str = validate_ARBORIZATION_FIELDSIZE(str)
            str = validatestring(str, IBdb.validEnums_ARBORIZATION_FIELDSIZE);
        end
        
        function str = validate_STAINING(str)
            str = validatestring(str, IBdb.validEnums_STAINING);
        end
        
        function str = validate_BRAINSTRUCTURE_TYPE(str)
            str = validatestring(str, IBdb.validEnums_BRAINSTRUCTURE_TYPE);
        end
        
        function str = validate_FUNCTION_ROLE(str)
            str = validatestring(str, IBdb.validEnums_FUNCTION_ROLE);
        end
        
        function str = validate_FUNCTION_MODALITY(str)
            str = validatestring(str, IBdb.validEnums_FUNCTION_MODALITY);
        end
        
        function str = validate_FUNCTION_RESPONSE_CLASS(str)
            str = validatestring(str, IBdb.validEnums_FUNCTION_RESPONSE_CLASS);
        end
        
        
        
        function c = validate_experimentCategory(c)
            
            if ~isnumeric(c)
                c = double(c);
            end
            
            mustBeInteger(c);
            
            mustBeMember(c, IBdb.experimentCategories_list.id);
            
        end
        
        
        %%
        
        function tbl = experimentCategories_list()
            %experimentCategories_list Retrieve the list of available experiment
            %categories as a table
            % 
            
            % Only request the list once per MATLAB session
            persistent expCatTbl
            
            if isempty(expCatTbl)
                
                url = composeUrl(IBdb.api, IBdb.EXPERIMENT, IBdb.CATEGORY);
                
                % Remove trailing slash, else the request won't work.
                if endsWith(url, "/")
                    url = extractBefore(url, strlength(url));
                end
                
                expCatTbl = webread(url);
                
                expCatTbl = sortrows( struct2table(expCatTbl) );
            end
            
            tbl = expCatTbl;
            
        end
        
        
        function data = brain_structure_get(brainStructure_id)
            brainStructure_id = IBdb.validate_id(brainStructure_id);
            
            data = webread( composeUrl(IBdb.api, IBdb.BRAIN_STRUCTURE, brainStructure_id) );
        end
        
        
        function resp = brain_structure_query(NameValue)
            
            arguments
                
                NameValue.name string {IBdb.mustBeEmptyOrScalarText}
                NameValue.schematicbrainstructure__schematic__species {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.species {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.type string {IBdb.mustBeEmptyOrScalarText}
                NameValue.parent {IBdb.mustBeEmpytOrScalarInteger}
                NameValue.abbreviation string {IBdb.mustBeEmptyOrScalarText}
                
            end
            
%             NameValue.parent = IBdb.validate_id(NameValue.parent);
          
            
            % Querying for abbreviation is not yet implemented in the API, so let's do
            % this manually for now.
            if isfield(NameValue, "abbreviation")
                
                abbrev = NameValue.abbreviation;
                NameValue = rmfield(NameValue, "abbreviation");
                
            else
                abbrev = "";
            end
            
            
            query = namedargs2cell(NameValue);

            resp = webread( composeUrl(IBdb.api, IBdb.BRAIN_STRUCTURE), query{:} );
            
            
            if abbrev ~= ""
                resp = resp( strcmpi({resp.abbreviation}, abbrev) );
            end
            
        end
        
        
        
        
        % can/should be private?
        function awsResp = uploadAws(awsUrl, fields, fullFileName, fileName)
            %uploadAws Use an AWS upload URL from the data base for uploading a file.
            % Needs Python and the REQUESTS package.
            %
            % awsResp = IBdb.uploadAws(awsUrl, fields, fullFileName, fileName);
            %
            % awsUrl -- Upload URL returned from the data base
            %
            % fields -- Struct with fields that need to be passed to AWS
            %
            % fullFileName -- Valid Path + file name for actual upload
            %
            % fileName -- Displayed file name
            
            respFieldnames = fieldnames(fields);
            
            % Replace underscores with dashes because this is done by MATLAB in order to
            % provide the response as a STRUCT. Hopefully, this does not introduce any
            % errors when the response fields change ...
            postNames = strrep(respFieldnames, '_', '-');
            
            postValues = struct2cell(fields);
            
            % convert response field values to a cell array for name/value passing
            postArgs = [postNames, postValues];
            postArgs = postArgs';
            
            
            %% python approach (requires REQUESTS)
            
            % pure python:
%             import requests
%             payload={
%                 'key': '68e02c91-cf5d-41c4-8d05-eadac25251d4/test.txt',
%                 'x-amz-algorithm': 'AWS4-HMAC-SHA256',
%                 'x-amz-credential': '--cred--',
%                 'x-amz-date': '20210323T163113Z',
%                 'policy': '--policy--',
%                 'x-amz-signature': '--signature--'
%                 }
%             files=[ ('file', ('test.txt', open('test.txt','rb'), 'text/plain')) ]
%             headers = {}
%             response = requests.request("POST", url, headers=headers, data=payload, files=files)
            
            
            payload = py.dict( pyargs( postArgs{:} ) );
            
            files = py.dict(...
                pyargs('file', {fileName, py.open(fullFileName, 'rb')} ));
            
            % 'data' parameter: request's body
            awsResp = py.requests.request("POST", awsUrl, ...
                pyargs('headers', {}, 'data', payload, 'files', files ) ) ;
            
            
            if awsResp.status_code < 200 || awsResp.status_code >= 300
                
                warning('IBDB:AWSfileUpload:RequestNotSuccessful', ...
                    'The server responded with status %i %s', ...
                    awsResp.status_code, string(awsResp.reason));
                
            end
            
            return
            %%
            %%
            %% MATLAB approach
            % Not working because, for some reason, the response is always 411 Length
            % required. Apparently, the content-length is not communicated properly and I
            % don't know how to figure this out. Providing the correct content-length
            % works, but I do not know how to calculate it. Providing an excessive value
            % provokes an error whose message states the correct content-length, which can
            % then be used for a subsequent request but that would just be a shitty
            % workaround.
            
            fp = matlab.net.http.io.FileProvider(fullFileName, 'r');
            
            postNames{end+1} = 'file';
            postValues{end+1} = fp;
            
            postArgs = [postNames, postValues];
            postArgs = postArgs';
            
            mp = matlab.net.http.io.MultipartFormProvider(postArgs{:});
            
            reqMsg = matlab.net.http.RequestMessage('POST', [], mp);
            
%             reqMsg.Header = matlab.net.http.HeaderField('Content-Length', x);
            
            awsResp = reqMsg.send(dbResp.url);
            
        end
        


        function [n,p] = readCredentialsUserInput
            %readCredentialsUserInput Login credentials input.
            %
            % [username, password] = IBdb.readCredentialsUserInput();
            %
            
            if exist('passdlg', 'file')
                
                dlgInput = passdlg('u');
                n = string(dlgInput.User);
                p = string(dlgInput.Pass);
                
            else
                
                warning("IBDB:readCredentialsUserInput:UnsaveInput", ...
                    "Your username and password will be stored in your MATLAB history! " + ...
                    "You may want to delete them after putting them.");
                
                n = string(input("Username: ", 's'));
                p = string(input("Password: ", 's'));
            end
        end


        function [n,p] = readCredentialsFile(fn)
            %readCredentialsFile Reads the insectbraindb login credentials from a text
            %file. The file must contain a single line with username and password,
            %delimited with a comma.
            %
            % [username, password] = IBdb.readCredentialsFile(filename);
            %

            c = readcell(fn, 'FileType', 'text', 'TextType', 'string');

            assert(numel(c) == 2, "Error parsing credentials file: " + ...
                "The file must contain exactly two strings delimited with a comma.");

            [n, p] = c{:};

        end
        
        
        function hasPy = checkForPython()
            %checkForPython Checks the system for Python and the requests package. If both
            %are available, TRUE is returned.
            %
            %   hasPy = IBdb.checkForPython();
            
            logMsg("Checking for Python installation ...")
            
            [status, ~] = system("python --version");
            % (Explicitly omitting the second output suppresses the version information
            % output in the command window.)
            
            pyInstalled = status == 0;
            
            if pyInstalled
                
                % Check installed packages for requests
                [~, pipList] = system("pip list");
                
                hasRequests = contains(pipList, "requests");
                
            else
                
                warning("IBDB:checkForPython:PythonNotFound", ...
                    "No Python installation found. Install Python for full functionality.");
                
                hasRequests = false;
                
            end
            
            if ~hasRequests
                warning("IBDB:checkForPython:RequestsNotFound", ...
                    "'Requests' package for Python not found. Install the package for full functionality.");
            end
            
            hasPy = pyInstalled && hasRequests;
            
        end
        
        
        
        %% Boilerplate code generation
        
        function convertSchemaToArguments()
            %convertSchemaToArguments Converts the schema of an API endpoint to MATLAB
            %ARGUMENT syntax
            % The schema is provided in the clipboard and is expected to be in the format
            % provided by the Swagger interface
            % (https://insectbraindb.org/api/schema/swagger-ui/). The converted output is
            % likewise copied to the clipboard.
            %
            %   IBdb.convertSchemaToArguments()
            %
            % Example:
            %  1) Copy the endpoint schema of a request to the clipboard. It should look
            %  like this:
            %   {
            %   "description": "string",
            %   "experimenter": "string",
            %   "date": "2021-07-27",
            %   "comments": "string",
            %   "user_defined_id": "string",
            %   "category": 0
            %   }
            %
            %  2) Call this function:
            %   IBdb.convertSchemaToArguments()
            %
            %  3) Paste the clipboard content in the MATLAB function for which you need
            %  the schema field names to be parsed as name value pairs:
            %   arguments
            %   self
            %
            %   NameValue.description
            %   NameValue.experimenter
            %   NameValue.date
            %   NameValue.comments
            %   NameValue.user_defined_id
            %   NameValue.category
            %   end
            %  
            %  This is intended to be used as boilerplate code for functions that follow
            %  this function signature pattern:
            %       function response = myRequest(self, NameValue)
            
            txt = clipboard('paste');
            
            % break at newlines
            txt = strsplit(txt, '\n');
            
            % regular expression pattern
            expr = '\s*"(?<name>\w*)": (?<value>"[-\w]*"|\d*),?\s*';
            
            tokens = regexp(txt, expr, 'names');
            tokens = cell2mat(tokens);
            
            assert(~isempty(tokens), ...
                "IBDB:convertSchemaToArguments:NoMatch", ...
                "No matches found in clipboard text.");
            
            names = string({tokens.name});
            
            % append "NameValue." to fieldnames
            nameValueTxt = compose("NameValue.%s", names);
            
            % add ARGUMENTS syntax elements and SELF reference
            fullTxt = ["arguments", "self", "", nameValueTxt, "end"];
            
            % convert to single string with newlines
            fullTxt = strjoin(fullTxt, '\n');
            
            clipboard('copy', fullTxt)
            
        end
        
        
        function convertSchemaEnumsToCode(propertyPrefix, enumStrings)
            %convertSchemaEnumsToCode Converts API enumeration definition into boilerplate
            %code for property definition and validation in this class.
            %
            % Example:
            %
            %   IBdb.convertSchemaEnumsToCode("FUNCTION_ROLE", ["UNKNOWN" "INHIBITORY" "EXCITATORY"])
            %
            % Output:
            %
            % FUNCTION_ROLE_UNKNOWN = "UNKNOWN"
            % FUNCTION_ROLE_INHIBITORY = "INHIBITORY"
            % FUNCTION_ROLE_EXCITATORY = "EXCITATORY"
            %
            % validEnums_FUNCTION_ROLE = [
            % IBdb.FUNCTION_ROLE_UNKNOWN
            % IBdb.FUNCTION_ROLE_INHIBITORY
            % IBdb.FUNCTION_ROLE_EXCITATORY
            % ]
            %
            % function str = validate_FUNCTION_ROLE(str)
            % str = validatestring(str, IBdb.validEnums_FUNCTION_ROLE);
            % end

            
            arguments
                propertyPrefix (1,1) string
                enumStrings string
            end
            
            enumStrings = enumStrings(:); % must be column vector for COMPOSE
            
            propNames = compose("%s_%s", propertyPrefix, upper(enumStrings) );
            
            propDef = compose("%s = ""%s""\n", propNames, enumStrings);
            
            propNamesClassname = compose("IBdb.%s\n", propNames);
            
            validationPropName = "validEnums_" + propertyPrefix;
            
            validationPropDef = [
                compose("%s = [\n", validationPropName)
                propNamesClassname
                "]"
                ];
            
            
            validationFun = compose([
                "function str = validate_" + propertyPrefix + "(str)\n"
                "str = validatestring(str, IBdb." + validationPropName + ");\n"
                "end\n"
                ]);
            
            fprintf("\n");
            fprintf("%s", propDef);
            fprintf("\n");
            fprintf("%s", validationPropDef);
            fprintf("\n");
            fprintf("\n");
            fprintf("%s", validationFun);
            fprintf("\n");
            fprintf("\n");
            
            
        end
        
        
        
    end
    
    
end
