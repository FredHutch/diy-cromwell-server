#!/bin/bash
source /app/lmod/lmod/init/bash
module use /app/modules/all

# grab all your customization variables for this env
source ${2}

# run this python chunk to find an open port on the node
ml Python

CROMWELLPORT=$( python3 <<CODE
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 0))
addr = s.getsockname()
print(addr[1])
s.close()
CODE
)
# send this port and hostname back to the user
echo "Your Cromwell server is attempting to start up on node/port $(hostname):$CROMWELLPORT.  \
If you encounter errors, you may want to check your server logs at "$SERVERLOGDIR" to see if Cromwell was unable to start up." | nc -N  ${SLURM_SUBMIT_HOST} ${MYPORT}

# Clean the env
module purge
# Load the Cromwell Module
module --ignore-cache load cromwell/57-Java-1.8

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
# Ensure Singularity cache dir exists
SINGULARITYCACHEDIR=${SCRATCHPATH}/.singularity-cache
if [ ! -d ${SINGULARITYCACHEDIR} ]; then
  mkdir -p ${SINGULARITYCACHEDIR}
fi
export SINGULARITYCACHEDIR

# Run your server!
java -Xms28g -Xmx31g \
    -XX:+UseParallelGC \
    -XX:ParallelGCThreads=${NCORES} \
    -Dconfig.file=${1} \
    -DLOG_MODE=pretty \
    -DLOG_LEVEL=WARN \
    -Dbackend.providers.gizmo.config.root=${SCRATCHPATH} \
    -Dworkflow-options.workflow-log-dir=${WORKFLOWLOGDIR} \
    -Ddatabase.db.url=jdbc:mysql://mydb:${CROMWELLDBPORT}/${CROMWELLDBNAME}?${jdbc_connect_params} \
    -Ddatabase.db.user=${CROMWELLDBUSERNAME} \
    -Ddatabase.db.password=${CROMWELLDBPASSWORD} \
    -Dwebservice.port=${CROMWELLPORT} \
    -jar $EBROOTCROMWELL/cromwell-57.jar \
    server

