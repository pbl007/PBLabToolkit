function arrayStruct = addNewFieldToNonScalarStruct (arrayStruct,scalarStruct,idx)
% functions addNewFieldToNonScalarStruct inserts the a scalar structure
% into an existing array structure at the given index. If the scalar
% structure contains fields not existing in the array structure, the new
% fields are added with empty values to the array structure to allow
% assignment.
%
%  Pablo

%% compare field names and find new, if any
fieldsInArray = fieldnames(arrayStruct);
fieldsInScalar = fieldnames(scalarStruct);
%look for additional fields in scalar array
fieldsNotInArray = setdiff(fieldsInScalar,fieldsInArray);

nFieldsToInitialize = numel(fieldsNotInArray);

%% initialize new variables in array structure
tmp = cell(size(arrayStruct));
for iFIELD  = 1 : nFieldsToInitialize
    [arrayStruct(:).(fieldsNotInArray{iFIELD})] = deal(tmp);
end

%% now we can add the new structre as valid entry into the array
arrayStruct(idx) = scalarStruct;
