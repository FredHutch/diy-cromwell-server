# diy-cromwell-server
A repo containing instructions for running a Cromwell server on `gizmo` at the Fred Hutch.  These instructions were created and tested by Amy Paguirigan, so drop her a line if they don't work for you or you need help.  Username is `apaguiri`.  


## What is Cromwell?
Cromwell is a workflow manager developed by the Broad which manages the individual tasks involved in multi-step workflows, tracks job metadata, provides an API/Swagger UI interface and allows users to manage multiple workflows simultaneously.  Cromwell currently uses either CWL or WDL workflow languages, and we will focus on WDL workflows for now.  
- [Emerging Cromwell Docs site](https://cromwell.readthedocs.io/en/stable/)

### WDL Resources
These plugins help when you are editing your workflow in Atom or VS Code by color coding and finding errors:
- [WDL Viewer Package](https://atom.io/packages/atom-wdl-viewer) for Atom
- [WDL Syntax Highlighter](https://marketplace.visualstudio.com/items?itemName=broadinstitute.wdl) for VS Code

These relate to the WDL workflow language itself and example workflows to start from:
- [Open WDL](https://github.com/openwdl/wdl) for more about development of WDL as a standard
- [bioWDL](https://biowdl.github.io/) for template workflows relating to bioinformatics/sequencing analysis

These are more Cromwell/Broad oriented instructions and resources:
- Cromwell [GitHub Repo](https://github.com/broadinstitute/cromwell)
- Broad WDL User Guide and tutorials have moved over to the [Terra site](https://support.terra.bio/hc/en-us/sections/360007274612-WDL-Documentation) and thus are a bit in transition
- Some basic Broad [WDL Tutorials](https://support.terra.bio/hc/en-us/sections/360007347652?name=wdl-tutorials)
[GATK Workflows](https://github.com/gatk-workflows?language=wdl)


## Steps to prepare
If you have questions about these steps, feel free to contact Amy Paguirigan (`apaguiri`) or `SciComp`.  

### Rhino Access
Currently, to run your own Cromwell server you'll need to know how to connect to `rhino` at the Fred Hutch.  Read over at [SciWiki](https://sciwiki.fredhutch.org/) in the Scientific Computing section about Access Methods, and Technologies.  

### Database Setup
These instructions let you stand up a Cromwell server with the default maximum wall time on our HPC cluster, which is 3 days.  If you have workflows that run longer than that or you want to be able to get metadata for or restart jobs even after the server goes down, you'll want an external database.  We have found as well that by using a MySQL database for your Cromwell server, it will run faster than a file based database and be better able to handle simultaneous workflows while also making all the metadata available to you during and after the run.  

We currently suggest you go to [DB4Sci](https://mydb.fredhutch.org/login) and see the Wiki entry for DB4Sci [here](https://sciwiki.fredhutch.org/scicomputing/store_databases/#db4sci--previously-mydb).  There, you will login using Fred Hutch credentials, choose `Create DB Container`, and choose the MariaDB option.  The default database container values are typically fine, but do save the `DB/Container Name`, `DB Username` and `DB Password` as you will need them for the  configuration step.  Once you click submit, a confirmation screen will appear (hopefully), and you'll need to note which `Port` is specified.  This is a 5 digit number.  

Once this is complete, you can file a ticket to `scicomp` to request the database to be set up in that container. Or if you are able to get onto `rhino`, you can do the following.  

```
mysql -p -u <DB Username> -h mydb -P <Port>
```
It will then prompt you to enter the DB password you specified during setup.  Once you are are a "mysql>" prompt, you can do the following.
>Note, we suggest you name the database inside the container the same as the container, but you cannot include dashes in your database name.  In the future, DB4Sci may also set up the database inside the container for you, in which case you would be provided a database name as well during setup.
```
mysql> create database <DB Name>
# It should do it's magic
mysql> exit
```

 Then you're ready to go and never have to set up the database part again and you can use this database to manage all your work over time.  

## Server setup instructions
1.  Decide where you want to keep your Cromwell configuration files.  This must be a place where `rhino` can access them, such as in your `Home` directory, which is typically the default directory when you connect to the `rhinos`.  Create a `cromwell` folder (or whatever you want to call it) and save the files in this repo's `config` folder there.  
2.  Tailor your `cromwellParams.sh` file to be specific to your particular server (see suggestions in the file and below).
3.  Adjust, if desired, the resources requested for your server in `cromServer.sh`.  

> Note:  For this server, you will want multiple cores to allow it to multi-task.  Memory is less important when you use an external database.  I have requested one `largenode` for this server but you can request less if you are likely to be only doing one workflow at a time.  

5.  Kick off your server either:

By connecting to `rhino` then:
```
sbatch -o \
    /home/cromwell/serverlogs/%A.txt \
    /home/cromwell/cromServer.sh \
    /home/cromwell/cromwellParams.sh \
    2020
```

> Note:  the second line here will save the output of the actual sbatch'd server job to `/home/cromwell/serverlogs/` with the file name being `jobID`.txt.  This is not required but is helpful initially for you to troubleshoot if your server goes down and you don't know why.  The last line here is the port you want to use for the API - change it to whatever you'd like.

Or from your local R instance using the [fh.wdlR R package](https://github.com/FredHutch/fh.wdlR):

```{r}
require(remotes)
remotes::install_github('FredHutch/fh.wdlR')
library(fh.wdlR)
cromwellCreate(FredHutchId = "username", port = "2020",
        pathToServerLogs = "/some/path/cromwell/serverlogs/%A.txt",
        pathToScript = "/some/path/cromwell/cromServer.sh",
        pathToParams = "/some/path/cromwell/cromwellParams.sh")
# You can use this to confirm that the environment variable was set correctly:
Sys.getenv("CROMWELLURL")
```

If you use the R package, when you use the `cromwellCreate` function it will return the necessary information for using the API via a browser AND will automatically set your `CROMWELLURL` environment variable to the correct location for the remaining job submission and management functions in the R package.  Then you can skip step 6 and do not have to ever connect to `rhino` unless you want to.  


6. For using the API (via a browser, some other method of submission): On `rhino` type: `squeue -u username` to find the list of jobs you have running.  Note the node name (such as `gizmoj30`) that your server job was assigned to.  When you go your browser, you can go to `http://gizmoj30:2020` ("2020" or whatever the webservice port you chose) to use the Swagger UI to submit workflows.  

> Note:  To test your server, you can send the `hello-gizmo` workflow that is in this repo, in the folder `helloHostname`.  


## Design Recommendations for WDL workflows at Fred Hutch
In order to improve sharability and also leverage the R package, as well as future UI based submission tools being developed, we recommend you structure your WDL based workflows with the following input files:

1.  Workflow Description file:  [Example here](/batchFileScatter/batchFileScatter.wdl)
  - in WDL, a list of tools to be run in a sequence, likely several, otherwise using a workflow manager is not the right approach.  
  - This file describes the process that is desired to occur every time the workflow is run.
2.  Parameters file: [Example here](/batchFileScatter/batchFileScatter-params.json)
  - in json, a workflow-specific list of inputs and parameters that are intended to be set for every group of workflow executions.
  - Examples of what this input may include would be which genome to map to, reference data files to use, what environment modules to use, etc.
3.  Batch file:  [Example here](/batchFileScatter/batchFileScatter-batch.json)
  - in csv or tsv, a batch-specific list of the raw input data sets intended to be processed using the same set of inputs/parameters for the same workflow, WITH HEADERS!!
  - This file is a list of data locations and any other sample/job-specific information the workflow needs.  Ideally this would be relatively minimal so that the consistency of the analysis between input data sets are as similar as possible to leverage the strengths of a reproducible workflow.  
4.  Workflow options (OPTIONAL): [Example here](workflow-options.json)
Example:

```
  {
    "workflow_failure_mode": "NoNewCalls",
    "default_runtime_attributes": {
        "maxRetries": 1
    },
    "write_to_cache": true,
    "read_from_cache": true
}
```

Workflow options can be applied to any workflow to tune how the individual instance of the workflow should behave. There are more options than these that can be found in the Cromwell docs site, but of most interest are the following parameters:

- `workflow_failure_mode`: `NoNewCalls` indicates that if one task fails, no new calls will be sent and all existing calls will be allowed to finish.  `ContinueWhilePossible` indicates that even if one task fails, all other task series should be continued until all possible jobs are completed either successfully or not.
- `default_runtime_attributes.maxRetries`: The maximum number of times a job can be retried if it fails in a way that is considered a retryable failure (like if a job gets dumped or the server goes down).
- `write_to_cache`: Do you want to write metadata about this workflow to the database to allow for future use of the cached files it might create?
- `read_from_cache`: Do you want to query the database to determine if portions of this workflow have already completed successfully, thus they do not need to be re-computed.  

## R support
I have a basic R package that wraps the Cromwell API allowing you to submit, monitor and kill workflow jobs on `gizmo` from R directly. It also has a function (`cromwellCreate`) that can help you set up your Cromwell server directly from R assuming your configuration files are saved where `rhino` can reach them and you know their paths. This means that you don't necessarily have to interact with the command line to do workflow submissions again.  The package is [fh.wdlR](https://github.com/FredHutch/fh.wdlR).  

## Workflow Publishing
If you are ok with sharing your workflow for use by others in our community or you would like to get some help making your workflow work, please put your workflow into a GitHub repo in the Fred Hutch organization, with one workflow per repo, the above file structure for workflow, inputs and batch, and a quick README.md explaining what the workflow does, what inputs are needed, what assumptions are made.
> Note:  In the title of the GitHub repo, please include `-wdl` (or `-cwl`) so that others can more easily find your repo and so it will show up in our Fred Hutch Project listing.

## Other Fred Hutch based resources
While additional development is going on to make Cromwell work better in AWS (currently it works well in Google and SLURM among other backends), we are anticipating that it will be more widely available for use with AWS based computing.  To support that there is a growing public data set AWS S3 bucket at `fh-ctr-public-reference-data`.  Contact Amy Paguirigan or Sam Minot if you'd like something to be added here and we can help you do that.  

The Coop Slack [#nextflow channel](https://fhbig.slack.com/archives/CJFP1NYSZ) is currently supporting Nextflow (another workflow manager) users but workflow managers often have similar problems so that community is likely to evolve into a `workflow-manager` group rather than being specifically for Nextflow.  Please go ask questions there for now and tag Amy Paguirigan in them for help.  

### Cromwell Server Customization

In `config/cromwellParams.sh` there are some variables that allow users to share a similar configuration file but tailor the particular behavior of their Cromwell server to best suit them.  The following text is also in this repo but these are the customizations you'll need to decide on for your server.
```
## Where do you want the working directory to be for Cromwell?  
SCRATCHPATH=/fh/scratch/delete90/pilastname_f/cromwell-executions

## Where do you want logs about individual workflows (not jobs) to be written?
WORKFLOWLOGDIR=/fh/fast/pilastname_f/cromwell/workflow-logs

## Where do you want final output files specified by workflows to be copied for your subsequent use?
WORKFLOWOUTPUTSDIR=/fh/fast/pilastname_f/cromwell/outputs

## Where do you want individual task-level logs to be written after a workflow is successful?
WORKFLOWCALLLOGSDIR=/fh/fast/pilastname_f/trgen/Cromwell/outputs

## Where is your configuration file?
CROMWELLCONFIG=/home/fh-slurm-cromwell.config

## DB4Sci MariaDB details:
CROMWELLDBPORT=<DB PORT>
CROMWELLDBNAME=<DB NAME>
CROMWELLDBUSERNAME=<DB USERNAME>
CROMWELLDBPASSWORD=<DB PASSWORD>
```
