# diy-cromwell-server
A repo containing instructions for running a DIY Cromwell server on an on-prem SLURM cluster at the Fred Hutch.  These instructions were generated for an institution-specific configuration of Cromwell, but could serve as a starting point for other institutions customizing a configuration specific to their HPC infrastructure.  


## Cromwell Resources
Cromwell is a workflow manager developed by the Broad which manages the individual tasks involved in multi-step workflows, tracks job metadata, provides an API/Swagger UI interface and allows users to manage multiple workflows simultaneously.  Cromwell currently runs workflows written in WDL workflow language.  The WDL specification and documentation is curated by the [openWDL group](https://openwdl.org/).


The Fred Hutch Data Science Lab has developed an R Shiny app you can use to monitor your own Cromwell server workflows when you have a Cromwell server if you have users that would benefit from a simple UI.  That repo is here: [shiny-cromwell](https://github.com/FredHutch/shiny-cromwell).  There is also basic R package that wraps the Cromwell API allowing you to submit, monitor and kill workflow jobs to a Cromwell server from R directly. The package is [rcromwell](https://github.com/getwilds/rcromwell).


## Steps to prepare
If you have questions about these steps, please file an issue!   For Fred Hutch users, SciComp and the Data Science Lab have developed a new approach to using Cromwell on Fred Hutch infrastructure that is even simpler than the legacy approach documented here.  

> Note: This information, while specific to Fred Hutch, is considered the "legacy" way to do this, but we're leaving it here in case this is useful for folks at other institutions in setting up their own configuration. Please see the new Fred Hutch approach called "PROOF" on the [Fred Hutch Biomedical Data Science Wiki data science section](https://sciwiki.fredhutch.org/datascience/ds_index/).  

### Rhino Access (one time)
Currently, to run your own Cromwell server you'll need to know how to connect to `rhino` at the Fred Hutch which are the login nodes to the 'gizmo' cluster.  

### Database Setup (one time)
These instructions let you stand up a Cromwell server for 7 days at a time.  If you have workflows that run longer than that or you want to be able to get metadata for or restart jobs even after the server goes down, you'll want an external database to keep track of your progress even if your server goes down (for whatever reason). It also will allow your future workflows to use cached copies of data when the exact task has already been done (and recorded in the database).  We have found as well that by using a MySQL database for your Cromwell server, it will run faster and be better able to handle simultaneous workflows while also making all the metadata available to you during and after the run.  

We currently suggest you go to [DB4Sci](https://mydb.fredhutch.org/login) and see the Wiki entry for DB4Sci [here](https://sciwiki.fredhutch.org/scicomputing/store_databases/#db4sci--previously-mydb).  There, you will login using Fred Hutch credentials, choose `Create DB Container`, and choose the MariaDB option.  The default database container values are typically fine, EXCEPT you likely need either weekly or no backups (no backups preferred) for this database. Save the `DB/Container Name`, `DB Username` and `DB Password` as you will need them for the  configuration step.  Once you click submit, a confirmation screen will appear (hopefully), and you'll need to note which `Port` is specified.  This is a 5 digit number currently.

 Or if you are able to get onto `rhino`, you can do the following to do this process yourself:

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

1.  Decide where you want to keep your Cromwell configuration files.  This must be a place where `rhino` can access them, such as in your `Home` directory, which is typically the default directory when you connect to the `rhinos`.  We suggest you create a `cromwell-home` folder (or whatever you want to call it) and follow these git instructions to clone it directly.


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

> Note:  For this server, you will want multiple cores to allow it to multi-task.  Memory is less important when you use an external database.  If you notice issues, the particular resource request for the server job itself might be a good place to start adjusting, in conjunction with some guidance from peers if you post in the FH-Data Slack [#workflow-managers](https://fhdata.slack.com/archives/CJFP1NYSZ) channel.

4.  Kick off your Cromwell server:

```
## You'll want to put `cromwell.sh` somewhere handy for future use (and very occasionally you might need to update it), we suggest:
cp ./diy-cromwell-server/cromwell.sh .
chmod +x cromwell.sh

# Then simply start up Cromwell:
./cromwell.sh cromUserConfig.txt
```

5.  Much like the `grabnode` command you may have used previously, the script will run and print back to the console instructions once the resources have been provisioned for the server. You should see something like this:
```
Your configuration details have been found...
Getting an updated copy of Cromwell configs from GitHub...
Setting up all required directories...
Detecting existence of AWS credentials...
Credentials found, setting appropriate configuration...
Requesting resources from SLURM for your server...
Submitted batch job 2224761
Your Cromwell server is attempting to start up at http://gizmok53:46287.  It can take up to 2 minutes prior to the port being open for use by the shiny app at https://cromwellapp.fredhutch.org or via the R package rcromwell. If you encounter errors, you may want to check your server logs at /home/username/cromwell-home/server-logs to see if Cromwell was unable to start up.
Go have fun now.
```
> NOTE:  Please write down the url it specifies here.  This is the only place where you will be able to find the particular url for this instance of your Cromwell server, and you'll need that to be able to send jobs to the Crowmell server.  If you forget it, `scancel` the Cromwell server job and start a new one.


6. This url is what you use to submit and monitor workflows with the Shiny app mentioned above.    After you click the "Connect to Server" button, you'll put `http://gizmok30:20201` (or whatever your url is) where it says "My Own Cromwell".

7.  While your server will normally stop after 7 days (the default), at which point if you have jobs still running you can simply restart your server and it will reconnect to existing jobs/workflows.  However, if you need to take down your server for whatever reason before that point, you can go to `rhino` and do:

```
# Here `username` is your Fred Hutch username
squeue -u username
## Or if you want to get fancy:
squeue -o '%.18i %.9P %j %.8T %.10M %.9l %.6C %R' -u username

## You'll see a jobname "cromwellServer".  Next to that will be a JOBID. In this example the JOBID of the server is 50062886.

scancel 50062886

```

> NOTE: For those test workflows that use Docker containers, know that the first time you run them, you may notice that jobs aren't being sent very quickly.  That is because for our cluster, we need to convert those Docker containers to something that can be run by Singularity.  The first time a Docker container is used, it must be converted, but in the future Cromwell will used the cached version of the Docker container and jobs will be submitted more quickly. 


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

## Where do you want to save Cromwell server logs for troubleshooting Cromwell itself?
### Suggestion: ~/home/username/cromwell-home/server-logs
SERVERLOGDIR=~./cromwell-home/server-logs

################ DATABASE CUSTOMIZATIONS #################
## DB4Sci MariaDB details (remove < and >, and use unquoted text):

CROMWELLDBPORT=...
CROMWELLDBNAME=...
CROMWELLDBUSERNAME=...
CROMWELLDBPASSWORD=...

## Number of cores for your Cromwell server itself - usually 4 is sufficient.  
###Increase if you want to run many, complex workflows simultaneously or notice your server is slowing down.
NCORES=4

## Length of time you want the server to run for.  
### Note: when servers go down, all jobs they'd sent will continue.  When you start up a server the next time
### using the same database, the new server will pick up whereever the previous workflows left off.  "7-0" is 7 days, zero hours.
SERVERTIME="7-0" 
```

Contact Amy Paguirigan about these issues for some advice or file an issue on this repo.  

## Task Defaults and Runtime Variables available
For the gizmo backend, the following runtime variables are available that are customized to our configuration.  What is specified below is the current default as written, you can edit these in the config file if you'd like OR you can specify these variables in your `runtime` block in each task to change only the variables you want to change from the default for that particular task.  

- `cpu = 1`
  - An integer number of cpus you want for the task
- `walltime = "18:00:00"`
  - A string of date/time that specifies how many hours/days you want to request for the task
- `memory = 2000`
  - An integer number of MB of memory you want to use for the task
- `partition = "campus-new"`
  - Which partition you want to use, the default is `campus-new` but whatever is in the runtime block of your WDL will overrride this. 
- `modules = ""`
  - A space-separated list of the environment modules you'd like to have loaded (in that order) prior to running the task.  
- `docker = "ubuntu:latest"`
  - A specific Docker container to use for the task.  For the custom Hutch configuration, docker containers can be specified and the necessary conversions (to Singularity) will be performed by Cromwell (not the user).  Note: when docker is used, soft links cannot be used in our filesystem, so workflows using very large datasets may run slightly slower due to the need for Cromwell to copy files rather than link to them.  
- `dockerSL= "ubuntu:latest"`
  - This is a custom configuration for the Hutch that allows users to use docker and softlinks only to specific locations in Scratch.  It is helpful when working with very large files. 
- `account = "radich_j"`
  - This is a custom configuration for the Hutch that allows users to submit jobs to run under different PI cluster accounts if they have multiple collaborators they run workflows for.  Check with `SciComp` if you have this scenario but do not have multiple PI cluster accounts associated with your username.  
