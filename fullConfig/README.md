# fullConfig

This config set up will provide you a Cromwell server on `gizmo` that submits jobs to `gizmo` and uses files in Fast/Scratch but allows you to specify environment modules, OR docker container in which case Singularity will be used to run tasks.


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
