
% This function imputes unemployment insurance benefits for different US
% states. Special thanks to L. Pistaferri for sharing advice

% Copyright (C) 2018 Johannes Fleck; https://github.com/Jo-Fleck
% You may use this code for your own work and you may distribute it freely.
% No attribution is required. Please leave this notice and the above URL in the
% source code. Thank you.


function [UI_Ben] = UI_calc(year,state,size,inc)

%% Inputs - need to be in monthly frequency (current USD)
% year: ####
% state: FIPS
% size: 4 or 3 (assume 2 DAs in both cases)
% inc: monthly PER PARENT income (assume identical) before unemployment

% Load param file and add utility folder
load('/Users/main/Documents/Dropbox/!!EUI/Research/insurance_US/material_calcs/US_UI/calculators/!UI_calc/UI_calc_params/UI_params_out.mat','UI_params');
addpath('/Users/main/Documents/GitHubRepos/US_insurance/utilities');

% Convert to quarterly income
inc_pre_UI = 3*inc;

%% Keep params of relevant year and state

yr = num2str(year);
WP = extractfield(UI_params,['WP_' yr])';
WBF1ps = extractfield(UI_params,['WBF1ps_' yr])';
maxben1ps = extractfield(UI_params,['maxben1ps_' yr])';
minben1ps = extractfield(UI_params,['minben1ps_' yr])';
WBF1ps2deps = extractfield(UI_params,['WBF1ps2deps_' yr])';
maxben1ps2deps = extractfield(UI_params,['maxben1ps2deps_' yr])';
minben1ps2deps = extractfield(UI_params,['minben1ps2deps_' yr])';
DA1ps2deps = extractfield(UI_params,['DA1ps2deps_' yr])';

idx_s = State_fips_to_alphanum(state);
WP = WP(idx_s);
WBF1ps = WBF1ps(idx_s);
maxben1ps = maxben1ps(idx_s);
minben1ps = minben1ps(idx_s);
WBF1ps2deps = WBF1ps2deps(idx_s);
maxben1ps2deps = maxben1ps2deps(idx_s);
minben1ps2deps = minben1ps2deps(idx_s);
DA1ps2deps = DA1ps2deps(idx_s);

% States where DA is not additive:
% IA: DA included in WBF_1ps2deps and DA1ps2deps=0 --> all set 
% NJ, RI: DA as % of WB --> use if condition in DA assignment
% [Note: NJ=32(alphanum)=34(fips); RI=40(alphanum)=44(fips)]

%% Impute for different family types

if size == 4        % 1 recipient + 1 recipient with 2 dependents

    % Assign benefits
    B1 = max( min(inc_pre_UI*WBF1ps, maxben1ps), minben1ps);
    
    if idx_s == 32 || idx_s == 40
        B2 = max( min(inc_pre_UI*WBF1ps2deps*(1+DA1ps2deps), maxben1ps2deps), minben1ps2deps);
    else
        B2 = max( min(inc_pre_UI*WBF1ps2deps+DA1ps2deps, maxben1ps2deps), minben1ps2deps);
    end
    
    % Implement WP and round
    UI_B = round( (4 - WP)*(B1+B2) );
        
elseif size == 3    % 1 recipient with 2 dependents
    
    % Assign benefits
    if idx_s == 32 || idx_s == 40
        B = max( min(inc_pre_UI*WBF1ps2deps*(1+DA1ps2deps), maxben1ps2deps), minben1ps2deps);
    else
        B = max( min(inc_pre_UI*WBF1ps2deps+DA1ps2deps, maxben1ps2deps), minben1ps2deps);
    end

    % Implement WP
    UI_B = round( (4 - WP)*B );
    
else 
    
    disp('Family size has to be 3 or 4')
     
end


clearvars -except UI_B

UI_Ben = UI_B;


end