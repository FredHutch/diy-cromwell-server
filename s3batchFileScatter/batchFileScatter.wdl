# This workflow takes a tab separated file where each row is a set of data to be used in each 
# of the independent scattered task series that you have as your workflow process.  This file 
# will, for example, have column names `sampleName`, `bamLocation`, and `bedlocation`.  This
# allows you to know that regardless of the order of the columns in your batch file, the correct
# inputs will be used for the tasks you define.  

## This workflow allows the batch file and the inputs to be in AWS S3 storage.  The test data for this 
## workflow are in a publicly accessible bucket, accessible to Fred Hutch on campus users.  It will
## read the batch file from S3 and scatter over the rows of it for each task series in the scatter. 
## In this case, the task series is to go stage any inputs from S3 specified in the batch file to local storage for further analysis
workflow TGR_s3BatchFileScatter {
  # Batch file information
  String s3batchFile

  # Environment modules used
  String awscliModule

call fetchS3Input as fetchBatch {
  input:
    s3Input = s3batchFile,
    modules = awscliModule
}

# Read the contents of the batch file into an Array of objects to scatter over
Array[Object] batchInfo = read_objects(fetchBatch.file)

scatter (job in batchInfo){
  # The variable `job` here is an object that contains the column names from the
  # batch file and a single row of data from that batch file
  # In this case, the `String sampleName` is being assigned the value in the specific 
  # row assigned to `job` in the `sampleName` column.
    String sampleName = job.sampleName
    String bamFile = job.bamLocation
    String bedFile = job.bedLocation

  call fetchS3Input as fetchBam {
  input:
    s3Input = bamFile,
    modules = awscliModule
  }

  call fetchS3Input as fetchBed {
    input:
      s3Input = bedFile,
      modules = awscliModule
  }

## INSERT YOUR WORKFLOW HERE

  }  # End Scatter
# Outputs that will be retained when execution is complete
  output {
    Array[File] outputBam = fetchBam.file
    Array[File] outputBed = fetchBed.file
    }
# End workflow
}

#### TASK DEFINITIONS
task fetchS3Input {
  String s3Input
  String inputBasename = basename(s3Input)
  String modules
  command {
    set -eo pipefail
    aws s3 cp ${s3Input} ${inputBasename}
  }
  runtime {
    modules: "${modules}"
  }
  output {
    File file = "${inputBasename}"
  }
}
