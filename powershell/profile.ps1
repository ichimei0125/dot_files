Import-Alias -Path "C:\Users\shi\bin\ps_alias.csv"

# lazy load posh-git
$LazyLoadProfile = [PowerShell]::Create()
[void]$LazyLoadProfile.AddScript(@'
    Import-Module posh-git
'@)
$LazyLoadProfileRunspace = [RunspaceFactory]::CreateRunspace()
$LazyLoadProfile.Runspace = $LazyLoadProfileRunspace
$LazyLoadProfileRunspace.Open()
[void]$LazyLoadProfile.BeginInvoke()

$null = Register-ObjectEvent -InputObject $LazyLoadProfile -EventName InvocationStateChanged -Action {
    Import-Module -Name posh-git
    $global:GitPromptSettings.DefaultPromptPrefix.Text = 'PS '
    $global:GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
    $LazyLoadProfile.Dispose()
    $LazyLoadProfileRunspace.Close()
    $LazyLoadProfileRunspace.Dispose()
}

# sync dot files
function gitdotfiles() {
	$dot_files = @{
	"C:\Users\shi\Documents\PowerShell\profile.ps1" = "C:\Users\shi\workspace\Github\dot_files\powershell";
	"C:\Users\shi\_vimrc" = "C:\Users\shi\workspace\Github\dot_files\.vimrc"
	}
	$git_repo = "C:\Users\shi\workspace\Github\dot_files"

	$dot_files.GetEnumerator() | ForEach-Object {
		cp $_.Key $_.Value
	}

	# git push
	$now_path = Get-Location
	cd $git_repo
	git add .
	git commit -m "update by gitdotfiles"
	git push
	cd $now_path
}
