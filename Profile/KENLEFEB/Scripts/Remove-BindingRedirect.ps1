function Remove-BindingRedirect {
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [object[]]
        $Project
    )

    process {
        $ProjectDir = Split-Path $Project.FullName

        $ConfigFileName = $Project.ProjectItems | Where-Object { $_.Name -eq 'web.config' -or $_.Name -eq 'app.config' }
        if ($null -ne $ConfigFileName) {    
            $ConfigPath = Join-Path -Path $ProjectDir -ChildPath $ConfigFileName.Name
            $Xml = [xml](Get-Content $ConfigPath)
            $Ns = @{ ms = "urn:schemas-microsoft-com:asm.v1" }

            $Xml | Select-Xml '//ms:assemblyBinding' -Namespace $Ns | ForEach-Object {
                $Xml.configuration.runtime.RemoveChild($_.Node)
            } | Out-Null

            $Xml.Save($ConfigPath)

            Write-Host "Removed bindingRedirects from $ConfigPath"
        }  
        else {
            Write-Host "Couldn't remove bindingRedirects from $($Project.Name) as couldn't find a config file"
        }

        return $Project
    }
}