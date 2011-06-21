using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using FluentBuild.Core;

namespace Build
{
    public static class FileSetExtenstions
    {

        public static BuildArtifact[] ToBuildArtifacts(this FileSet fileset)
        {
            return fileset.Files.Select(x=> new BuildArtifact(x)).ToArray();
        }
    }
}
