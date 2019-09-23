function widefield_toolkit__validate_job_prmts(job_def)
%Function test definitio of trial and conditions if applicable and also against number of
%actual frames.

%%
switch job_def.exp_prmts.experiment_type
    case{'trial_based'}
        expected_frames = compute_expected_number_of_frames(job_def);
    case{'continuous'}
        
    otherwise
        error('Experiment type must be "trial_based" or "continuous" was "%s". \nCheck the parameter file %s used for this job',...
            job_def.exp_prmts.experiment_type,job_def.prmt_file);
end

end

function expected_frames = compute_expected_number_of_frames(job_def)
%% 
exp = job_def.exp_prmts;
expected_frames = exp.n_trials * (exp.n_pre_frames+exp.n_stim_frames+exp.n_post_frames); 
%looks like David each condition

end