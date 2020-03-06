#!/bin/bash
#SBATCH --partition=largenode
#SBATCH --cpus-per-task=6
#SBATCH --mem=43G

source /app/Lmod/lmod/lmod/init/bash
module use /app/easybuild/modules/all
module purge

# Read in your custom config parameters
source ${1}
# ${2} is the port you want to open on the node you get for the API

# Load the Cromwell Module you'd like
module load cromwell/49-Java-1.8

# Run your server!
java -Xms4g \
    -Dconfig.file=${CROMWELLCONFIG} \
    -DLOG_MODE=pretty \
    -DLOG_LEVEL=INFO \
    -Dbackend.providers.gizmo.config.root=${SCRATCHPATH} \
    -Dworkflow-options.workflow-log-dir=${WORKFLOWLOGDIR} \
    -Dworkflow-options.final_workflow_log_dir=${WORKFLOWLOGDIR} \
    -Dworkflow-options.final_workflow_outputs_dir=${WORKFLOWOUTPUTSDIR} \
    -Dworkflow-options.final_call_logs_dir=${WORKFLOWCALLOGSDIR} \
    -Ddatabase.db.url=jdbc:mysql://mydb:${CROMWELLDBPORT}/${CROMWELLDBNAME}?rewriteBatchedStatements=true \
    -Ddatabase.db.user=${CROMWELLDBUSERNAME} \
    -Ddatabase.db.password=${CROMWELLDBPASSWORD} \
    -Dwebservice.port=${2} \
    -jar $EBROOTCROMWELL/cromwell-49.jar \
    server


