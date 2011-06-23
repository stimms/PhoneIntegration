require 'rubygems'
require 'albacore'
require 'rake/clean'

include FileUtils

solution_file = FileList["**/PhoneIntegration.sln"].first
web_project_file = FileList["**/PhoneIntegration.csproj"].first
gallio_test_runner = FileList["**/Gallio.Echo.exe"].first
project_name="PhoneIntegration"
configuration=ENV["configuration"] || :Release
permitted_configurations = ["Staging", "Test", "Production", "Debug"]

CLEAN.include("**/bin", "**/obj", "**/TestResults", "**/output")

task :default => ["build:all"]

task :test => ["test:all"]

namespace :build do
	desc "Build the project"
	msbuild :all => ["util:update_version"] do |msb|
		msb.properties :configuration => configuration, :OutDir => "output/"
		msb.targets :Clean, :Build
		msb.solution = solution_file
		
	end
	task :re => ["clean", "build:all"]
end

namespace :publish do
	desc "Creates the web deployment package"
	msbuild :createPackage => ["build:all"] do |msb|
		msb.properties :configuration => configuration
		msb.targets :Package
		msb.solution = web_project_file
	end
	
	msbuild :createWebConfig, :buildMode do |msb, args|
		msb.properties :configuration => args.buildMode
		msb.solution = web_config_transform_file
	end
	
end

namespace :test do
	desc "Run tests"
	task :all => ["build:all"] do
		tests = FileList["**/bin/**/*.Test*.dll"].join " "
		print "Running tests from #{tests}"
		system "'#{gallio_test_runner}' #{tests}"		
	end
end

namespace :util do
	
	task :update_version do
		FileList["**/AssemblyInfo.cs"].each { |file|
			system "attrib -R \"#{file}\""
			print "File: #{file}\n"
			Rake::Task["util:set_version"].invoke(file)
			Rake::Task["util:set_version"].reenable
		}
	end
	
	assemblyinfo :set_version, :file do |asm, args|
		asm.version = "1.0.0." + ENV['BUILD_NUMBER']
		asm.file_version = "1.0.0." + ENV['BUILD_NUMBER']
		asm.company_name = "Wopsle Inc."
		asm.product_name = "PhoneIntegration"
		asm.copyright = "Wopsle Inc. - #{DateTime.now.year}"
		asm.input_file = args.file
		asm.output_file = args.file
	end
end
