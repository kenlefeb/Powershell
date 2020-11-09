
<#
 .Synopsis
  Deletes a Git Worktree.

 .Description
  Deletes the Git Worktree for the repository containing the current working location.

 .Parameter KeepBranch
  A switch that determines whether to keep the branch or delete it (by default).

 .Parameter WhatIf
  A switch that determines whether to actually delete the worktree, or just report on
  what _would_ be done with the supplied parameters.

 .Example
   # Delete the current worktree and its associated branch
   Remove-Worktree

 .Example
   # Delete the current worktree but not its associated branch
   Remove-Worktree -KeepBranch

#>
Function Remove-Worktree(
    [switch] $KeepBranch,
    [switch] $WhatIf
) {

    $master = $GitWorktreesSettings['default-branch']
    $branch = Get-CurrentBranch
    $path = (Get-Worktrees)[$branch]

    if ($WhatIf) {
        Write-Host "Set-Location $((Get-Worktrees)[$master])"
    }
    else {
        Set-Location (Get-Worktrees)[$master]
    }

    $path = Resolve-Path $path -Relative

    $command = "git worktree remove $path"

    if ($WhatIf) {
        Write-Host $command
    }
    else {
        Invoke-Expression $command
    }

    if (!$KeepBranch) {

        $command = "git branch -D $branch"

        if ($WhatIf) {
            Write-Host $command
        }
        else {
            Invoke-Expression $command
        }
    }

}

<#
 .Synopsis
  Pulls the Default Branch from its Default Remote.

 .Description
 Temporarily switches to the worktree for the default branch (e.g., "master"), issues a git pull command, then switches back to previous location. 

 .Example
   # Pull Master
   Sync-DefaultBranch
#>
Function Sync-DefaultBranch(
    [switch] $WhatIf
) {

    $master = $GitWorktreesSettings['default-branch']
    $location = Get-Location

    if ($WhatIf) {
        Write-Host "Set-Location $(Get-PathString (Get-Worktrees)[$master])"
    }
    else {
        Set-Location (Get-Worktrees)[$master]
    }

    $command = 'git pull'

    if ($WhatIf) {
        Write-Host $command
    }
    else {
        Invoke-Expression $command
    }

    if ($WhatIf) {
        Write-Host "Set-Location $location"
    }
    else {
        Set-Location $location
    }
}

<#
 .Synopsis
  Retrieves a dictionary of current Git Worktrees.

 .Description
 Queries Git for a list of all current Worktrees and constructs a dictionary of each worktree
 wherein the key is the name of the branch in the worktree, and the value is the full path to the worktree. 

 .Example
   # Show a table of each current worktree
   Get-Worktrees
#>
Function Get-Worktrees {

    $branch = (git branch --show-current)

    if ($null -eq $branch) {
        Write-Error 'You are not currently in a Git repository.'
        Return
    }

    $list = (git worktree list)

    $lines = $list | Select-String -Pattern '(?<path>.*?)\s+(?<hash>[\da-f]+)\s\[(?<branch>.*)\]' -AllMatches

    $worktrees = @{};

    foreach ($line in $lines.Matches) {
        $branch = $line.Groups['branch'].Value
        $path = Resolve-Path $line.Groups['path'].Value
        $worktrees[$branch] = $path
    }

    $worktrees
}

<#
 .Synopsis
  Determines what the next worktree directory ought to be.

 .Description
  Using a lowercase alphabet, this function will determine the next character that is valid to be git worktree, 
  as a peer to the repository root directory (e.g., where the "master" branch resides).

 .Example
   # If there are no worktrees other than the "master" branch, Get-NextWorktreeDirectory will usually return 'a'.
   Get-NextWorktreeDirectory
#>
Function Get-NextWorktreeDirectory {

    $previous = Get-Location

    Set-Location (Get-Worktrees)['master']

    Set-Location ..

    foreach ($letter in 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()) {
        if (Test-Path $letter -PathType Container) {
            if ((Get-ChildItem $letter).Count -eq 0) {
                $directory = Get-Item $letter
                Set-Location $previous
                return $directory
            }
        }
        if (!(Test-Path $letter)) {
            $directory = New-Item $letter -ItemType Directory
            Set-Location $previous
            return $directory
        }
    }

    Set-Location $previous
    $null
}

<#
 .Synopsis
  Creates a new Git Worktree.

 .Description
  Creates a new Git Worktree for the repository containing the current working location.

 .Parameter Name
  The branch name to checkout into the new worktree.

 .Parameter Exact
  A switch that determines whether the -Name parameter should be used as is, or to pre-pend 
  the conventional 'users/{username}/' path to the branch name. The {username} is determined
  based on the git configuration value for 'user.alias' or the environment variable named 'USERNAME'.

 .Parameter WhatIf
  A switch that determines whether to actually create the new worktree, or just report on
  what _would_ be created with the supplied parameters.

 .Example
   # Create a new worktree for the branch named 'users/{username}/feature-abc'
   New-Worktree -Name feature-abc

 .Example
   # Create a new worktree for the branch named 'releases/2020/2020.7'
   New-Worktree -Name releases/2020/2020.7 -Exact
