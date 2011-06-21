using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using FluentBuild.Core;
using FluentBuild.Utilities;

namespace Build
{
    public class Default : FluentBuild.Core.BuildFile
    {
        private readonly BuildFolder outputDirectory;
        private readonly BuildFolder baseDirectory;
        private readonly BuildArtifact mainAssembly;

        public Default()
        {
            MessageLogger.Write("socks", Properties.CurrentDirectory);
            baseDirectory = new BuildFolder(Properties.CurrentDirectory);
            outputDirectory = baseDirectory.SubFolder("output");
            mainAssembly = outputDirectory.File("PhoneIntegration.dll");

            AddTask(CleanAll);
            AddTask(Build);
        }

        private void CleanAll()
        {
            outputDirectory.Delete(OnError.Continue).Create();

        }

        private void Build()
        {
            FileSet sourceFiles = new FileSet()
                                        .Include(baseDirectory.SubFolder("PhoneIntegration"))
                                        .RecurseAllSubDirectories
                                        .Filter("*.cs");
            FileSet libraryFiles = new FileSet()
                                        
                                        .Include(baseDirectory.SubFolder("packages"))
                                        .RecurseAllSubDirectories.Filter("*.dll")
                                        .Exclude(baseDirectory.SubFolder("packages").SubFolder("SqlServerCompact.4.0.8482.1").SubFolder("NativeBinaries").SubFolder("amd64")).Filter("*.dll")
                                        .Exclude(baseDirectory.SubFolder("packages").SubFolder("SqlServerCompact.4.0.8482.1").SubFolder("NativeBinaries").SubFolder("x86")).Filter("*.dll")
                                        .Exclude(baseDirectory.SubFolder("packages").SubFolder("EntityFramework.4.1.10331.0").SubFolder("lib")).Filter("*.dll");
            
            BuildArtifact[] artifaction = new List<BuildArtifact>{
                new BuildArtifact(@"C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0\System.Web.ApplicationServices.dll"),
                new BuildArtifact(@"c:\Program Files\Microsoft ASP.NET\ASP.NET MVC 3\Assemblies\System.Web.Mvc.dll"),
                new BuildArtifact(@"C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0\System.ComponentModel.DataAnnotations.dll"),
                new BuildArtifact(@"C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0\System.Data.Entity.dll")
            }.ToArray();

            using (MessageLogger.ShowDebugMessages)
            {
                FluentBuild.Core.Build.UsingCsc.Target.Library
                    .AddSources(sourceFiles)
                    .AddRefences(libraryFiles.ToBuildArtifacts())
                    .AddRefences(artifaction)
                    .OutputFileTo(mainAssembly)
                    .Execute();
            }
        }
    }
}
