# diy-cromwell-server
A repo containing instructions for running a Cromwell server on `gizmo` at the Fred Hutch.  These instructions were created and tested by Amy Paguirigan, so drop her a line if they don't work for you or you need help.  Fred Hutch username is `apaguiri`.  
Alternatively, join the discussion in The Coop Slack in the [#question-and-answer channel](https://fhbig.slack.com/archives/CD3HGJHJT) using your Fred Hutch, UW, SCHARP or Sagebase email.  


## Cromwell Resources
Cromwell is a workflow manager developed by the Broad which manages the individual tasks involved in multi-step workflows, tracks job metadata, provides an API/Swagger UI interface and allows users to manage multiple workflows simultaneously.  Cromwell currently uses either CWL or WDL workflow languages, and we will focus on WDL workflows for now. [Learn more on the Fred Hutch wiki about using Cromwell at Fred Hutch.](https://sciwiki.fredhutch.org/compdemos/Cromwell/)

You can see what is currently available in the FredHutch GitHub institution by using [this link to search results](https://github.com/FredHutch?utf8=%E2%9C%93&q=wdl+OR+cromwell&type=&language=).

We have also been building other places to find information about both workflow managers being supported at the Fred Hutch via [this GitHub Project](https://github.com/orgs/FredHutch/projects/8).

Amy also made a shiny app you can use to monitor your own Cromwell server workflows when you have a Cromwell server running on `gizmo` that can be found [here](https://cromwellapp.fredhutch.org/).


## Steps to prepare
If you have questions about these steps, feel free to contact Amy Paguirigan (`apaguiri`) or `scicomp`.  

### Rhino Access
Currently, to run your own Cromwell server you'll need to know how to connect to `rhino` at the Fred Hutch. If you have never used the local cluster (`rhino`/`gizmo`), you may need to file a ticket by emailing fredhutch email `scicomp` and requesting your account be set up.  To do this you'll need to specify which PI you are sponsored by/work for.  You also may want to read a bit more about the use of our cluster over at [SciWiki](https://sciwiki.fredhutch.org/) in the Scientific Computing section about Access Methods, and Technologies.  

### Database Setup
These instructions let you stand up a Cromwell server for 7 days at a time.  If you have workflows that run longer than that or you want to be able to get metadata for or restart jobs even after the server goes down, you'll want an external database to keep track of your progress even if your server goes down (for whatever reason). It also will allow your future workflows to use cached copies of data when the exact task has already been done (and recorded in the database).  We have found as well that by using a MySQL database for your Cromwell server, it will run faster and be better able to handle simultaneous workflows while also making all the metadata available to you during and after the run.  

We currently suggest you go to [DB4Sci](https://mydb.fredhutch.org/login) and see the Wiki entry for DB4Sci [here](https://sciwiki.fredhutch.org/scicomputing/store_databases/#db4sci--previously-mydb).  There, you will login using Fred Hutch credentials, choose `Create DB Container`, and choose the MariaDB option.  The default database container values are typically fine, EXCEPT you likely need either weekly or no backups (no backups preferred) for this database. Save the `DB/Container Name`, `DB Username` and `DB Password` as you will need them for the  configuration step.  Once you click submit, a confirmation screen will appear (hopefully), and you'll need to note which `Port` is specified.  This is a 5 digit number currently.

Once this is complete, you can file a ticket to `scicomp` to request the database to be set up in that container.  In the future it might be possible to have this step be part of the DB4Sci setup process but until then, you'll need to do this additional step. Or if you are able to get onto `rhino`, you can do the following to do this process yourself:

```
ml MariaDB/10.5.1-foss-2019b
mysql --host mydb --port <Port> --user <username> --password
```
It will then prompt you to enter the DB password you specified during setup.  Once you are are a "mysql>" prompt, you can do the following.
>Note, we suggest you name the database inside the container the same as the container, but you cannot include dashes in your database name.  In the future, DB4Sci may also set up the database inside the container for you, in which case you would be provided a database name as well during setup.
```
MariaDB [(none)]> create database <DB Name>;
# It should do it's magic
MariaDB [(none)]> exit
```

 Then you're ready to go and never have to set up the database part again and you can use this database to manage all your work over time.

## Server setup instructions

1.  Decide where you want to keep your Cromwell configuration files.  This must be a place where `rhino` can access them, such as in your `Home` directory, which is typically the default directory when you connect to the `rhinos`.  Create a `cromwell-home` folder (or whatever you want to call it) and follow these git instructions to clone it directly.


2.  First set up the customizations per user that you're going to want for your server(s) by making user configuration file(s) in your `cromwell-home` or wherever you find convenient.  You can manage mulitple Cromwell profiles this way by just maintaining different files full of credentials and configuration variables that you want.  

To get started, do the following on `rhino`:
```
mkdir -p cromwell-home
cd cromwell-home
git clone --branch main https://github.com/FredHutch/diy-cromwell-server.git


cp ./diy-cromwell-server/cromUserConfig.txt .
## When you are first setting up Cromwell, you'll need to put all of your User Customizations into this `cromUserConfig.txt` which can serve as a template.  
## After you've done this once, you just need to keep the path to the file(s) handy for the future.  
```

3.  Tailor your `cromUserConfig.txt` file to be specific to your various directories and resources (see notes in the version of the file in this repo).

> Note:  For this server, you will want multiple cores to allow it to multi-task.  Memory is less important when you use an external database.  If you notice issues, the particular resource request for the server job itself might be a good place to start adjusting, in conjunction with some guidance from SciComp or the Slack [Question and Answer channel](https://fhbig.slack.com/archives/CD3HGJHJT) folks.

4.  Kick off your Cromwell server:
```
## You'll want to put `cromwell.sh` somewhere handy for future use, we suggest:
cp ./diy-cromwell-server/cromwell.sh .
chmod +x cromwell.sh

# Then simply start up Cromwell:
./cromwell.sh cromUserConfig.txt
```

5.  Much like the `grabnode` command you may have used previously, the script will run and print back to the console instructions once the resources have been provisioned for the server. You should see something like this:
```
Your configuration details have been found...
Getting an updated copy of Crowmell configs from GitHub...
Cloning into 'tg-cromwell-server'...
remote: Enumerating objects: 196, done.
remote: Counting objects: 100% (196/196), done.
remote: Compressing objects: 100% (179/179), done.
remote: Total 196 (delta 96), reused 109 (delta 13), pack-reused 0
Receiving objects: 100% (196/196), 41.14 KiB | 533.00 KiB/s, done.
Resolving deltas: 100% (96/96), done.
Setting up all required directories...
Requesting resources from SLURM for your server...
Submitted batch job 36391382
Your Cromwell server is attempting to start up on **node/port gizmok30:2020**.  If you encounter errors, you may want to check your server logs at /home/username/cromwell-home/server-logs to see if Cromwell was unable to start up.
Go have fun now.
```
> NOTE:  Please write down the node and port it specifies here.  This is the only place where you will be able to find the particular node/port for this instance of your Cromwell server, and you'll need that to be able to send jobs to the Crowmell server.  If you forget it, `scancel` the Cromwell server job and start a new one.  

6. For using the API (via a browser, some other method of submission), you'll want to keep the node and port number it tells you when you start up a fresh Cromwell server.  When you go your browser, you can go to (for example) `http://gizmok30:2020` ("2020" or whatever the webservice port it told you) to use the Swagger UI to submit workflows.  This node host and port also is what you use to submit and monitor workflows with the Shiny app at [cromwellapp.fredhutch.org](https://cromwellapp.fredhutch.org/) where it says "Current Cromwell host:port", you put `gizmok30:2020`.


7.  See our [Test Workflow folder](https://github.com/FredHutch/diy-cromwell-server/tree/main/testWorkflows) once your server is up and run through the tests specified in the markdown there.

## Guidance and Support
### Monitoring your workflows at Fred Hutch:
I made a shiny app you can use to monitor your own Cromwell server workflows when you have a Cromwell server running on `gizmo` that can be found [here](https://cromwellapp.fredhutch.org/).  If you'd like to roll your own, you can find my shiny app code [here](https://github.com/FredHutch/shiny-cromwell).

### Design Recommendations for WDL workflows at Fred Hutch
See our [SciWiki page](https://sciwiki.fredhutch.org/compdemos/Cromwell/) on Cromwell for more about guidance for how to start structuring and building your workflows as well as how to share them with others on campus in a findable way.  

### R support
I have a basic R package that wraps the Cromwell API allowing you to submit, monitor and kill workflow jobs on `gizmo` from R directly. The package is [fh.wdlR](https://github.com/FredHutch/fh.wdlR).  

### Other Fred Hutch based resources
While additional development is going on to make Cromwell work better in AWS (currently it works well in Google and SLURM among other backends), we are anticipating that it will be more widely available for use with AWS based computing.  To support that there is a growing public data set AWS S3 bucket at `fh-ctr-public-reference-data`.  Contact Amy Paguirigan if you'd like something to be added here and we can help you do that.  

## Cromwell Server Customization

In `cromUserConfig.txt` there are some variables that allow users to share a similar configuration file but tailor the particular behavior of their Cromwell server to best suit them.  The following text is also in this repo but these are the customizations you'll need to decide on for your server.
```
################## WORKING DIRECTORY AND PATH CUSTOMIZATIONS ###################
## Where do you want the working directory to be for Cromwell (note: this process will create a subdirectory here called "cromwell-executions")?  
### Suggestion: /fh/scratch/delete90/pilastname_f/username/
SCRATCHDIR=/fh/scratch/delete90/...

## Where do you want logs about individual workflows (not jobs) to be written?
## Note: this is a default for the server and can be overwritten for a given workflow in workflow-options.
### Suggestion: /fh/fast/pilastname_f/cromwell/workflow-logs
WORKFLOWLOGDIR=~/cromwell-home/workflow-logs

## Where do you want final output files specified by workflows to be copied for your subsequent use?
## Note: this is a default for the server and can be overwritten for a given workflow in workflow-options.
### Suggestion: /fh/fast/pilastname_f/cromwell/outputs
WORKFLOWOUTPUTSDIR=/fh/scratch/delete90/...

## Where do you want to save Cromwell server logs for troubleshooting Cromwell itself?
### Suggestion: ~/home/username/cromwell-home/server-logs
SERVERLOGDIR=~./cromwell-home/server-logs

################ DATABASE CUSTOMIZATIONS #################
## DB4Sci MariaDB details (remove < and >, and use unquoted text):

CROMWELLDBPORT=...
CROMWELLDBNAME=...
CROMWELLDBUSERNAME=...
CROMWELLDBPASSWORD=...

NCORES=4

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
  - Which partition you want to use, currently the only Bionic option is `campus-new`
- `String modules = ""`
  - A space-separated list of the environment modules you'd like to have loaded (in that order) prior to running the task.  
