#!/bin/bash
if [ ! -f ${1} ]; then
  echo "Please provide a valid path to your Cromwell personal configuration file."
  exit
fi
source ${1}
if [[ -z $NCORES || -z $SCRATCHDIR || -z $WORKFLOWLOGDIR || -z $SERVERLOGDIR || -z $CROMWELLDBPORT || -z $CROMWELLDBNAME || -z $CROMWELLDBUSERNAME || -z $CROMWELLDBPASSWORD ]]; then 
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
git clone --branch v1.3 https://github.com/FredHutch/diy-cromwell-server.git --quiet

echo "Setting up all required directories..."
# If the directory to write server logs to doesn't yet exist, make it.
if [ ! -d $SERVERLOGDIR ]; then
  mkdir -p $SERVERLOGDIR
fi

# If the user doesn't have AWS credentials then the AWS-naive Cromwell config file needs to be used.
# Note this doesn't check that if the aws credentials exist that they are valid - that occurs when jobs using AWS get created in a workflow.
echo "Detecting existence of AWS credentials..."
if [ -f ~/.aws/credentials ]
then
  echo "Credentials found, setting appropriate configuration..."
  CONFFILE="./diy-cromwell-server/fh-S3-cromwell.conf"
else 
  echo "Credentials not found, setting appropriate configuration..."
  CONFFILE="./diy-cromwell-server/fh-cromwell.conf"
fi

echo "Requesting resources from SLURM for your server..."
# Submit the server job, and tell it to send netcat info back to port 6000
sbatch --export=MYPORT=6000 --cpus-per-task=$NCORES -N 1 --time=$SERVERTIME --job-name="cromwellServer" \
  --output=$SERVERLOGDIR/cromwell_%A.out\
  ./diy-cromwell-server/cromwellServer.sh $CONFFILE \
  ${1}

nc  -l -p 6000

echo "Go have fun now."