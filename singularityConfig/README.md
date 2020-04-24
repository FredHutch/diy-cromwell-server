# singularityConfig

This config set up will provide you a Cromwell server on `gizmo` that submits jobs to `gizmo` and uses files in Fast/Scratch but allows you to specify a docker container instead of environment modules and Singularity will be used to run the workflow.  

This config also requires additional parameters and adjusted server shell scripts, so the complete set of 3 files is included in this folder for this config.  

## Quick git instructions
```
git clone https://github.com/FredHutch/diy-cromwell-server.git

mkdir ./diy-cromwell-server/singularityConfig/server-logs/

### Go edit ./diy-cromwell-server/singularityConfig/cromwellParams.sh  for yourself

sbatch -o \
    ./diy-cromwell-server/singularityConfig/server-logs/sing-v49-%A.txt \
    ./diy-cromwell-server/singularityConfig/cromServer.sh \
    ./diy-cromwell-server/singularityConfig/cromwellParams.sh \
    2020
```
