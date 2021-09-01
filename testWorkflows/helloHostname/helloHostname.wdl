version 1.0
## This is a test workflow that returns the hostname of the node the job is submitted to as a test for the Gizmo backend. 
workflow hello_hostname {
call hostname {
}
  output {
    File stdout = hostname.out
  }
}

## Task Descriptions
task hostname {
  command {
    echo $(hostname)
  }
  runtime {
  }
  output {
    File out = stdout()
  }
}
