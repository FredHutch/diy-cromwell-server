# diy-cromwell-server
A repo containing instructions for running a Cromwell server on `gizmo` at the Fred Hutch.  These instructions were created and tested by Amy Paguirigan, so drop her a line if they don't work for you or you need help.  Username is `apaguiri`.  
Alternatively, join the discussion in The Coop Slack in the [#cromwell-wdl channel](https://fhbig.slack.com/archives/CTFU13URJ) using your Fred Hutch, UW, SCHARP or Sagebase email.  


## Cromwell Resources
Cromwell is a workflow manager developed by the Broad which manages the individual tasks involved in multi-step workflows, tracks job metadata, provides an API/Swagger UI interface and allows users to manage multiple workflows simultaneously.  Cromwell currently uses either CWL or WDL workflow languages, and we will focus on WDL workflows for now. [Learn more on the Fred Hutch wiki about using Cromwell at Fred Hutch.](https://sciwiki.fredhutch.org/compdemos/Cromwell/)

You can see what is currently available in the FredHutch GitHub institution by using [this link to search results](https://github.com/FredHutch?utf8=%E2%9C%93&q=wdl+OR+cromwell&type=&language=).

We have also been building other places to find information about both workflow managers being supported at the Fred Hutch via [this GitHub Project](https://github.com/orgs/FredHutch/projects/8).

Amy also made a shiny app you can use to monitor your own Cromwell server workflows when you have a Cromwell server running on `gizmo` that can be found [here](https://cromwellapp.fredhutch.org/).


## Steps to prepare
If you have questions about these steps, feel free to contact Amy Paguirigan (`apaguiri`) or `scicomp`.  

### Rhino Access
Currently, to run your own Cromwell server you'll need to know how to connect to `rhino` at the Fred Hutch.  While [Amy has a basic R package](https://github.com/FredHutch/fh.wdlR) for interacting with Cromwell via R, you may likely want to learn how to see what is happening via the `rhinos` so you'll want to read over at [SciWiki](https://sciwiki.fredhutch.org/) in the Scientific Computing section about Access Methods, and Technologies.  If you have never used the local cluster (`rhino`/`gizmo`), you may need to file a ticket by emailing fredhutch email `scicomp` and requesting your account be set up.  To do this you'll need to specify which PI you are sponsored by/work for.  

### Database Setup
These instructions let you stand up a Cromwell server for 7 days at a time.  If you have workflows that run longer than that or you want to be able to get metadata for or restart jobs even after the server goes down, you'll want an external database to keep track of your progress even if your server goes down (for whatever reason). It also will allow your future workflows to use cached copies of data when the exact task has already been done (and recorded in the database).  We have found as well that by using a MySQL database for your Cromwell server, it will run faster and be better able to handle simultaneous workflows while also making all the metadata available to you during and after the run.  

We currently suggest you go to [DB4Sci](https://mydb.fredhutch.org/login) and see the Wiki entry for DB4Sci [here](https://sciwiki.fredhutch.org/scicomputing/store_databases/#db4sci--previously-mydb).  There, you will login using Fred Hutch credentials, choose `Create DB Container`, and choose the MariaDB option.  The default database container values are typically fine, but do save the `DB/Container Name`, `DB Username` and `DB Password` as you will need them for the  configuration step.  Once you click submit, a confirmation screen will appear (hopefully), and you'll need to note which `Port` is specified.  This is a 5 digit number currently.

Once this is complete, you can file a ticket to `scicomp` to request the database to be set up in that container.  In the future it might be possible to have this step be part of the DB4Sci setup process but until then, you'll need to do this additional step. Or if you are able to get onto `rhino`, you can do the following to do this process yourself:

```
mysql --host mydb --port <Port> --user <username> --password
```
It will then prompt you to enter the DB password you specified during setup.  Once you are are a "mysql>" prompt, you can do the following.
>Note, we suggest you name the database inside the container the same as the container, but you cannot include dashes in your database name.  In the future, DB4Sci may also set up the database inside the container for you, in which case you would be provided a database name as well during setup.
```
mysql> create database <DB Name>;
# It should do it's magic
mysql> exit
```

 Then you're ready to go and never have to set up the database part again and you can use this database to manage all your work over time.

## Server setup instructions

1.  Decide where you want to keep your Cromwell configuration files.  This must be a place where `rhino` can access them, such as in your `Home` directory, which is typically the default directory when you connect to the `rhinos`.  Create a `cromwell` folder (or whatever you want to call it) and save the files contained in this GitHub repo OR follow these git instructions to clone it directly.

### Quick git instructions on `rhino`
```
cd <to wherever you'd like to put all of your Cromwell stuff>

git clone https://github.com/FredHutch/diy-cromwell-server.git

# Makes a directory for your server logs and customization files
mkdir -p cromwell-home
mkdir -p ./cromwell-home/server-logs

## Initially do this, but once you customize cromwellParams.sh, skip this step:
cp ./diy-cromwell-server/cromwellParams.sh ./cromwell-home/
```

2.  Tailor your `cromwellParams.sh` file to be specific to your particular server (see notes in the version of the file in this repo).
3.  Adjust, if desired, the memory and cpu resources requested for your server in `cromServer.sh`.  

> Note:  For this server, you will want multiple cores to allow it to multi-task.  Memory is less important when you use an external database.  If you notice issues, the particular resource request for the server job itself might be a good place to start adjusting, in conjunction with some guidance from SciComp or the Slack WDL channel folks.

5.  Kick off your Cromwell server by either:

Connecting to `rhino` then (note:  change the port from `2020` here to whatever you'd like it to be, just remember it!):
```
cd <to wherever you'd like to put all of your Cromwell stuff>

sbatch -o \
    ./cromwell-home/server-logs/cromwell-v49-%A.txt \
    ./diy-cromwell-server/cromServer.sh \
    ./cromwell-home/cromwellParams.sh \
    2020 \
    ./diy-cromwell-server/fullConfig/fh-cromwell.conf
```
If you'd like to use file inputs in AWS S3 and you have AWS credentials saved in your home directory, then do this:
```
cd <to wherever you'd like to put all of your Cromwell stuff>

sbatch -o \
    ./cromwell-home/server-logs/cromwell-v49-%A.txt \
    ./diy-cromwell-server/cromServer.sh \
    ./cromwell-home/cromwellParams.sh \
    2020 \
    ./diy-cromwell-server/fullConfig-withAWS/fh-S3-cromwell.conf
```


> Note:  the second line of these sbatch commands will save the output of the actual server job itself to `./cromwell-home/server-logs/` with the file name being `cromwell-v49-jobID.txt`.  This is not required but is helpful initially for you to troubleshoot if your server goes down and you don't know why.  The number on the fourth line is the port you want to use for the API - change it to whatever you'd like.  The last line is the path to the config file you downloaded.

Or from your local R instance using the [fh.wdlR R package](https://github.com/FredHutch/fh.wdlR), using the correct path to the configuration file you'd like to use (either the fullConfig or fullConfig-withAWS):

```{r}
require(remotes)
remotes::install_github('FredHutch/fh.wdlR')
library(fh.wdlR)
cromwellCreate(FredHutchId = "username", port = "2020",
        pathToServerLogs = "/some/path/cromwell-home/server-logs/%A.txt",
        pathToServerScript = "/some/path/cromwell-home/cromServer.sh",
        pathToParams = "/some/path/cromwell-home/cromwellParams.sh",
        pathToConfig = "/some/path/cromwell-home/fh-cromwell.conf")
# You can use this to confirm that the environment variable was set correctly:
Sys.getenv("CROMWELLURL")
```

If you use the R package, when you use the `cromwellCreate` function it will return the necessary information for using the API via a browser AND will automatically set your `CROMWELLURL` environment variable to the correct location for the remaining job submission and management functions in the R package.  Then you can skip step 6 and do not have to ever connect to `rhino` unless you want to.  


6. For using the API (via a browser, some other method of submission): On `rhino` type: `squeue -u username` to find the list of jobs you have running.  Note the node name (such as `gizmok30`) that your server job was assigned to.  When you go your browser, you can go to `http://gizmok30:2020` ("2020" or whatever the webservice port you chose) to use the Swagger UI to submit workflows.  This node host and port also is what you use to submit and monitor workflows with the Shiny app at [cromwellapp.fredhutch.org](https://cromwellapp.fredhutch.org/) where it says "Current Cromwell host:port", you put `gizmok30:2020`.


7.  See our [Test Workflow folder](https://github.com/FredHutch/diy-cromwell-server/tree/master/testWorkflows) once your server is up and run through the tests specified in the markdown there.

## Guidance and Support
### Monitoring your workflows at Fred Hutch:
Amy also made a shiny app you can use to monitor your own Cromwell server workflows when you have a Cromwell server running on `gizmo` that can be found [here](https://cromwellapp.fredhutch.org/).  If you'd like to roll your own, you can find her shiny app code [here](https://github.com/FredHutch/shiny-cromwell).

### Design Recommendations for WDL workflows at Fred Hutch
See our [SciWiki page](https://sciwiki.fredhutch.org/compdemos/Cromwell/) on Cromwell for more about guidance for how to start structuring and building your workflows as well as how to share them with others on campus in a findable way.  

### R support
I have a basic R package that wraps the Cromwell API allowing you to submit, monitor and kill workflow jobs on `gizmo` from R directly. It also has a function (`cromwellCreate`) that can help you set up your Cromwell server directly from R assuming your configuration files are saved where `rhino` can reach them and you know their paths, the example for which is described above. This means that you don't necessarily have to interact with the command line to do workflow submissions again.  The package is [fh.wdlR](https://github.com/FredHutch/fh.wdlR).  

### Other Fred Hutch based resources
While additional development is going on to make Cromwell work better in AWS (currently it works well in Google and SLURM among other backends), we are anticipating that it will be more widely available for use with AWS based computing.  To support that there is a growing public data set AWS S3 bucket at `fh-ctr-public-reference-data`.  Contact Amy Paguirigan or Sam Minot if you'd like something to be added here and we can help you do that.  

## Cromwell Server Customization

In `cromwellParams.sh` there are some variables that allow users to share a similar configuration file but tailor the particular behavior of their Cromwell server to best suit them.  The following text is also in this repo but these are the customizations you'll need to decide on for your server.
```
################## WORKING DIRECTORY AND PATH CUSTOMIZATIONS ###################
## Where do you want the working directory to be for Cromwell?  
### Suggestion: /fh/scratch/delete90/pilastname_f/cromwell-executions
SCRATCHPATH=/fh/scratch/delete90/pilastname_f/cromwell-executions

## Where do you want logs about individual workflows (not jobs) to be written?
## Note: this is a default for the server and can be overwritten for a given workflow in workflow-options.
### Suggestion: /fh/fast/pilastname_f/cromwell/workflow-logs
WORKFLOWLOGDIR=/fh/fast/pilastname_f/cromwell/workflow-logs

## Where do you want final output files specified by workflows to be copied for your subsequent use?
## Note: this is a default for the server and can be overwritten for a given workflow in workflow-options.
### Suggestion: /fh/fast/pilastname_f/cromwell/outputs
WORKFLOWOUTPUTSDIR=/fh/fast/pilastname_f/cromwell/outputs


################ DATABASE CUSTOMIZATIONS #################
## DB4Sci MariaDB details (remove < and >, and use unquoted text):
CROMWELLDBPORT=<DB PORT>
CROMWELLDBNAME=<DB NAME>
CROMWELLDBUSERNAME=<DB USER>
CROMWELLDBPASSWORD=<DB PASSWORD>

```
Whether these customizations are done user-by-user or lab-by-lab depend on how your group wants to interact with workflows and data.  Also, as there are additional features provided in the additional config's we provide, there may be additional customization parameters that you'll need.  Check the config directories to see if there are additional copies of those files and associated server shell scripts.  If they are absent that means you can use the base setup.  Contact Amy Paguirigan about these issues for some advice.  

## Task Defaults and Runtime Variables available
For the gizmo backend, the following runtime variables are available that are customized to our configuration.  What is specified below is the current default as written, you can edit these in the config file if you'd like OR you can specify these variables in your `runtime` block in each task to change only the variables you want to change from the default for that particular task.  

- `Int cpu = 1`
  - An integer number of cpus you want for the task
- `String walltime = "18:00:00"`
  - A string of date/time that specifies how many hours/days you want to request for the task
- `Int memory = 2000`
  - An integer number of MB of memory you want to use for the task
- `String partition = "campus-new"`
  - Which partition you want to use, currently options are "campus" or "largenode" on `gizmo`
- `String modules = ""`
  - A space separated list of the environment modules you'd like to have loaded (in that order) prior to running the task.  
