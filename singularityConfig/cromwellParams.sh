## Where is your configuration file?
### Suggestion: /fh/fast/pilastname_f/cromwell/fh-slurm-sing-cromwell.conf
CROMWELLCONFIG=/fh/fast/pilastname_f/cromwell/fh-slurm-sing-cromwell.conf

## Where do you want the working directory to be for Cromwell?  
### Suggestion: /fh/scratch/delete90/pilastname_f/cromwell-executions
SCRATCHPATH=/fh/scratch/delete90/pilastname_f/cromwell-executions

## If you will be using docker containers on Gizmo, where do you want to store 
## your converted Singularity containers for Cromwell as a cache?  
### Suggestion: /fh/scratch/delete90/pilastname_f/cromwell-containers
SINGULARITYCACHEDIR=/fh/scratch/delete90/pilastname_f/cromwell-containers

## DB4Sci MariaDB details (remove < and >, and use unquoted text):
CROMWELLDBPORT=<DB PORT>
CROMWELLDBNAME=<DB NAME>
CROMWELLDBUSERNAME=<DB USER>
CROMWELLDBPASSWORD=<DB PASSWORD>

## Where do you want logs about individual workflows (not jobs) to be written?
## Note: this is a default for the server and can be overwritten for a given workflow in workflow-options.
### Suggestion: /fh/fast/pilastname_f/cromwell/workflow-logs
WORKFLOWLOGDIR=/fh/fast/pilastname_f/cromwell/workflow-logs

## Where do you want final output files specified by workflows to be copied for your subsequent use?
## Note: this is a default for the server and can be overwritten for a given workflow in workflow-options.
### Suggestion: /fh/fast/pilastname_f/cromwell/outputs
WORKFLOWOUTPUTSDIR=/fh/fast/pilastname_f/cromwell/outputs
