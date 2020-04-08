# diy-cromwell-server Test Workflows
Run test workflows in this order:

## For all config versions:
1.  helloHostname
  This workflow simply tests to make sure that your server is set up and the environment of the jobs is a valid working environment.
2.  localBatchFileScatter
  This workflow will test access to a publicly available file in our filesystem, the ability of the Cromwell server to parse that file and kick off a scatter of parallel jobs.
3.  tg-wdl-VariantCaller
  This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow.  
  > Note: this is a duplicate of this repo: [tg-wdl-VariantCaller](https://github.com/FredHutch/tg-wdl-VariantCaller) but is maintained here for simplicity.  



## For singularityConfig version:
4.  helloSingularityHostname
  This workflow does the same as above but does it with the ubuntu:latest docker container, via Singularity.
5.  tg-wdl-VariantCaller-docker
  This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow using docker containers instead of environment modules.  


## For S3InputsConfig version:
6.  s3batchFileScatter
  This workflow will test access to a publicly available file in an S3 bucket available to all Fred Hutch users, the ability of the Cromwell server to parse that file and kick off a scatter of parallel jobs.
7.  tg-wdl-VariantCaller-docker-S3
  This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow using docker containers instead of environment modules and also input files from S3. 
