################## WORKING DIRECTORY AND PATH CUSTOMIZATIONS ###################
## Where do you want the working directory to be for Cromwell (note: this process will create a subdirectory here called "cromwell-executions")?  
### Suggestion: /fh/scratch/delete90/pilastname_f/username
SCRATCHDIR=/fh/scratch/delete90/pilastname_f/username

## Where do you want logs about individual workflows (not jobs/tasks) to be written?
## Note: this is a default for the server and can be overwritten for a given workflow by specifying this in the workflow options json.
### Suggestion: /fh/fast/pilastname_f/cromwell/workflow-logs
WORKFLOWLOGDIR=/fh/fast/pilastname_f/cromwell/workflow-logs

## Where do you want final output files specified by workflows to be copied for your subsequent use?
## Note: this is a default for the server and can be overwritten for a given workflow by specifying this in the workflow options json.
### Suggestion: /fh/fast/pilastname_f/cromwell/outputs
WORKFLOWOUTPUTSDIR=/fh/fast/pilastname_f/cromwell/outputs


################ DATABASE CUSTOMIZATIONS #################
## DB4Sci MariaDB details (remove < and >, and use unquoted text):
CROMWELLDBPORT=<DB PORT>
CROMWELLDBNAME=<DB NAME>
CROMWELLDBUSERNAME=<DB USER>
CROMWELLDBPASSWORD=<DB PASSWORD>