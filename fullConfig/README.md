# fullConfig

This config set up will provide you a Cromwell server on `gizmo` that submits jobs to `gizmo` using the Bionic nodes.  Workflows can access files in Fast/Scratch (our local filesystem).  It allows you to specify environment modules, OR docker container in which case under the hood, Singularity will be used to run tasks, though that requires no additional setup on your part.  Simply specify the docker container in DockerHub in your task runtime section as normal.  


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
    ./diy-cromwell-server/cromServer.sh \
    ./cromwell-home/cromwellParams.sh \
    2020 \
    ./diy-cromwell-server/fullConfig/fh-cromwell.conf
```
