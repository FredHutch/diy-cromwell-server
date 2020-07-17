#!/bin/bash
#SBATCH --partition=campus-new
#SBATCH --cpus-per-task=4
#SBATCH --time="7-0"
#SBATCH -N 1

## This script needs three parameters;
## The first is the path to the cromwellParams.sh file that contains your customizations
## The second is the port you'd like to use for the API
## The third is the path to the current config file you'd like to use

source /app/lmod/lmod/init/bash
module use /app/modules/all
module purge


### ADD TEST HERE TO CONFIRM THAT .AWS CREDENTIALS ARE AVAILABLE OR THIS WILL FAIL FOR FULLCONFIG-WITHAWS #####

# Read in your custom config parameters
source ${1}

# Load the Cromwell Module
module --ignore-cache load cromwell/52-Java-1.8

# All this to make it a little more readable.  Put JDBC connection
# options in a bash array
jdbc_options=(\
  rewriteBatchedStatements=true \
  serverTimezone=UTC \
)

# Then encode for URL (ampersands and all that)
# see here: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
jdbc_connect_params=$(IFS=\& ; echo "${jdbc_options[*]}")

# Ensure scratch dir exists
if [ ! -d ${SCRATCHDIR} ]; then
  mkdir -p ${SCRATCHDIR}
fi
SCRATCHPATH=${SCRATCHDIR}/cromwell-executions
# Ensure scratch path exists
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

## Singularity specific 
# Ensure Singularity cache dir exists
SINGULARITYCACHEDIR=${SCRATCHPATH}/.singularity-cache
if [ ! -d ${SINGULARITYCACHEDIR} ]; then
  mkdir -p ${SINGULARITYCACHEDIR}
fi
export SINGULARITYCACHEDIR

# Run your server!
java -Xms8g \
    -Dconfig.file=${3} \
    -DLOG_MODE=pretty \
    -DLOG_LEVEL=INFO \
    -Dbackend.providers.gizmo.config.root=${SCRATCHPATH} \
    -Dworkflow-options.workflow-log-dir=${WORKFLOWLOGDIR} \
    -Dworkflow-options.final_workflow_outputs_dir=${WORKFLOWOUTPUTSDIR} \
    -Ddatabase.db.url=jdbc:mysql://mydb:${CROMWELLDBPORT}/${CROMWELLDBNAME}?${jdbc_connect_params} \
    -Ddatabase.db.user=${CROMWELLDBUSERNAME} \
    -Ddatabase.db.password=${CROMWELLDBPASSWORD} \
    -Dwebservice.port=${2} \
    -jar $EBROOTCROMWELL/cromwell-52.jar \
    server


