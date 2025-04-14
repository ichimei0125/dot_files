# alias
Set-Alias py312 C:\Users\shi\.virtualenv\py312\Scripts\activate.ps1

function prompt {
    $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
	$user = $user.Split('\')[-1]
    $host_ = $env:COMPUTERNAME
    $cwd  = (Get-Location).Path

    # 使用 ANSI 转义序列加颜色（兼容 PowerShell Core 7+）
    $colorGreen = "`e[32m"
    $colorRed   = "`e[31m"
    $colorBlue  = "`e[94m"
    $colorCyan  = "`e[36m"
    $colorReset = "`e[0m"


	# Git 状态段（如果有 posh-git）
	$gitStatus = ""
    # if (Get-Command -Name Get-GitStatus -ErrorAction SilentlyContinue -CommandType Function) {
	if (Test-Path (Join-Path (Get-Location).Path ".git")) {
        $gitStatus = & $GitPromptScriptBlock
	}

    $top = "$colorRed┌─[$colorGreen$user@$host_$colorRed]─[$colorBlue$cwd$colorRed]"
    $bottom = "$colorRed└─$colorCyan`$ $gitStatus$colorReset"

    return "$top`n$bottom "

	# return "PS $(Get-Location)`n> "
}

function global:Set-Location {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path
    )

    # 切换目录
    Microsoft.PowerShell.Management\Set-Location -Path $Path

    # 检查当前路径是否在 Git 仓库中
    if (-not (Get-Module posh-git) -and (Test-Path (Join-Path (Get-Location).Path ".git"))) {
        Write-Host "Loading posh-git..." -ForegroundColor Yellow
        Import-Module posh-git

		$global:GitPromptSettings.DefaultPromptPath.Text = ''
		$global:GitPromptSettings.DefaultPromptSuffix = ''
    }
}

function global:cd {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path
    )
    Set-Location $Path
}

# sync dot files
#function get-dotfiles {
	#$dot_files = @{
	#"C:\Users\shi\Documents\PowerShell\profile.ps1" = "C:\Users\shi\workspace\Github\dot_files\powershell\profile.ps1";
	#"C:\Users\shi\_vimrc" = "C:\Users\shi\workspace\Github\dot_files\vim\.vimrc";
    #"C:\Users\shi\AppData\Local\nvim\init.lua" = "C:\Users\shi\workspace\Github\dot_files\nvim\init.lua";
    #"C:\Users\shi\AppData\Local\nvim\vimrc.vim" = "C:\Users\shi\workspace\Github\dot_files\nvim\vimrc.vim"
	#}
	#return $dot_files
#}
#function gitpushdotfiles {
	#$git_repo = "C:\Users\shi\workspace\Github\dot_files"
	#$dot_files = get-dotfiles
#
	#$dot_files.GetEnumerator() | ForEach-Object {
		#cp $_.Key $_.Value
	#}
#
	## git push
	#$now_path = Get-Location
	#cd $git_repo
	#git add .
	#git commit -m "update by gitdotfiles"
	#git push
	#cd $now_path
#}
#function gitpulldotfiles {
	#$git_repo = "C:\Users\shi\workspace\Github\dot_files"
	#$dot_files = get-dotfiles
#
	## git push
	#$now_path = Get-Location
	#cd $git_repo
	#git pull
#
	#$dot_files.GetEnumerator() | ForEach-Object {
		#cp $_.Value $_.Key
#
		##[System.IO.File]::Copy($_.Value, $_.Key, $true);
	#}
	#cd $now_path
#}
#function gitsyncdotfiles {
    #gitpulldotfiles
    #gitpushdotfiles
#}
