$framework = '4.0' #set framework version

properties {
  $build_dir = Split-Path $psake.build_script_file
  $test_runner = "$build_dir\tools\Gallio\Gallio.Echo.exe"
  $output_dir = "$build_dir/output/" 
  $build_configuration='Release'
  $testMessage = 'Executed Test!'
  $compileMessage = 'Executed Compile!'
  $cleanMessage = 'Executed Clean!'
}

task default -depends Test

formatTaskName "---------{0}---------"

task Test -depends Compile, Clean { 
  Write-Host $testMessage -BackgroundColor Red
  & $test_runner $output_dir/*Tests.dll
}

task Compile -depends Clean { 
  exec { msbuild /p:OutDir=$output_dir /p:Configuration=$build_configuration }
  $compileMessage
}

task Clean { 
  
  exec { msbuild /t:Clean }
  $cleanMessage
}

task ? -Description "Helper to display task info" {
	Write-Documentation
}