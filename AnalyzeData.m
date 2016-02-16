function result=AnalyzeData(data,func,varargin)
%% result=AnalyzeData(data,func,'option1',value1,...)
% purpose: apply a user-specified analysis function to a DynaSim data structure.
% inputs:
%   data: DynaSim data structure (also accepted: data file name)
%   func: function handle pointing to analysis function
%   options: 
%     - key/value pairs passed on to the analysis function
%     - 'save_data_flag' (0 or 1) (default: 0): whether to save result
%     - 'result_file' (default: 'result.mat'): where to save result
% 
% outputs:
%   result: structure returned by the analysis function
% 
% see also: SimulateModel

% todo: annotate figures with data set-specific modifications

% check inputs
options=CheckOptions(varargin,{...
  'result_file','result.mat',[],...
  'save_data_flag',0,{0,1},...
  },false);

% load data if input is not a DynaSim data structure
if ~(isstruct(data) && isfield(data,'time'))
  data=ImportData(data,varargin{:}); % load data
end
% confirm single data set
if numel(data)>1
  error('this function only accepts a single DynaSim data structure.');
end
% confirm function handle
if ~isa(func,'function_handle')
  error('post-processing function must be supplied as a function handle');
end
% confirm single analysis function
if numel(func)>1
  error('Too many function handles were supplied. AnalyzeData only applies a single function to a single data set.');
end

% do analysis
result=feval(func,data,varargin{:});

% determine if result is a plot handle or derived data
if all(ishandle(result)) % analysis function returned a graphics handle
  for i=1:length(result)
    % add 'varied' info to plot as annotation
    % ...
    % save plot
    if options.save_data_flag
      % temporary default: jpg
      if length(result)==1
        fname=[options.result_file '.jpg'];
      else
        fname=[options.result_file '_page' num2str(i) '.jpg'];
      end
      print(gcf,fname,'-djpeg');
    end
  end
else % analysis function returned derived data
  if isstruct(result) && isfield(data,'varied')
    % add 'varied' info to result structure
    for i=1:length(result)
      result(i).varied=data.varied;
      for j=1:length(data.varied)
        result(i).(data.varied{j})=data.(data.varied{j});
      end
    end
  end
  % save derived data
  if options.save_data_flag
    save(options.result_file,'result','-v7.3');
  end
end
