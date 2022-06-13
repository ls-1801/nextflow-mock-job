#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.file = 'compile.sh'

process splitLetters {
  input:
    path input_file
  output:
    path 'chunk_*'

  """
  do_stuff --runtime quadratic --input $input_file --output chunk_ --n-output 8 --output-ratio 200
  """
}

process convertToUpper {
  input:
    path input_file
  output:
    path 'output1'

  """
  echo $input_file \$(do_stuff --runtime quadratic --input $input_file --output 'output1') 
  """
}

process convertToUpperLinear {
  input:
    path input_file
  output:
    path 'output2'

  """
  echo $input_file \$(do_stuff --runtime linear --input $input_file --output 'output2') 
  """
}

process mergeQuadratic {
  input:
    path input_file1
    path input_file2
  output:
    stdout

  """
  echo $input_file1, $input_file2 \$(do_stuff --runtime quadratic --input $input_file1 --input $input_file2) 
  """
}

workflow {
  data = channel.fromPath(params.file)
  output = splitLetters(data) | flatten

  linear = convertToUpperLinear(output)
  quadratic = convertToUpper(output)

  
  mergeQuadratic(linear, quadratic)
}