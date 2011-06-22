$framework = '4.0' #set framework version

#settings
properties {
  $build_dir = Split-Path $psake.build_script_file
  $test_runner = "$build_dir\tools\Gallio\Gallio.Echo.exe"
  $output_dir = "$build_dir/output/" 
  $publish_project = "$build_dir/PhoneIntegration/PhoneIntegration.csproj"
  $build_configuration='Release'
  $company = "Wopsle Inc."
  $copyright_year = (Get-Date).Year
  $assembly_info_contents = @"
  			      using System.Reflection;
  			      using System.Runtime.CompilerServices;
  			      using System.Runtime.InteropServices;


			     [assembly: AssemblyTitle("PhoneIntegration")]
			     [assembly: AssemblyConfiguration("$build_configuration")]
			     [assembly: AssemblyCompany("$company")]
			     [assembly: AssemblyProduct("PhoneIntegration")]
			     [assembly: AssemblyCopyright("Copyright ©$copyright_year $company")]

			     [assembly: AssemblyVersion("1.0.0.$Env:BuildNumber")]
			     [assembly: AssemblyFileVersion("1.0.0.$Env:BuildNumber")]
"@
}

task default -depends Test

formatTaskName "---------{0}---------"

task Test -depends Compile, Clean { 
  Write-Host $testMessage -BackgroundColor Red
  & $test_runner $output_dir/*Tests.dll
}

task Compile -depends Clean, SetupVersionInformation { 
  exec { msbuild /p:OutDir=$output_dir /p:Configuration=$build_configuration }
  $compileMessage
}

task SetupVersionInformation {
	Get-ChildItem -Recurse -Include AssemblyInfo.cs | ForEach-Object {
		$assembly_info_contents > $_
	}
}

task createPackage {
	& msbuild /p:Configuration=$build_configuration /p:OutDir=$output_dir /t:Package $publish_project
}

task Clean { 
  
  exec { msbuild /t:Clean }
  $cleanMessage
}