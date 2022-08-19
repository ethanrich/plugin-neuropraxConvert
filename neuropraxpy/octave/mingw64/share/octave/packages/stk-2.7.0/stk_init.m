% STK_INIT initializes the STK
%
% CALL: stk_init ()
%
% STK_INIT sets paths and environment variables

% Copyright Notice
%
%    Copyright (C) 2015-2018, 2019, 2022 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

%% PKG_ADD: stk_init ('pkg_load');

%% PKG_DEL: stk_init ('pkg_unload');

function output = stk_init (command)

if nargin == 0
    command = 'pkg_load';
end

% Deduce the root of STK from the path to this function
root = fileparts (mfilename ('fullpath'));

switch command
    
    case 'pkg_load'
        stk_init__pkg_load (root);
        
    case 'pkg_unload'
        stk_init__pkg_unload (root);
        
    case 'clear_persistents'
        % Note: this implies munlock
        stk_init__clear_persistents ();
        
    case 'munlock'
        stk_init__munlock ();
        
    case 'addpath'
        % Add STK subdirectories to the search path
        stk_init__addpath (root);
        
    case 'rmpath'
        % Remove STK subdirectories from the search path
        stk_init__rmpath (root);
        
    case 'genpath'
        % Return the list of all STK "public" subdirectories
        output = stk_init__genpath (root);
        
    otherwise
        error ('Unknown command.');
        
end % switch

end % function

%#ok<*NODEF,*WNTAG,*SPERR,*SPWRN,*LERR,*CTCH,*SPERR>


function stk_init__pkg_load (root)

% Unlock all possibly mlock-ed STK files and clear all STK functions
% that contain persistent variables
stk_init__clear_persistents ();

% Add STK subdirectories to the path
stk_init__addpath (root);

% Set default options
stk_options_set ('default');

% Select default "parallelization engine"
stk_parallel_engine_set ();

% Hide some warnings about numerical accuracy
warning ('off', 'STK:stk_predict:NegativeVariancesSetToZero');
warning ('off', 'STK:stk_cholcov:AddingRegularizationNoise');
warning ('off', 'STK:stk_param_relik:NumericalAccuracyProblem');

% Uncomment this line if you want to see a lot of details about the internals
% of stk_dataframe and stk_factorialdesign objects:
% stk_options_set ('stk_dataframe', 'disp_format', 'verbose');

end % function


function stk_init__pkg_unload (root)

% Unlock all possibly mlock-ed STK files and clear all STK functions
% that contain persistent variables
stk_init__clear_persistents ();

% Remove STK subdirectories from the path
stk_init__rmpath (root);

end % function


function stk_init__munlock ()

filenames = {                 ...
    'stk_optim_fmincon',      ...
    'stk_options_set',        ...
    'stk_parallel_engine_set' };

for i = 1:(length (filenames))
    name = filenames{i};
    if mislocked (name)
        munlock (name);
    end
end

end % function


function stk_init__clear_persistents ()

stk_init__munlock ();

filenames = {                 ...
    'stk_disp_progress',      ...
    'stk_disp_getformat',     ...
    'stk_expcov_iso',         ...
    'stk_expcov_aniso',       ...
    'stk_gausscov_iso',       ...
    'stk_gausscov_aniso',     ...
    'stk_materncov_aniso',    ...
    'stk_materncov_iso',      ...
    'stk_materncov32_aniso',  ...
    'stk_materncov32_iso',    ...
    'stk_materncov52_aniso',  ...
    'stk_materncov52_iso',    ...
    'stk_sphcov_iso',         ...
    'stk_sphcov_aniso',       ...
    'stk_optim_fmincon',      ...
    'stk_options_set',        ...
    'stk_parallel_engine_set' ...
    'stk_plot_shadedci'       };

for i = 1:(length (filenames))
    clear (filenames{i});
end

end % function


function stk_init__addpath (root)

path = stk_init__genpath (root);

% Check for missing directories
for i = 1:length (path)
    if ~ exist (path{i}, 'dir')
        error (sprintf (['Directory %s does not exist.\n' ...
            'Is there a problem in stk_init__genpath ?'], path{i}));
    end
end

% Add STK folders to the path
addpath (path{:});

end % function


function path = stk_init__genpath (root)

path = {};

% main function folders
path = [path {                              ...
    fullfile(root, 'arrays'               ) ...
    fullfile(root, 'arrays', 'generic'    ) ...
    fullfile(root, 'core'                 ) ...
    fullfile(root, 'covfcs'               ) ...
    fullfile(root, 'covfcs', 'rbf'        ) ...
    fullfile(root, 'lm'                   ) ...
    fullfile(root, 'model'                ) ...
    fullfile(root, 'model', 'noise'       ) ...
    fullfile(root, 'model', 'prior_struct') ...    
    fullfile(root, 'param', 'classes'     ) ...
    fullfile(root, 'param', 'estim'       ) ...
    fullfile(root, 'sampling'             ) ...
    fullfile(root, 'utils'                ) }];

% 'misc' folder and its subfolders
misc = fullfile (root, 'misc');
path = [path {                 ...
    fullfile(misc, 'design'  ) ...
    fullfile(misc, 'dist'    ) ...
    fullfile(misc, 'distrib' ) ...
    fullfile(misc, 'error'   ) ...
    fullfile(misc, 'optim'   ) ...
    fullfile(misc, 'options' ) ...
    fullfile(misc, 'parallel') ...
    fullfile(misc, 'pareto'  ) ...
    fullfile(misc, 'plot'    ) ...
    fullfile(misc, 'test'    ) ...
    fullfile(misc, 'text'    ) }];

% folders that contain examples
path = [path {                                             ...
    fullfile(root, 'examples', '01_kriging_basics'       ) ...
    fullfile(root, 'examples', '02_design_of_experiments') ...
    fullfile(root, 'examples', '03_miscellaneous'        ) ...
    fullfile(root, 'examples', 'datasets'                ) ...
    fullfile(root, 'examples', 'test_functions'          ) }];

end % function


function stk_init__rmpath (root)

s = path ();

regex1 = strcat ('^', escape_regexp (root));

try
    % Use the modern name (__octave_config_info__) if possible
    apiver = __octave_config_info__ ('api_version');
    assert (ischar (apiver));
catch
    % Use the old name instead
    apiver = octave_config_info ('api_version');
end
regex2 = strcat (escape_regexp (apiver), '$');

while ~ isempty (s)
    
    [d, s] = strtok (s, pathsep);  %#ok<STTOK>
    
    if (~ isempty (regexp (d,  regex1, 'once'))) ...
            && (isempty (regexp (d, regex2, 'once'))) ...
            && (~ strcmp (d, root))  % Only remove subdirectories, not the root
        
        rmpath (d);
        
    end
end

end % function


function s = escape_regexp (s)

s = strrep (s, '\', '\\');
s = strrep (s, '+', '\+');
s = strrep (s, '.', '\.');

end % function
