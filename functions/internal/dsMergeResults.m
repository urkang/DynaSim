function dsMergeResults(src, varargin)
%dsMergeResults - Merge analysis results of a simulation
%
% Usage:
%   results = dsMergeResults(src)
%   results = dsMergeResults(src,'option1',value1,...)
%
% Inputs:
%   - src: DynaSim study_dir path or studyinfo structure
%   - func: function handle of analysis function whose results to return
%   - options: (key/value pairs are passed on to the analysis function)
%     'import_scope' : 'studyinfo' only looks for files listed in studyinfo.mat
%                         that were specified in initial dsSimulate call
%                      'results' looks in 'results' folder
%                      'postHocResults' looks in 'postHocResults' folder
%                      'allResults' does above without studyinfo
%                      'all' does all of the above (default)'
%     'func'       : optional argument to return matching function name(s) or index(ies).
%                    1) name as function handle or string, or cell array of
%                    handles. one can mix in function number indicies also as
%                    strings or numeric. name can be partial for matching using 'contains' fn.
%                    2) index number(s) for function, typically following analysis in
%                    name, e.g. 'study_sim1_analysis#_func.mat' as mat. If index not
%                    specified and func name matches multiple functions, will
%                    return results as as structure fields (see Outputs below).
%     'simIDs'        : numeric array of simIDs to import results from (default: [])
%     'moveDir'       : rel or abs path to move original data to (default: 'results_split')
%     'delete_original': whether to delete original results (default: 0)
%
% Author: Erik Roberts
% Copyright (C) 2018

% dev TODO: fill in mising sims with new results if present

%% Check inputs
if ~nargin || isempty(src)
  src = pwd;
end

options = dsCheckOptions(varargin,{...
  'moveDir', 'results_split', [],...
  'delete_original',0,{0,1},... % whether to delete original results (default: 0)
  },false);

% determine study_dir
if isdir(src)
  study_dir = src;
elseif isfile(src)
  study_dir = fileparts(src);
elseif isstruct(src) && isfield(src,'study_dir')
  studyinfo = src;
  study_dir = studyinfo.study_dir;
end

[results, ~, originalResultFilePaths] = dsImportResults(study_dir, varargin{:}, 'as_cell',1, 'add_prefix',1);

if ~isempty(results)
  % save struct fields to vars in mat file
  filePath = fullfile(study_dir, 'results', 'results_merged.mat');
  if strcmp(reportUI,'matlab')
    save(filePath, '-struct','results', '-v7.3');
  else
    save(filePath, '-struct','results', '-hdf5'); % hdf5 format in Octave
  end
  
  if options.delete_original
    % delete filePaths
    structfun(@cellDel, originalResultFilePaths);
  elseif ~isempty(options.moveDir) % move filePaths
    [~, pathInAbsBool] = getAbsolutePath(options.moveDir);
    
    % make moveDir absolute path
    if ~pathInAbsBool
      moveDir = fullfile(study_dir, options.moveDir);
    else
      moveDir = options.moveDir;
    end
    
    % mkdir if ~exist
    exist_mkdir(moveDir);
    
    % move filePaths
    structfun(@cellMove, originalResultFilePaths);
  end
else
  warning('No results found');
end


%% Nested fn
  function cellMove(filePath)
    cellfun(@moveFile, filePath);
  end

  function moveFile(filePath)
    filename = filepartsNameExt(filePath);
    newFilePath = fullfile(moveDir, filename);
    movefile(filePath, newFilePath);
  end

end

%% local fn
function cellDel(filePath)
 cellfun(@delete, filePath);
end