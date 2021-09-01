# diy-cromwell-server Test Workflows
Run test workflows in this order:

-  helloHostname
  This workflow simply tests to make sure that your server is set up and the environment of the jobs is a valid working environment.
-  localBatchFileScatter
  This workflow will test access to a publicly available file in our filesystem, the ability of the Cromwell server to parse that file and kick off a scatter of parallel jobs.
-  tg-wdl-VariantCaller
  This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow.  
-  helloSingularityHostname
  This workflow does the same as above but does it with the ubuntu:latest docker container, via Singularity under the hood.
-  tg-wdl-VariantCaller-docker
  This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow using docker containers instead of environment modules.

-  s3batchFileScatter
  This workflow will test access to a publicly available file in an S3 bucket available to all Fred Hutch users, the ability of the Cromwell server to parse that file and kick off a scatter of parallel jobs.
-  tg-wdl-VariantCaller-S3
  This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow using environment modules and also input files from S3.
- tg-wdl-VariantCaller-docker-S3
  This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow using docker containers and also input files from S3.
