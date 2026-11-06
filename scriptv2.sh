# Script PowerShell (malgré l'extension .sh). Exemple d'exécution limitée :
# & ([scriptblock]::Create((Get-Content -Raw -LiteralPath 'C:\Users\Admin\Desktop\git\git-vscodium\scriptv2.sh'))) -DurationSeconds 6

param(
    [ValidateRange(0, [int]::MaxValue)]
    [int]$DurationSeconds = 0,
    [ValidateRange(1, 3600)]
    [int]$IntervalSeconds = 3
)

$source = @'
using System;
using System.Runtime.InteropServices;

public static class ScreenRotation {
	[StructLayout(LayoutKind.Explicit)]
	public struct DISPLAYUNION {
		[FieldOffset(0)] public int dmPositionX;
		[FieldOffset(4)] public int dmPositionY;
		[FieldOffset(0)] public int dmDisplayOrientation;
		[FieldOffset(4)] public int dmDisplayFixedOutput;
	}

	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	public struct DEVMODE {
		[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
		public short dmSpecVersion, dmDriverVersion, dmSize, dmDriverExtra;
		public int dmFields;
		public DISPLAYUNION dmDisplay;
		public short dmColor, dmDuplex, dmYResolution, dmTTOption, dmCollate;
		[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
		public short dmLogPixels;
		public int dmBitsPerPel, dmPelsWidth, dmPelsHeight, dmDisplayFlags, dmDisplayFrequency;
		public int dmICMMethod, dmICMIntent, dmMediaType, dmDitherType, dmReserved1, dmReserved2;
		public int dmPanningWidth, dmPanningHeight;

		public int dmDisplayOrientation {
			get { return dmDisplay.dmDisplayOrientation; }
			set { DISPLAYUNION display = dmDisplay; display.dmDisplayOrientation = value; dmDisplay = display; }
		}
	}

	[DllImport("user32.dll", EntryPoint = "EnumDisplaySettingsW", CharSet = CharSet.Unicode)]
	[return: MarshalAs(UnmanagedType.Bool)]
	public static extern bool EnumDisplaySettings(IntPtr deviceName, int modeNum, ref DEVMODE devMode);
	[DllImport("user32.dll", CharSet = CharSet.Unicode)]
	public static extern int ChangeDisplaySettings(ref DEVMODE devMode, int flags);
}
'@

Add-Type -TypeDefinition $source
$original = New-Object 'ScreenRotation+DEVMODE'
$original.dmSize = [Runtime.InteropServices.Marshal]::SizeOf($original)
if (-not [ScreenRotation]::EnumDisplaySettings([IntPtr]::Zero, -1, [ref]$original)) {
    throw "Impossible de lire la configuration de l'écran."
}

$baseOrientation = $original.dmDisplayOrientation
$sideOrientation = ($baseOrientation + 1) % 4
$baseWidth = $original.dmPelsWidth
$baseHeight = $original.dmPelsHeight
$current = $baseOrientation
$fields = 0x80 -bor 0x80000 -bor 0x100000

function Set-ScreenOrientation([int]$orientation) {
    $mode = New-Object 'ScreenRotation+DEVMODE'
    $mode.dmSize = [Runtime.InteropServices.Marshal]::SizeOf($mode)
    if (-not [ScreenRotation]::EnumDisplaySettings([IntPtr]::Zero, -1, [ref]$mode)) {
        throw "Impossible de relire la configuration de l'écran."
    }
    $mode.dmFields = $script:fields
    $mode.dmDisplayOrientation = $orientation
    if (($orientation % 2) -ne ($script:baseOrientation % 2)) {
        $mode.dmPelsWidth = $script:baseHeight
        $mode.dmPelsHeight = $script:baseWidth
    } else {
        $mode.dmPelsWidth = $script:baseWidth
        $mode.dmPelsHeight = $script:baseHeight
    }
    $result = [ScreenRotation]::ChangeDisplaySettings([ref]$mode, 0)
    if ($result -ne 0) { Write-Warning "Windows n'a pas accepté ce changement d'orientation (code $result)." }
}

Write-Host "La fête commence ! Ctrl+C pour remettre l'écran droit."
$stopwatch = [Diagnostics.Stopwatch]::StartNew()
try {
    while ($DurationSeconds -eq 0 -or $stopwatch.Elapsed.TotalSeconds -lt $DurationSeconds) {
        $sleepSeconds = $IntervalSeconds
        if ($DurationSeconds -gt 0) {
            $remainingSeconds = $DurationSeconds - $stopwatch.Elapsed.TotalSeconds
            $sleepSeconds = [Math]::Min($sleepSeconds, [Math]::Ceiling($remainingSeconds))
        }
        Start-Sleep -Seconds $sleepSeconds
        if ($DurationSeconds -gt 0 -and $stopwatch.Elapsed.TotalSeconds -ge $DurationSeconds) { break }
        $current = if ($current -eq $baseOrientation) { $sideOrientation } else { $baseOrientation }
        Set-ScreenOrientation $current
    }
} finally {
    Set-ScreenOrientation $baseOrientation
    Write-Host "Fin du tour de manège : orientation initiale restaurée."
}

# Mais mettez moi les exit 0 !
exit 0