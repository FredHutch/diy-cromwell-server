#!/bin/bash
if [ ! -f ${1} ]; then
  echo "Please provide a valid path to your Cromwell personal configuration file."
  exit
fi
source ${1}
if [[ -z $NCORES || -z $SCRATCHDIR || -z $WORKFLOWLOGDIR || -z $WORKFLOWOUTPUTSDIR || -z $SERVERLOGDIR || -z $CROMWELLDBPORT || -z $CROMWELLDBNAME || -z $CROMWELLDBUSERNAME || -z $CROMWELLDBPASSWORD ]]; then 
    echo "One or more of your personal configuration variables is unset, please check your configuration file and try again."
    exit 1
fi
echo "Your configuration details have been found..."
# Setting default servertime if not specified
if [[ -z $SERVERTIME ]]; then 
  SERVERTIME="7-0"
fi

echo "Getting an updated copy of Cromwell configs from GitHub..."
# If the repo already exists, delete it then re-clone a fresh copy
if [ -d "diy-cromwell-server" ]; then rm -Rf diy-cromwell-server; fi
git clone --branch v1.0 https://github.com/FredHutch/diy-cromwell-server.git

echo "Setting up all required directories..."
# If the directory to write server logs to doesn't yet exist, make it.
if [ ! -d $SERVERLOGDIR ]; then
  mkdir -p $SERVERLOGDIR
fi

echo "Requesting resources from SLURM for your server..."
# Submit the server job, and tell it to send netcat info back to port 6000
sbatch --export=MYPORT=6000 --cpus-per-task=$NCORES -N 1 --time=$SERVERTIME --job-name="cromwellServer" \
  --output=$SERVERLOGDIR/cromwell_%A.out\
  ./diy-cromwell-server/cromwellServer.sh ./diy-cromwell-server/fh-S3-cromwell.conf \
  ${1}

nc  -l -p 6000

echo "Go have fun now."