# Intro to Workflow Options

## For all config versions:

{
    "workflow_failure_mode": "NoNewCalls",
    "write_to_cache": false,
    "read_from_cache": false
}


### workflows_failure_mode
Options: "NoNewCalls" or "ContinueWhilePossible"
This means, for a workflow, if a task fails, should No New Calls be made and all existing jobs be allowed to finish, OR if all other jobs should Continue While Possible until all jobs that are not dependent on the failed job are completed.


### write_to_cache
Options: True/False
This means, for a workflow, if you want the metadata about completed jobs to be saved in the database as information for possible call caching of those results for future workflows.


### read_from_cache
Options: True/False
This means, for a workflow, if you want the metadata about completed jobs to be READ from in order to identify possible cache hits for the workflow that is running now.  
