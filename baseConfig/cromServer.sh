#!/bin/bash
#SBATCH --partition=largenode
#SBATCH --cpus-per-task=6
#SBATCH --mem=43G
#SBATCH -N 1

## This script needs three parameters;
## The first is the path to the cromwellParams.sh file that contains your customizations
## The second is the port you'd like to use for the API
## The third is the path to the current config file you'd like to use
 

source /app/Lmod/lmod/lmod/init/bash
module use /app/easybuild/modules/all
module purge

# Read in your custom config parameters
source ${1}

# Load the Cromwell Module
module load cromwell/49-Java-1.8

# All this to make it a little more readable.  Put JDBC connection
# options in a bash array
jdbc_options=(\
  rewriteBatchedStatements=true \
  serverTimezone=UTC \
)

# Then encode for URL (ampersands and all that)
# see here: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
jdbc_connect_params=$(IFS=\& ; echo "${jdbc_options[*]}")

## Basic Working Dir's
# Ensure scratch dir exists
if [ ! -d ${SCRATCHPATH} ]; then
  mkdir -p ${SCRATCHPATH}
fi
# Ensure workflow log dir exists
if [ ! -d ${WORKFLOWLOGDIR} ]; then
  mkdir -p ${WORKFLOWLOGDIR}
fi
# Ensure workflow output dir exists
if [ ! -d ${WORKFLOWOUTPUTSDIR} ]; then
  mkdir -p ${WORKFLOWOUTPUTSDIR}
fi



# Run your server!
java -Xms4g \
    -Dconfig.file=${CROMWELLCONFIG} \
    -DLOG_MODE=pretty \
    -DLOG_LEVEL=INFO \
    -Dbackend.providers.gizmo.config.root=${SCRATCHPATH} \
    -Dworkflow-options.workflow-log-dir=${WORKFLOWLOGDIR} \
    -Dworkflow-options.final_workflow_outputs_dir=${WORKFLOWOUTPUTSDIR} \
    -Ddatabase.db.url=jdbc:mysql://mydb:${CROMWELLDBPORT}/${CROMWELLDBNAME}?${jdbc_connect_params} \
    -Ddatabase.db.user=${CROMWELLDBUSERNAME} \
    -Ddatabase.db.password=${CROMWELLDBPASSWORD} \
    -Dwebservice.port=${2} \
    -jar $EBROOTCROMWELL/cromwell-49.jar \
    server


