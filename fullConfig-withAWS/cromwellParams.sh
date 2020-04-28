################## WORKING DIRECTORY AND PATH CUSTOMIZATIONS ###################
## Where do you want the working directory to be for Cromwell?  
### Suggestion: /fh/scratch/delete90/pilastname_f/cromwell-executions
SCRATCHPATH=/fh/scratch/delete90/pilastname_f/cromwell-executions

## Where do you want logs about individual workflows (not jobs) to be written?
## Note: this is a default for the server and can be overwritten for a given workflow in workflow-options.
### Suggestion: /fh/fast/pilastname_f/cromwell/workflow-logs
WORKFLOWLOGDIR=/fh/fast/pilastname_f/cromwell/workflow-logs

## Where do you want final output files specified by workflows to be copied for your subsequent use?
## Note: this is a default for the server and can be overwritten for a given workflow in workflow-options.
### Suggestion: /fh/fast/pilastname_f/cromwell/outputs
WORKFLOWOUTPUTSDIR=/fh/fast/pilastname_f/cromwell/outputs



############## SINGULARITY CUSTOMIZATIONS
## If you will be using docker containers on Gizmo, where do you want to store 
## your converted Singularity containers for Cromwell as a cache?  
### Suggestion: /fh/scratch/delete90/pilastname_f/cromwell-containers
SINGULARITYCACHEDIR=/fh/scratch/delete90/pilastname_f/cromwell-containers
