function new_result_file = nameFromVaried(data, file_type, old_result_file)
%% new_result_file = nameFromVaried(data, file_type, old_result_file)
% purpose: makes a filename based on the parameters in data.varied.
%
% inputs:
%   data: DynaSim data structure (also accepted: data file name)
%   file_type: file prefix for type of file
%   result_file: previous result_file, only uses this for the path.
%
% outputs:
%   new_result_file: where to save result, based on file_type and data.varied

pathstr = fileparts(old_result_file);

fileName = file_type;

%check for simID# from batch sims
token = regexp(old_result_file, '(sim\d+)', 'tokens');
if ~isempty(token)
  fileName = [fileName '_' token{1}{1}];
end
  
for param = data.varied(:)'
  fileName = [fileName '__' param{1} '_' num2str(data.(param{1}))];
end

new_result_file = fullfile(pathstr, fileName);

end