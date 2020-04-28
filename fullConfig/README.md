# fullConfig

This config set up will provide you a Cromwell server on `gizmo` that submits jobs to `gizmo` and uses files in Fast/Scratch but allows you to specify environment modules, OR docker container in which case Singularity will be used to run tasks.

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
cp ./diy-cromwell-server/fullConfig/cromwellParams.sh ./cromwell-home/
### Go edit ./cromwell-home/cromwellParams.sh for yourself

sbatch -o \
    ./cromwell-home/server-logs/cromwell-v49-%A.txt \
    ./diy-cromwell-server/fullConfig/cromServer.sh \
    ./cromwell-home/cromwellParams.sh \
    2020 \
    ./diy-cromwell-server/fullConfig/fh-slurm-sing-cromwell.conf
```
