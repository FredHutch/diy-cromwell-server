# This workflow takes a tab separated file where each row is a set of data to be used in each 
# of the independent scattered task series that you have as your workflow process.  This file 
# will, for example, have column names `sampleName`, `bamLocation`, and `bedlocation`.  This
# allows you to know that regardless of the order of the columns in your batch file, the correct
# inputs will be used for the tasks you define.  

## This workflow allows the batch file (and other inputs) to be in AWS S3 storage. 
workflow s3BatchFileScatter {
  File s3batchFile
  Array[Object] batchInfo = read_objects(s3batchFile)
scatter (job in batchInfo){
  # The variable `job` here is an object that contains the column names from the
  # batch file and a single row of data from that batch file
  # In this case, the `String sampleName` is being assigned the value in the specific 
  # row assigned to `job` in the `sampleName` column.
    String sampleName = job.sampleName
    File bamFile = job.bamLocation
    File bedFile = job.bedLocation

    ## INSERT YOUR WORKFLOW TO RUN PER LINE IN YOUR BATCH FILE HERE!!!!
    call test {
        input: in1=sampleName, in2=bamFile, in3=bedFile
    }
  }  # End Scatter
# Outputs that will be retained when execution is complete
  output {
    Array[File] outputArray = test.item_out
    }
# End workflow
}

#### TASK DEFINITIONS
# echo some text to stdout, treats files as strings just to echo them as a dummy example
task test {
    String in1
    String in2
    String in3
    command {
    echo ${in1}
    echo ${in2}
    echo ${in3}
    }
    output {
        File item_out = stdout()
    }
}
