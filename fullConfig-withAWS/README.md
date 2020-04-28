# fullConfig-withAWS

This config set up will provide you a Cromwell server on `gizmo` that submits jobs to `gizmo` and uses files in Fast/Scratch OR in AWS S3 but allows you to specify environment modules, OR docker container in which case Singularity will be used to run tasks.

>Note:  This version of the configuration file will NOT run successfully unless you've
already followed the instructions [here](https://sciwiki.fredhutch.org/scicomputing/access_credentials/#amazon-web-services-aws) to create a hidden file in your home dir that this config will look for in
order to start up. That implies also that file inputs in S3 that you want to use in a workflow
are accessible using the particular credentials saved in your home directory.  


## Params update
The following variable needs to be included in your `cromwellParamsh.sh` file if you want to have the option to use Singularity as well as environment modules and to use the config in this directory.

```
############## SINGULARITY CUSTOMIZATIONS #################
## If you will be using docker containers on Gizmo, where do you want to store
## your converted Singularity containers for Cromwell as a cache?  
### Suggestion: /fh/scratch/delete90/pilastname_f/cromwell-containers
SINGULARITYCACHEDIR=/fh/scratch/delete90/pilastname_f/cromwell-containers
````




## Quick git instructions on `rhino`
```
git clone https://github.com/FredHutch/diy-cromwell-server.git

mkdir -p cromwell-home
mkdir -p ./cromwell-home/server-logs

## Initially do this, but once you customize cromwellParams.sh, skip this copy:
cp ./diy-cromwell-server/fullConfig-withAWS/cromwellParams.sh ./cromwell-home/
### Go edit ./cromwell-home/cromwellParams.sh for yourself

sbatch -o \
    ./cromwell-home/server-logscromwell-v49-%A.txt \
    ./diy-cromwell-server/fullConfig-withAWS/cromServer.sh \
    ./cromwell-home/cromwellParams.sh \
    2020 \
    ./diy-cromwell-server/fullConfig-withAWS/fh-slurm-sing-S3-cromwell.conf
```
