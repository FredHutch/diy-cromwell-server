## Read in a batch file from S3 and scatter over it using local `Gizmo` compute resources
## Will also stage any inputs from S3 specified in the batch file to local storage for further analysis
workflow TGR_s3BatchFileScatter {
  # Batch file information
  String s3batchFile

  # Environment modules used
  String awscliModule

call fetchS3Input as fetchBatch {
  input:
    s3Input = s3batchFile,
    awscliModule = awscliModule
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
    awscliModule = awscliModule
  }

  call fetchS3Input as fetchBed {
    input:
      s3Input = bedFile,
      awscliModule = awscliModule
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
  String awscliModule
  command {
    set -eo pipefail
    module load ${awscliModule}
    aws s3 cp ${s3Input} ${inputBasename}
  }
  runtime {
  }
  output {
    File file = "${inputBasename}"
  }
}
