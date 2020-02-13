# This workflow takes a tab separated file where each row is a set of data to be used in each 
# of the independent scattered task series that you have as your workflow process.  This file 
# will, for example, have column names `sampleName`, `bamLocation`, and `bedlocation`.  This
# allows you to know that regardless of the order of the columns in your batch file, the correct
# inputs will be used for the tasks you define.  
workflow parseBatchFile {
  File batchFile
  Array[Object] batchInfo = read_objects(batchFile)
  scatter (job in batchInfo){
    String sampleName = job.sampleName
    File bamLocation = job.bamLocation
    File bedLocation = job.bedLocation

    ## INSERT YOUR WORKFLOW TO RUN PER LINE IN YOUR BATCH FILE HERE!!!!
    call test {
        input: in1=sampleName, in2=bamLocation, in3=bedLocation
    }

  }  # End Scatter over the batch file
# Outputs that will be retained when execution is complete
  output {
    Array[File] outputArray = test.item_out
    }
# End workflow
}

#### TASK DEFINITIONS
# echo some text to stdout
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