# diy-cromwell-server Test Workflows
Run test workflows in this order:

## For all config versions:
1.  helloHostname
  This workflow simply tests to make sure that your server is set up and the environment of the jobs is a valid working environment.
2.  localBatchFileScatter
  This workflow will test access to a publicly available file in our filesystem, the ability of the Cromwell server to parse that file and kick off a scatter of parallel jobs.
3.  [tg-wdl-VariantCaller](https://github.com/FredHutch/tg-wdl-VariantCaller)
  This workflow is in a separate repo and tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow.  
