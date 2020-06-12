# fullConfig-withAWS

This config set up will provide you a Cromwell server on `gizmo` that submits jobs to `gizmo` using the Bionic nodes.  Workflows can access files in Fast/Scratch (our local filesystem) or in AWS S3, by specifying either the full path in the filesystem (e.g. `/fh/fast/lastname-f/folder`) or the S3 prefix (e.g. `s3://bucket-name/folder`).  It allows you to specify environment modules, or docker container in which case under the hood, Singularity will be used to run tasks, though that requires no additional setup on your part.  Simply specify the docker container in DockerHub in your task runtime section as normal.  

>Note:  This version of the configuration file will NOT run successfully unless you've
already followed the instructions [here](https://sciwiki.fredhutch.org/scicomputing/access_credentials/#amazon-web-services-aws) to create a hidden file in your home dir that this config will look for in
order to start up. That implies also that file inputs in S3 that you want to use in a workflow
are accessible using the particular credentials saved in your home directory.  



## Quick git instructions on `rhino`
```
git clone https://github.com/FredHutch/diy-cromwell-server.git

mkdir -p cromwell-home
mkdir -p ./cromwell-home/server-logs

## Initially do this, but once you customize cromwellParams.sh, skip this copy:
cp ./diy-cromwell-server/fullConfig-withAWS/cromwellParams.sh ./cromwell-home/
### Go edit ./cromwell-home/cromwellParams.sh for yourself

sbatch -o \
    ./cromwell-home/server-logs/cromwell-v49-%A.txt \
    ./diy-cromwell-server/cromServer.sh \
    ./cromwell-home/cromwellParams.sh \
    2020 \
    ./diy-cromwell-server/fullConfig-withAWS/fh-S3-cromwell.conf
```