#>
Function New-Worktree(
    [string] $Name,
    [switch] $Exact,
    [switch] $WhatIf
) {

    $repository = Get-RepositoryName
    $commands = (Get-RepositoryCommands $repository)

    if ($WhatIf) {
        Write-Host "Username: $(Get-Username)"
        Write-Host "Repository: $repository"
        Write-Host "Branch: $(Get-BranchName)"
        Write-Host "Commands: $commands"
        Write-Host ""
    }

    $target = Get-NextWorktreeDirectory
    $target = Resolve-Path $target
    $master = $GitWorktreesSettings['default-branch']

    if ($WhatIf) {
        Write-Host "Set-Location $(Get-PathString (Get-Worktrees)[$master])"
    }
    else {
        Set-Location (Get-Worktrees)[$master]
    }

    if ($Exact) {
        $branch = Get-BranchName -Name $Name -Exact
    }
    else {
        $branch = Get-BranchName -Name $Name
    }

    Write-Output "Creating worktree for $branch"
    $branches = (git branch -a)
    $exists = ($branches | Select-String "\s$branch`$").Count -gt 0

    $command = 'git worktree add'

    if (!$exists) {
        $command = "$command -b $branch $(Get-PathString $target) $master"
    }
    else {
        $command = "$command $(Get-PathString $target) $branch"
    }

    if ($WhatIf) {
        Write-Output $command
        Write-Output "Set-Location $(Get-PathString $target)"
    }
    else {
        Invoke-Expression $command
        Set-Location $target
    }


    if ($null -ne $commands) {

        Write-Host "Invoking commands for $repository"
        foreach ( $command in $commands) {

            if ($command -is [string]) {
                if ($WhatIf) {
                    Write-Output $command
                }
                else {
                    Invoke-Expression $command
                }
            } else {
                Write-Warning "Unable to execute a command for this repository. $command"
            }
        }

        if ($WhatIf) {
            Write-Host "Set-Location $target"
        }
        else {
            Set-Location $target
        }

    }

}

<#
 .Synopsis
  Retrieves the name of the Git repository.

 .Example
   # Show a table of each current worktree
   Get-RepositoryName
#>
Function Get-RepositoryName {
    return ([System.IO.DirectoryInfo](Get-Location).Path).Parent.Name
}

Function Get-CurrentBranch {
    $worktrees = Get-Worktrees
    $path = (Get-Location).Path

    return $worktrees.Keys | Where-Object { $path.StartsWith($worktrees[$_]) }
}

Function Get-BranchName(
    [string] $Name,
    [switch] $Exact
) {
    # Calculate the specified branch name

    if ($Exact) {
        return $Name
    }
    else {
        $alias = Get-Username
        return "users/$alias/$Name"
    }
}

Function Get-Username {

    $alias = $GitWorktreesSettings['username']

    if ($null -eq $alias) {
        $alias = (git config user.alias)
    }

    if ($null -eq $alias) {
        $alias = $env:USERNAME
    }

    if ($null -eq $alias) {
        $alias = 'me'
    }

    return $alias
}

Function Get-RepositoryCommands(
    [string] $Name
) {
    return $GitWorktreesSettings['repository-commands'].$Name
}

$path = ([System.IO.FileInfo]$PSCommandPath).DirectoryName
$path = "$path\settings.yml"
$default = @"
username: me
default-branch: master
repository-commands: []
"@

if (Test-Path $path) {
    Write-Host "Using settings from $path"
    $GitWorktreesSettings = (Get-Content $path | ConvertFrom-Yaml)
}
else {
    Write-Host "Git-Worktrees module settings not found: $path"
    $GitWorktreesSettings = ConvertFrom-Yaml $default
    $GitWorktreesSettings
}

Function Get-PathString(
    [string] $Path
) {
    if ($Path -match '^[''"].*[''"]$') {
        return $Path
    }
    if ($Path -match "\s") {
        return """$Path"""
    }
    return $Path
}

Function Get-OrphanBranches(
    [switch] $Bare
) {

    $remoteBranches = (git branch -r)

    $orphans = (git branch -l) `
    | ForEach-Object { $_.Replace(' ', '') } `
    | Where-Object { -not ($_ -match '([\*\+].*)|master') } `
    | Where-Object { -not ($remoteBranches -match "\s+origin/$_") }

    if ($Bare) {
        $orphans
    }
    else {

        $branches = @{}

        foreach ($branch in $orphans) {
            $description = git log $branch -1 --date=relative --pretty='format:%ad: %s'
            $branches.Add( $branch, $description)
        }

        $branches
    }
}

Function Remove-OrphanBranches(
    [switch]  $WhatIf
) {
    foreach ($branch in Get-OrphanBranches -Bare) {

        $command = "git branch -D $branch"

        if ($WhatIf) {
            Write-Output $command
        }
        else {
            Invoke-Expression $command
        }
    }
}

New-Alias -Name pull -Value Sync-DefaultBranch
New-Alias -Name trees -Value Get-Worktrees
New-Alias -Name tree -Value New-Worktree
New-Alias -Name deltree -Value Remove-Worktree
New-Alias -Name branch -Value Get-CurrentBranch

Export-ModuleMember -Function Get-PathString, Get-Worktrees, New-Worktree, Remove-Worktree, Get-CurrentBranch, Sync-DefaultBranch, Get-OrphanBranches, Remove-OrphanBranches -Alias pull, trees, tree, deltree, branch -Variable $GitWorktreesSettings
