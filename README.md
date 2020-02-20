# diy-cromwell-server
A repo containing instructions for running a Cromwell server on `gizmo` at the Fred Hutch.  These instructions were created and tested by Amy Paguirigan, so drop her a line if they don't work for you or you need help.  Username is `apaguiri`.  
Alternatively, join the discussion in The Coop Slack in the [#cromwell-wdl channel](https://fhbig.slack.com/archives/CTFU13URJ) using your Fred Hutch, UW, SCHARP or Sagebase email.  


## What is Cromwell?
Cromwell is a workflow manager developed by the Broad which manages the individual tasks involved in multi-step workflows, tracks job metadata, provides an API/Swagger UI interface and allows users to manage multiple workflows simultaneously.  Cromwell currently uses either CWL or WDL workflow languages, and we will focus on WDL workflows for now.  
- [Emerging Cromwell Docs site](https://cromwell.readthedocs.io/en/stable/)

### External WDL Resources
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

### Internal WDL/Cromwell Resources
There is a Crowmell entry in our SciWiki that you can refer to to find new resources put up by Fred Hutch researchers.  Also, you can see what is currently available in the FredHutch GitHub institution by using [this link to search results](https://github.com/FredHutch?utf8=%E2%9C%93&q=wdl+OR+cromwell&type=&language=).

Beyond the two basic workflows for testing included in this repository, there is an example, [unpaired variant calling workflow](https://github.com/FredHutch/tg-wdl-unpairedVariantCaller) that can be run by Fred Hutch users on campus that has example data linked vis the inputs json file.

We have also been building other places to find information about both workflow managers being supported at the Fred Hutch via [this GitHub Project](https://github.com/orgs/FredHutch/projects/8).


## Steps to prepare
If you have questions about these steps, feel free to contact Amy Paguirigan (`apaguiri`) or `SciComp`.  

### Rhino Access
Currently, to run your own Cromwell server you'll need to know how to connect to `rhino` at the Fred Hutch.  While Amy has a basic R package for interacting with Cromwell via R, you may likely want to learn how to see what is happening via the `rhinos` so you'll want to read over at [SciWiki](https://sciwiki.fredhutch.org/) in the Scientific Computing section about Access Methods, and Technologies.  If you have never used the local cluster (`rhino`/`gizmo`), you may need to file a ticket by emailing fredhutch email `scicomp` and requesting your account be set up.  To do this you'll need to specify which PI you are sponsored by/work for.  

### Database Setup
These instructions let you stand up a Cromwell server with the default maximum wall time on our HPC cluster, which is 3 days.  If you have workflows that run longer than that or you want to be able to get metadata for or restart jobs even after the server goes down, you'll want an external database.  We have found as well that by using a MySQL database for your Cromwell server, it will run faster than a file based database and be better able to handle simultaneous workflows while also making all the metadata available to you during and after the run.  

We currently suggest you go to [DB4Sci](https://mydb.fredhutch.org/login) and see the Wiki entry for DB4Sci [here](https://sciwiki.fredhutch.org/scicomputing/store_databases/#db4sci--previously-mydb).  There, you will login using Fred Hutch credentials, choose `Create DB Container`, and choose the MariaDB option.  The default database container values are typically fine, but do save the `DB/Container Name`, `DB Username` and `DB Password` as you will need them for the  configuration step.  Once you click submit, a confirmation screen will appear (hopefully), and you'll need to note which `Port` is specified.  This is a 5 digit number currently.

Once this is complete, you can file a ticket to `scicomp` to request the database to be set up in that container.  In the future it might be possible to have this step be part of the DB4Sci setup process but until then, you'll need to do this additional step. Or if you are able to get onto `rhino`, you can do the following to do this process yourself:

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
2.  Tailor your `cromwellParams.sh` file to be specific to your particular server (see suggestions in the [template file itself](https://github.com/FredHutch/diy-cromwell-server/blob/master/config/cromwellParams.sh) and below).
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

> Note:  the second line here will save the output of the actual server job itself to `/home/cromwell/serverlogs/` with the file name being `jobID`.txt.  This is not required but is helpful initially for you to troubleshoot if your server goes down and you don't know why.  The last line here is the port you want to use for the API - change it to whatever you'd like.

Or from your local R instance using the [fh.wdlR R package](https://github.com/FredHutch/fh.wdlR):

```{r}
require(remotes)
remotes::install_github('FredHutch/fh.wdlR')
library(fh.wdlR)
cromwellCreate(FredHutchId = "username", port = "2020",
        pathToServerLogs = "/some/path/cromwell/serverlogs/%A.txt",
        pathToServerScript = "/some/path/cromwell/cromServer.sh",
        pathToParams = "/some/path/cromwell/cromwellParams.sh")
# You can use this to confirm that the environment variable was set correctly:
Sys.getenv("CROMWELLURL")
```

If you use the R package, when you use the `cromwellCreate` function it will return the necessary information for using the API via a browser AND will automatically set your `CROMWELLURL` environment variable to the correct location for the remaining job submission and management functions in the R package.  Then you can skip step 6 and do not have to ever connect to `rhino` unless you want to.  


6. For using the API (via a browser, some other method of submission): On `rhino` type: `squeue -u username` to find the list of jobs you have running.  Note the node name (such as `gizmoj30`) that your server job was assigned to.  When you go your browser, you can go to `http://gizmoj30:2020` ("2020" or whatever the webservice port you chose) to use the Swagger UI to submit workflows.  

> Note:  To test your server, you can send the `hello-gizmo` workflow that is in this repo, in the folder `helloHostname`.  

## Guidance and Support
### Design Recommendations for WDL workflows at Fred Hutch
See our [SciWiki page](https://sciwiki.fredhutch.org/compdemos/Cromwell/) on Cromwell for more about guidance for how to start structuring and building your workflows as well as how to share them with others on campus in a findable way.  

### R support
I have a basic R package that wraps the Cromwell API allowing you to submit, monitor and kill workflow jobs on `gizmo` from R directly. It also has a function (`cromwellCreate`) that can help you set up your Cromwell server directly from R assuming your configuration files are saved where `rhino` can reach them and you know their paths, the example for which is described above. This means that you don't necessarily have to interact with the command line to do workflow submissions again.  The package is [fh.wdlR](https://github.com/FredHutch/fh.wdlR).  

### Other Fred Hutch based resources
While additional development is going on to make Cromwell work better in AWS (currently it works well in Google and SLURM among other backends), we are anticipating that it will be more widely available for use with AWS based computing.  To support that there is a growing public data set AWS S3 bucket at `fh-ctr-public-reference-data`.  Contact Amy Paguirigan or Sam Minot if you'd like something to be added here and we can help you do that.  

## Cromwell Server Customization

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


## Task Defaults and Runtime Variables available
For the gizmo backend, the following runtime variables are available that are customized to our configuration.  What is specified below is the current default as written, you can edit these in the config file if you'd like OR you can specify these variables in your `runtime` block in each task to change only the variables you want to change from the default for that particular task.  

- `Int cpu = 1`
  - An integer number of cpus you want for the task
- `String walltime = "18:00:00"``
  - A string of date/time that specifies how many hours/days you want to request for the task
- `Int memory = 2000`
  - An integer number of MB of memory you want to use for the task
- `String partition = "campus"`
  - Which partition you want to use, currently options are "campus" or "largenode" on `gizmo`
- `String modules = ""`
  - A space separated list of the environment modules you'd like to have loaded (in that order) prior to running the task.  
