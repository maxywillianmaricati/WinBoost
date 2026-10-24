@echo off
title WinBoost 2.0 - Windows Performance Toolkit
setlocal
set "WB_SELF=%~f0"
mode con: cols=110 lines=48 >nul 2>&1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText($env:WB_SELF,[Text.Encoding]::UTF8);$i=$t.LastIndexOf('#<<WB-ENGINE>>');& ([scriptblock]::Create($t.Substring($i+'#<<WB-ENGINE>>'.Length)))"
exit /b %errorlevel%
#<<WB-ENGINE>>
# =============================================================================
#  WinBoost 2.0 engine (PowerShell 5.1) - Optimized & Manual RP Edition
# =============================================================================
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
$script:Ver = '2.0'
$script:Repo = 'github.com/maxywillianmaricati/WinBoost'
$script:Lang = 'en'
$script:SchemeGuid = '5b57a0f2-0b00-4c7e-9a10-000000000100'

try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
try { $Host.UI.RawUI.BackgroundColor = 'Black'; $Host.UI.RawUI.ForegroundColor = 'White' } catch {}

$wbId = [Security.Principal.WindowsIdentity]::GetCurrent()
$wbAdmin = (New-Object Security.Principal.WindowsPrincipal $wbId).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $wbAdmin) {
    Start-Process -FilePath $env:ComSpec -ArgumentList ('/c ""' + $env:WB_SELF + '""') -Verb RunAs
    exit
}

Add-Type -Namespace WB -Name N -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
[DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
[DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);
[DllImport("user32.dll", EntryPoint="SystemParametersInfo", CharSet=CharSet.Auto)] public static extern bool SpiInts(uint a, uint b, int[] c, uint d);
[DllImport("user32.dll", EntryPoint="SystemParametersInfo", CharSet=CharSet.Auto)] public static extern bool SpiVal(uint a, uint b, IntPtr c, uint d);
'@

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class WBPurge {
  [StructLayout(LayoutKind.Sequential, Pack = 4)] struct TP { public int Count; public long Luid; public int Attr; }
  [DllImport("ntdll.dll")] static extern int NtSetSystemInformation(int c, ref int i, int l);
  [DllImport("advapi32.dll", SetLastError = true)] static extern bool OpenProcessToken(IntPtr h, int a, out IntPtr t);
  [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)] static extern bool LookupPrivilegeValue(string s, string n, out long l);
  [DllImport("advapi32.dll", SetLastError = true)] static extern bool AdjustTokenPrivileges(IntPtr t, bool d, ref TP n, int len, IntPtr p, IntPtr r);
  [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
  [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
  public static int Run() {
    IntPtr t;
    if (!OpenProcessToken(GetCurrentProcess(), 0x28, out t)) return -1;
    try {
      TP tp = new TP(); tp.Count = 1; tp.Attr = 2;
      if (!LookupPrivilegeValue(null, "SeProfileSingleProcessPrivilege", out tp.Luid)) return -2;
      AdjustTokenPrivileges(t, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
      int cmd = 4;
      return NtSetSystemInformation(80, ref cmd, 4);
    } finally { CloseHandle(t); }
  }
}
'@

$script:E = [char]27
$script:Ansi = $false
try {
    $h = [WB.N]::GetStdHandle(-11); $m = [uint32]0
    if ([WB.N]::GetConsoleMode($h, [ref]$m)) { if ([WB.N]::SetConsoleMode($h, ($m -bor 4))) { $script:Ansi = $true } }
} catch {}
if ($env:WT_SESSION) { $script:Ansi = $true }
function Col($r, $g, $b) { if ($script:Ansi) { return ($script:E + '[38;2;' + $r + ';' + $g + ';' + $b + 'm') } return '' }
$script:cR = Col 255 55 75
$script:cB = Col 70 140 255
$script:cW = $(if ($script:Ansi) { $script:E + '[97m' } else { '' })
$script:cD = $(if ($script:Ansi) { $script:E + '[90m' } else { '' })
$script:cX = $(if ($script:Ansi) { $script:E + '[0m' } else { '' })

$script:Root = Join-Path $env:ProgramData 'WinBoost'
$script:LogDir = Join-Path $script:Root 'logs'
New-Item -ItemType Directory -Path $script:LogDir -Force | Out-Null
$script:ManFile = Join-Path $script:Root 'manifest.json'
$script:LangFile = Join-Path $script:Root 'lang.txt'
function Log($m) {
    try { Add-Content -LiteralPath (Join-Path $script:LogDir 'winboost.log') -Value ('[' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '] ' + $m) -Encoding UTF8 } catch {}
}

$script:S = @{}
function Def($k, $en, $pt) { $script:S[$k] = @($en, $pt) }
function Tr($k, [object[]]$a) {
    $v = $script:S[$k]
    if (-not $v) { return $k }
    $s = $(if ($script:Lang -eq 'pt') { $v[1] } else { $v[0] })
    if ($a) { return ($s -f $a) }
    return $s
}

Def 'yes' 'yes' 'sim'
Def 'no' 'no' 'não'
Def 'lang_title' 'Choose your language' 'Escolha seu idioma'
Def 'loading' 'Loading...' 'Carregando...'
Def 'detecting' 'Detecting hardware...' 'Detectando hardware...'
Def 'p_input' 'Input Lag' 'Input Lag'
Def 'p_fps' 'FPS & Gaming' 'FPS e Jogos'
Def 'p_energy' 'Energy' 'Energia'
Def 'p_memory' 'Memory' 'Memória'
Def 'p_clean' 'Cleaning' 'Limpeza'
Def 'p_privacy' 'Privacy' 'Privacidade'
Def 'p_system' 'System' 'Sistema'
Def 'p_advanced' 'Advanced' 'Avançado'
Def 'p_debloat' 'Debloat' 'Debloat'
Def 'p_repair' 'Repair' 'Reparo'
Def 'p_revert' 'Backup & Revert' 'Backup e Reverter'
Def 'ui_applyall' 'Apply ALL recommended' 'Aplicar TODAS recomendadas'
Def 'ui_undoall' 'Undo ALL' 'Desfazer TUDO'
Def 'ui_lang' 'Language' 'Idioma'
Def 'ui_exit' 'Exit' 'Sair'
Def 'ui_back' 'Back' 'Voltar'
Def 'ui_apply' 'Apply recommended' 'Aplicar recomendadas'
Def 'ui_undo' 'Undo page' 'Desfazer página'
Def 'ui_hint' 'Type numbers to apply (ex: 1,3,5-7)   |   U 2 = undo item 2' 'Digite números para aplicar (ex: 1,3,5-7)   |   U 2 = desfazer item 2'
Def 'ui_legend' '[ON] active   [ - ] off   [ ~ ] partial   [ * ] one-time action   ! advanced' '[ON] ativo   [ - ] desligado   [ ~ ] parcial   [ * ] ação única   ! avançado'
Def 'ui_press' 'Press Enter to continue...' 'Pressione Enter para continuar...'
Def 'q_apply' 'Apply {0} tweaks?' 'Aplicar {0} ajustes?'
Def 'q_undoall' 'Undo ALL {0} recorded changes?' 'Desfazer TODAS as {0} alterações registradas?'
Def 'q_undo' 'Undo {0} recorded changes?' 'Desfazer {0} alterações registradas?'
Def 'q_risky' 'Some selected items are advanced (!). Continue?' 'Alguns itens são avançados (!). Continuar?'
Def 'msg_nothing_apply' 'Everything recommended here is already active.' 'Tudo que é recomendado aqui já está ativo.'
Def 'msg_nothing_undo' 'Nothing to undo here.' 'Nada para desfazer aqui.'
Def 'msg_onetime' 'This page has one-time actions only, nothing to undo.' 'Esta página só tem ações únicas, nada para desfazer.'
Def 'msg_rp' 'Creating a Windows restore point...' 'Criando ponto de restauração do Windows...'
Def 'msg_rp_ok' 'Restore point created.' 'Ponto de restauração criado.'
Def 'msg_rp_fail' 'Restore point not created (System Protection may be off). WinBoost backup is still active.' 'Ponto não criado (Proteção do Sistema pode estar desligada). O backup do WinBoost continua ativo.'
Def 'msg_summary' '{0} applied  |  {1} already active  |  {2} skipped  |  {3} failed' '{0} aplicados  |  {1} já ativos  |  {2} ignorados  |  {3} falharam'
Def 'msg_restart' 'Restart your PC to finish applying.' 'Reinicie o PC para concluir.'
Def 'msg_freed' 'Space freed: {0}' 'Espaço liberado: {0}'
Def 'msg_undone' '{0} changes restored.' '{0} alterações restauradas.'
Def 'msg_undo_fail' '{0} could not be restored (see log).' '{0} não puderam ser restauradas (veja o log).'
Def 'msg_running' 'Running {0}... this may take a while.' 'Executando {0}... isso pode demorar.'
Def 'r_ok' 'OK' 'OK'
Def 'r_already' 'already' 'já ativo'
Def 'r_skip' 'skipped' 'ignorado'
Def 'r_fail' 'FAILED' 'FALHOU'
Def 'hw_cpu' 'CPU' 'CPU'
Def 'hw_gpu' 'GPU' 'GPU'
Def 'hw_ram' 'RAM' 'RAM'
Def 'hw_disk' 'Disk' 'Disco'
Def 'hw_pc' 'PC' 'PC'
Def 'hw_laptop' 'Laptop' 'Notebook'
Def 'hw_desktop' 'Desktop' 'Desktop'
Def 'rv_1' 'Undo everything' 'Desfazer tudo'
Def 'rv_2' 'Create restore point now' 'Criar ponto de restauração agora'
Def 'rv_3' 'Open Windows System Restore' 'Abrir Restauração do Sistema'
Def 'rv_4' 'Open backup folder' 'Abrir pasta de backup'
Def 'rv_5' 'Open log folder' 'Abrir pasta de logs'
Def 'rv_count' 'Recorded changes: {0}' 'Alterações registradas: {0}'
Def 'note_ram' 'RAM before/after: {0} MB -> {1} MB free' 'RAM antes/depois: {0} MB -> {1} MB livre'

# ---- tweak labels ----
Def 't_mouse_accel' 'Mouse acceleration off' 'Mouse sem aceleração'
Def 'd_mouse_accel' '1:1 pointer movement, essential for aim' 'Movimento 1:1 do ponteiro, essencial para mira'
Def 't_mouse_speed' 'Pointer speed 6/11' 'Velocidade do ponteiro 6/11'
Def 'd_mouse_speed' 'Default speed without skipped pixels' 'Velocidade padrão sem pular pixels'
Def 't_kbd_fast' 'Faster keyboard' 'Teclado mais rápido'
Def 'd_kbd_fast' 'Shortest repeat delay, fastest repeat rate' 'Menor atraso e maior taxa de repetição'
Def 't_sticky' 'No Sticky Keys popup' 'Sem aviso de Teclas de Aderência'
Def 'd_sticky' 'No popup when pressing Shift many times' 'Sem janela ao apertar Shift várias vezes'
Def 't_usb' 'USB never sleeps' 'USB nunca dorme'
Def 'd_usb' 'Disables USB selective suspend' 'Desliga a suspensão seletiva de USB'
Def 't_gamemode' 'Game Mode' 'Modo de Jogo'
Def 'd_gamemode' 'Windows prioritizes the game in the foreground' 'O Windows prioriza o jogo em primeiro plano'
Def 't_gamedvr' 'Game DVR off' 'Game DVR desligado'
Def 'd_gamedvr' 'Stops hidden background recording' 'Para a gravação escondida em segundo plano'
Def 't_mmcss' 'Game scheduling priority' 'Prioridade de jogos'
Def 'd_mmcss' 'More CPU/GPU/disk time for games' 'Mais tempo de CPU/GPU/disco para jogos'
Def 't_win32prio' 'Foreground boost' 'Prioridade do 1º plano'
Def 'd_win32prio' 'Short time slices, active window gets more CPU' 'Fatias curtas, a janela ativa recebe mais CPU'
Def 't_nethrottle' 'Network throttling off' 'Rede sem limitação'
Def 'd_nethrottle' 'Removes the packet limit used during media' 'Remove o limite de pacotes usado com mídia'
Def 't_bgapps' 'No background apps' 'Sem apps em segundo plano'
Def 'd_bgapps' 'Store apps stop running hidden' 'Apps da Store param de rodar escondidos'
Def 't_timer' 'Global timer resolution' 'Resolução global do timer'
Def 'd_timer' 'Game timer requests apply system-wide' 'Pedidos de timer do jogo valem para o sistema'
Def 't_hags' 'Hardware GPU scheduling' 'Agendamento de GPU por hardware'
Def 'd_hags' 'GPU manages its own memory, less latency' 'A GPU gerencia a própria memória, menos latência'
Def 't_pthrottle' 'Power Throttling off' 'Sem Power Throttling'
Def 'd_pthrottle' 'Windows stops lowering clocks of background tasks' 'O Windows não reduz o clock de tarefas em segundo plano'
Def 't_nagle' 'Nagle algorithm off' 'Algoritmo de Nagle desligado'
Def 'd_nagle' 'Small packets leave immediately, can lower ping' 'Pacotes pequenos saem na hora, pode reduzir o ping'
Def 't_scheme' 'WinBoost Max Performance plan' 'Plano WinBoost Desempenho Máximo'
Def 'd_scheme' 'Creates and activates a max performance power plan' 'Cria e ativa um plano de energia de desempenho máximo'
Def 't_cpumin' 'CPU minimum 100%' 'CPU mínima 100%'
Def 'd_cpumin' 'CPU never lowers its clock' 'A CPU nunca baixa o clock'
Def 'w_cpumin' 'On laptops this raises heat and fan noise.' 'Em notebook aumenta calor e barulho da ventoinha.'
Def 't_unpark' 'All cores unparked' 'Todos os núcleos ativos'
Def 'd_unpark' 'No delay waking cores when a game needs them' 'Sem atraso para acordar núcleos quando o jogo pede'
Def 't_boost' 'Aggressive turbo' 'Turbo agressivo'
Def 'd_boost' 'CPU boost mode set to aggressive' 'Modo de boost da CPU em agressivo'
Def 't_epp' 'Performance bias (EPP)' 'Preferência desempenho (EPP)'
Def 'd_epp' 'CPU ramps clocks up faster instead of saving power' 'A CPU sobe o clock mais rápido em vez de economizar'
Def 't_pcie' 'PCIe no power saving' 'PCIe sem economia'
Def 'd_pcie' 'GPU and NVMe stay active on the bus' 'GPU e NVMe ficam ativos no barramento'
Def 't_faststart' 'Fast Startup off' 'Inicialização rápida desligada'
Def 'd_faststart' 'Full shutdown, avoids stale drivers between boots' 'Desligamento completo, evita drivers "presos"'
Def 't_mcomp_off' 'RAM compression off' 'Compressão de RAM desligada'
Def 'd_mcomp_off' 'With 32 GB+ it saves a little CPU' 'Com 32 GB+ economiza um pouco de CPU'
Def 't_mcomp_on' 'RAM compression on' 'Compressão de RAM ligada'
Def 'd_mcomp_on' 'With 8 GB or less, compressing beats swapping' 'Com 8 GB ou menos, comprimir é melhor que usar o disco'
Def 't_pagexec' 'Kernel stays in RAM' 'Kernel fica na RAM'
Def 'd_pagexec' 'Drivers/kernel are not paged out (16 GB+)' 'Drivers/kernel não vão para o pagefile (16 GB+)'
Def 't_sysmain' 'SysMain off (SSD)' 'SysMain desligado (SSD)'
Def 'd_sysmain' 'Less disk activity on SSD' 'Menos uso de disco no SSD'
Def 't_ndu' 'Fix NDU memory leak' 'Corrigir vazamento do NDU'
Def 'd_ndu' 'Disables the data usage monitor known to leak RAM' 'Desliga o monitor de uso de dados que vaza RAM'
Def 't_purge' 'Free standby RAM now' 'Liberar RAM em espera agora'
Def 'd_purge' 'One-time: empties the standby list before a game' 'Ação única: esvazia a lista standby antes do jogo'
Def 't_tmp_user' 'User temp files' 'Temporários do usuário'
Def 'd_tmp_user' 'Empties %TEMP% (files in use are skipped)' 'Esvazia o %TEMP% (arquivos em uso são ignorados)'
Def 't_tmp_win' 'Windows temp files' 'Temporários do Windows'
Def 'd_tmp_win' 'Empties C:\Windows\Temp' 'Esvazia C:\Windows\Temp'
Def 't_wu' 'Windows Update cache' 'Cache do Windows Update'
Def 'd_wu' 'Deletes already downloaded installers' 'Apaga instaladores já baixados'
Def 't_shader' 'Shader caches' 'Cache de shaders'
Def 'd_shader' 'DirectX/NVIDIA/AMD/Intel, rebuilt on next launch' 'DirectX/NVIDIA/AMD/Intel, recriado na próxima abertura'
Def 't_browser' 'Browser caches' 'Cache dos navegadores'
Def 'd_browser' 'Cache only, passwords and history stay' 'Só cache, senhas e histórico ficam'
Def 't_dumps' 'Crash dumps' 'Dumps de travamento'
Def 'd_dumps' 'Minidump, MEMORY.DMP and CrashDumps' 'Minidump, MEMORY.DMP e CrashDumps'
Def 't_wer' 'Error reports' 'Relatórios de erro'
Def 'd_wer' 'Old Windows Error Reporting files' 'Arquivos antigos do relatório de erros'
Def 't_dns' 'Flush DNS cache' 'Limpar cache DNS'
Def 'd_dns' 'Fixes stale name resolution' 'Corrige resolução de nomes velha'
Def 't_trim' 'SSD TRIM' 'TRIM no SSD'
Def 'd_trim' 'Tells the SSD which blocks are free' 'Avisa o SSD quais blocos estão livres'
Def 't_recycle' 'Empty Recycle Bin' 'Esvaziar lixeira'
Def 'd_recycle' 'Permanently deletes what is in the bin' 'Apaga de vez o que está na lixeira'
Def 'w_recycle' 'Files in the Recycle Bin cannot be recovered.' 'Arquivos da lixeira não poderão ser recuperados.'
Def 't_fontcache' 'Font cache' 'Cache de fontes'
Def 'd_fontcache' 'Deletes the Windows font cache files' 'Apaga os arquivos de cache de fontes do Windows'
Def 't_eventlog' 'Event logs' 'Logs de eventos'
Def 'd_eventlog' 'Clears all Windows event logs' 'Limpa todos os logs de eventos do Windows'
Def 't_thumbcache' 'Thumbnail cache' 'Cache de miniaturas'
Def 'd_thumbcache' 'Recreates explorer thumbnail cache' 'Recria o cache de miniaturas do explorer'
Def 't_cleanmgr' 'Deep Disk Cleanup (cleanmgr)' 'Limpeza profunda de disco (cleanmgr)'
Def 'd_cleanmgr' 'Runs Windows cleanmgr with all safe categories' 'Executa o cleanmgr com todas as categorias seguras'

# ---- privacy tweak labels ----
Def 't_telemetry' 'Telemetry at minimum' 'Telemetria no mínimo'
Def 'd_telemetry' 'AllowTelemetry = 0 (security only)' 'AllowTelemetry = 0 (somente segurança)'
Def 't_cortana' 'Cortana off' 'Cortana desligada'
Def 'd_cortana' 'Disables Cortana and web search in Start' 'Desliga Cortana e busca web no Iniciar'
Def 't_location' 'Location tracking off' 'Rastreamento de localização desligado'
Def 'd_location' 'Disables Windows Location Provider and scripting' 'Desliga o provedor de localização do Windows'
Def 't_ads' 'Advertising ID off' 'ID de publicidade desligado'
Def 'd_ads' 'Apps cannot use your advertising ID' 'Apps não podem usar seu ID de publicidade'
Def 't_activity' 'Activity history off' 'Histórico de atividades desligado'
Def 'd_activity' 'Windows stops tracking apps you launch' 'O Windows para de rastrear apps que você abre'
Def 't_feedback' 'Feedback prompts off' 'Pedidos de feedback desligados'
Def 'd_feedback' 'No feedback notifications from Windows' 'Sem notificações de feedback do Windows'
Def 't_cloudvoice' 'Cloud voice recognition off' 'Reconhecimento de voz na nuvem desligado'
Def 'd_cloudvoice' 'Speech data stays local' 'Dados de fala ficam locais'
Def 't_ink' 'Ink/typing personalization off' 'Personalização de escrita/teclado desligada'
Def 'd_ink' 'Windows stops harvesting typing and handwriting data' 'O Windows para de coletar dados de digitação e escrita'
Def 't_deliveryopt' 'Delivery Optimization off' 'Otimização de Entrega desligada'
Def 'd_deliveryopt' 'No P2P update sharing with other PCs' 'Sem compartilhamento P2P de atualizações com outros PCs'

# ---- system tweak labels ----
Def 't_showext' 'Show file extensions' 'Mostrar extensões de arquivo'
Def 'd_showext' 'File Explorer shows .exe, .txt, etc.' 'O Explorador mostra .exe, .txt, etc.'
Def 't_longpaths' 'Long paths (>260 chars)' 'Caminhos longos (>260 chars)'
Def 'd_longpaths' 'Enables Win32 long path support' 'Habilita suporte a caminhos longos no Win32'
Def 't_menudelay' 'Instant menus' 'Menus instantâneos'
Def 'd_menudelay' 'MenuShowDelay = 0' 'MenuShowDelay = 0'
Def 't_startupdelay' 'No app startup delay' 'Sem atraso ao abrir apps'
Def 'd_startupdelay' 'Explorer launches apps instantly' 'O Explorador abre apps na hora'
Def 't_balloon' 'No balloon tips' 'Sem balões de dica'
Def 'd_balloon' 'Disables tray balloon notifications' 'Desliga notificações em balão da bandeja'
Def 't_lowdisk' 'No low disk warnings' 'Sem avisos de pouco disco'
Def 'd_lowdisk' 'Disables "low disk space" popups' 'Desliga os popups de "pouco espaço em disco"'
Def 't_reserved' 'Reserved storage off' 'Armazenamento reservado desligado'
Def 'd_reserved' 'Frees ~7 GB from Windows reserved storage' 'Libera ~7 GB do armazenamento reservado do Windows'
Def 't_visualfx' 'Best performance visuals' 'Visuais de melhor desempenho'
Def 'd_visualfx' 'Disables animations and effects (VisualFXSetting=2)' 'Desliga animações e efeitos (VisualFXSetting=2)'
Def 't_killtimeout' 'Faster service shutdown' 'Desligamento de serviço mais rápido'
Def 'd_killtimeout' 'WaitToKillServiceTimeout = 5000ms' 'WaitToKillServiceTimeout = 5000ms'

# ---- advanced tweak labels ----
Def 't_nohyper' 'Disable Hyper-V (bcdedit)' 'Desligar Hyper-V (bcdedit)'
Def 'd_nohyper' 'hypervisorlaunchtype = off (breaks WSL2/VBS)' 'hypervisorlaunchtype = off (quebra WSL2/VBS)'
Def 'w_nohyper' 'Breaks WSL2, Docker Desktop, VBS, Sandbox, Android emulators.' 'Quebra WSL2, Docker Desktop, VBS, Sandbox e emuladores Android.'
Def 't_nodynamictick' 'Disable dynamic tick (bcdedit)' 'Desligar dynamic tick (bcdedit)'
Def 'd_nodynamictick' 'disabledynamictick = Yes (may hurt laptop battery)' 'disabledynamictick = Yes (pode piorar bateria de notebook)'
Def 't_bootlegacy' 'Legacy boot menu (bcdedit)' 'Menu de boot legado (bcdedit)'
Def 'd_bootlegacy' 'bootmenupolicy = Legacy (F8 menu)' 'bootmenupolicy = Legacy (menu F8)'
Def 't_noquietboot' 'Fast boot logo off' 'Sem logo de boot rápido'
Def 'd_noquietboot' 'quietboot = No (shows boot text)' 'quietboot = No (mostra texto no boot)'
Def 't_timeout3' 'Boot timeout 3s' 'Timeout de boot 3s'
Def 'd_timeout3' 'Boot menu waits 3 seconds' 'Menu de boot espera 3 segundos'
Def 't_spectre' 'Disable Spectre/Meltdown patches' 'Desligar patches Spectre/Meltdown'
Def 'd_spectre' 'FeatureSettingsOverride = 3 (faster, less secure)' 'FeatureSettingsOverride = 3 (mais rápido, menos seguro)'
Def 'w_spectre' 'Removes CPU security mitigations. Real security risk.' 'Remove mitigações de segurança da CPU. Risco real de segurança.'
Def 't_usbstor' 'Block USB storage' 'Bloquear armazenamento USB'
Def 'd_usbstor' 'Pendrives are ignored (USB keyboards/mice still work)' 'Pendrives são ignorados (teclado/mouse USB ainda funcionam)'
Def 't_msimode' 'MSI mode on GPU' 'Modo MSI na GPU'
Def 'd_msimode' 'Message Signaled Interrupts on the GPU (lower latency)' 'Message Signaled Interrupts na GPU (menor latência)'
Def 't_no8dot3' 'Disable 8.3 filenames' 'Desligar nomes 8.3'
Def 'd_no8dot3' 'Saves disk space, slightly faster NTFS' 'Economiza espaço em disco, NTFS um pouco mais rápido'
Def 't_nolastaccess' 'No last-access timestamp' 'Sem timestamp de último acesso'
Def 'd_nolastaccess' 'NTFS stops writing access times on every read' 'NTFS para de gravar horário de acesso a cada leitura'

# ---- debloat / repair labels ----
Def 't_debloat_appx' 'Remove bundled Store apps' 'Remover apps da Store embutidos'
Def 'd_debloat_appx' 'Bing/Maps/Zune/Solitaire/Candy/Office hub, etc.' 'Bing/Maps/Zune/Solitaire/Candy/Office hub, etc.'
Def 't_debloat_tasks' 'Disable telemetry scheduled tasks' 'Desligar tarefas de telemetria'
Def 'd_debloat_tasks' 'Compatibility Appraiser, CEIP, Error Reporting, DiagTrack' 'Compatibility Appraiser, CEIP, Error Reporting, DiagTrack'
Def 't_debloat_browsers' 'Disable browser telemetry agents' 'Desligar agentes de telemetria dos navegadores'
Def 'd_debloat_browsers' 'Chrome/Edge/Firefox telemetry and update tasks' 'Telemetria e tarefas de atualização do Chrome/Edge/Firefox'
Def 't_debloat_old' 'Remove Windows.old' 'Remover Windows.old'
Def 'd_debloat_old' 'Deletes the previous Windows installation' 'Apaga a instalação anterior do Windows'
Def 't_repair_sfc' 'System File Checker (SFC)' 'Verificador de arquivos do sistema (SFC)'
Def 'd_repair_sfc' 'sfc /scannow - repairs corrupted system files' 'sfc /scannow - repara arquivos de sistema corrompidos'
Def 't_repair_dism' 'DISM RestoreHealth' 'DISM RestoreHealth'
Def 'd_repair_dism' 'Repairs the Windows component store' 'Repara o repositório de componentes do Windows'
Def 't_repair_resetbase' 'DISM ResetBase' 'DISM ResetBase'
Def 'd_repair_resetbase' 'Cleans old component versions (no more uninstall of updates)' 'Limpa versões antigas (não dá mais pra desinstalar updates)'
Def 't_repair_winsock' 'Reset Winsock' 'Resetar Winsock'
Def 'd_repair_winsock' 'Fixes broken network stacks (reboot needed)' 'Conserta pilha de rede quebrada (precisa reiniciar)'
Def 't_repair_tcpip' 'Reset TCP/IP' 'Resetar TCP/IP'
Def 'd_repair_tcpip' 'Restores default TCP/IP stack (reboot needed)' 'Restaura a pilha TCP/IP padrão (precisa reiniciar)'
Def 't_repair_tcp' 'TCP tuning (autotuning/ECN)' 'Ajuste TCP (autotuning/ECN)'
Def 'd_repair_tcp' 'Normal autotuning, ECN on, timestamps off' 'Autotuning normal, ECN ligado, timestamps desligado'
Def 't_repair_trim' 'Force SSD TRIM' 'Forçar TRIM no SSD'
Def 'd_repair_trim' 'fsutil DisableDeleteNotify = 0' 'fsutil DisableDeleteNotify = 0'

# =============================================================================
#  CONSOLE UI
# =============================================================================
function CW { try { $w = [Console]::WindowWidth; if ($w -gt 20) { return $w } } catch {}; return 100 }
function VLen([string]$s) { return ([regex]::Replace($s, '\x1b\[[0-9;]*m', '')).Length }
function PadV([string]$s, [int]$w) { $n = VLen $s; if ($n -ge $w) { return $s }; return $s + (' ' * ($w - $n)) }
function Center([string]$s) { $pad = [math]::Max(0, [int][math]::Floor(((CW) - (VLen $s)) / 2)); return (' ' * $pad) + $s }
function Cut([string]$s, [int]$n) { if ($n -lt 4) { return '' }; if ($s.Length -le $n) { return $s }; return $s.Substring(0, $n - 1) + '…' }
function Grad([string]$s) {
    if (-not $script:Ansi -or $s.Length -eq 0) { return $s }
    $sb = New-Object Text.StringBuilder
    $n = [math]::Max(1, $s.Length - 1)
    for ($i = 0; $i -lt $s.Length; $i++) {
        $c = $s[$i]
        if ($c -eq ' ') { [void]$sb.Append(' '); continue }
        $f = $i / $n
        $r = [int](255 + (70 - 255) * $f); $g = [int](55 + (140 - 55) * $f); $b = [int](75 + (255 - 75) * $f)
        [void]$sb.Append($script:E + '[38;2;' + $r + ';' + $g + ';' + $b + 'm').Append($c)
    }
    [void]$sb.Append($script:E + '[0m')
    return $sb.ToString()
}

$script:Font = @{
    'W' = @('█     █', '█     █', '█  █  █', '█ █ █ █', ' █   █ ')
    'I' = @('███', ' █ ', ' █ ', ' █ ', '███')
    'N' = @('█   █', '██  █', '█ █ █', '█  ██', '█   █')
    'B' = @('████ ', '█   █', '████ ', '█   █', '████ ')
    'O' = @(' ███ ', '█   █', '█   █', '█   █', ' ███ ')
    'S' = @(' ████', '█    ', ' ███ ', '    █', '████ ')
    'T' = @('█████', '  █  ', '  █  ', '  █  ', '  █  ')
}
function Big([string]$text) {
    $rows = @('', '', '', '', '')
    foreach ($ch in $text.ToCharArray()) {
        $g = $script:Font[[string]$ch]
        for ($i = 0; $i -lt 5; $i++) { $rows[$i] += $g[$i] + '  ' }
    }
    return $rows
}

function Show-Title {
    Clear-Host
    Write-Host ''
    foreach ($r in (Big 'WINBOOST')) { Write-Host (Center (Grad $r)) }
    Write-Host ''
    Write-Host (Center ($script:cD + 'v' + $script:Ver + '   ' + [char]0x2022 + '   ' + $script:Repo + $script:cX))
    Write-Host (Center (Grad ('─' * 72)))
}
function Show-Rule { Write-Host (Center (Grad ('─' * 72))) }
function Say([string]$s) { Write-Host ('  ' + $s) }
function Key([string]$k, [string]$label) {
    return ($script:cR + '[' + $script:cB + $k + $script:cR + ']' + $script:cX + ' ' + $script:cW + $label + $script:cX)
}
function Ask {
    Write-Host ''
    Write-Host -NoNewline ('  ' + $script:cB + '> ' + $script:cX)
    $r = [Console]::ReadLine()
    if ($null -eq $r) { return '' }
    return $r.Trim()
}
function Pause-Key {
    Write-Host ''
    Write-Host ('  ' + $script:cD + (Tr 'ui_press') + $script:cX)
    [void][Console]::ReadLine()
}
function Confirm-Yes([string]$q) {
    Write-Host ''
    Write-Host ('  ' + $script:cR + $q + $script:cX + $script:cD + '  [y/s = ' + (Tr 'yes') + ' | n = ' + (Tr 'no') + ']' + $script:cX)
    $a = (Ask).ToLower()
    return ($a -in @('y', 's', 'yes', 'sim'))
}
function Format-Size([double]$b) {
    if ($b -ge 1GB) { return ('{0:N2} GB' -f ($b / 1GB)) }
    if ($b -ge 1MB) { return ('{0:N1} MB' -f ($b / 1MB)) }
    if ($b -ge 1KB) { return ('{0:N0} KB' -f ($b / 1KB)) }
    return ('{0:N0} B' -f $b)
}

# =============================================================================
#  MANIFEST
# =============================================================================
$script:Man = @()
function Load-Man {
    $script:Man = @()
    if (Test-Path -LiteralPath $script:ManFile) {
        try {
            $raw = [IO.File]::ReadAllText($script:ManFile)
            if ($raw.Trim()) { $script:Man = @(ConvertFrom-Json $raw) }
        } catch { Log ('manifest read failed: ' + $_) }
    }
}
function Save-Man {
    try {
        $j = ConvertTo-Json -InputObject @($script:Man) -Depth 5
        if (-not $j) { $j = '[]' }
        [IO.File]::WriteAllText($script:ManFile, $j, (New-Object Text.UTF8Encoding $false))
    } catch { Log ('manifest save failed: ' + $_) }
}
function Add-Orig($id, $kind, $path, $name, $existed, $okind, $oval, $extra) {
    if (@($script:Man | Where-Object { $_.Id -eq $id }).Count -gt 0) { return }
    $script:Man += [pscustomobject]@{
        Id = [string]$id; Kind = [string]$kind; Path = [string]$path; Name = [string]$name
        Existed = [bool]$existed; OrigKind = [string]$okind; OrigVal = [string]$oval
        Extra = [string]$extra; Date = (Get-Date).ToString('s')
    }
    Save-Man
}

# =============================================================================
#  REGISTRY
# =============================================================================
function Split-Reg([string]$p) {
    if ($p -match '^(HKCU|HKLM):\\(.*)$') {
        $hive = $(if ($Matches[1] -eq 'HKCU') { [Microsoft.Win32.Registry]::CurrentUser } else { [Microsoft.Win32.Registry]::LocalMachine })
        return @{ Hive = $hive; Sub = $Matches[2] }
    }
    throw ('unsupported path ' + $p)
}
function ConvStore($kind, $raw) {
    switch ([string]$kind) {
        'DWord' { return [string][BitConverter]::ToUInt32([BitConverter]::GetBytes([int32]$raw), 0) }
        'QWord' { return [string][BitConverter]::ToUInt64([BitConverter]::GetBytes([int64]$raw), 0) }
        'Binary' { return [Convert]::ToBase64String([byte[]]$raw) }
        'MultiString' { return (($raw -join [string][char]30)) }
        default { return [string]$raw }
    }
}
function Get-Reg([string]$path, [string]$name) {
    $none = @{ Exists = $false; Kind = ''; Value = $null }
    try {
        $s = Split-Reg $path
        $k = $s.Hive.OpenSubKey($s.Sub, $false)
        if ($null -eq $k) { return $none }
        try {
            if (@($k.GetValueNames()) -notcontains $name) { return $none }
            $kind = $k.GetValueKind($name)
            $raw = $k.GetValue($name, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            return @{ Exists = $true; Kind = [string]$kind; Value = (ConvStore $kind $raw) }
        } finally { $k.Close() }
    } catch { return $none }
}
function Set-Reg([string]$path, [string]$name, [string]$kind, [string]$val) {
    $s = Split-Reg $path
    $k = $s.Hive.CreateSubKey($s.Sub)
    if ($null -eq $k) { throw 'cannot open key' }
    try {
        switch ($kind) {
            'DWord' { $k.SetValue($name, [BitConverter]::ToInt32([BitConverter]::GetBytes([uint32]$val), 0), [Microsoft.Win32.RegistryValueKind]::DWord) }
            'QWord' { $k.SetValue($name, [BitConverter]::ToInt64([BitConverter]::GetBytes([uint64]$val), 0), [Microsoft.Win32.RegistryValueKind]::QWord) }
            'Binary' { $k.SetValue($name, [byte[]][Convert]::FromBase64String($val), [Microsoft.Win32.RegistryValueKind]::Binary) }
            'ExpandString' { $k.SetValue($name, $val, [Microsoft.Win32.RegistryValueKind]::ExpandString) }
            default { $k.SetValue($name, $val, [Microsoft.Win32.RegistryValueKind]::String) }
        }
    } finally { $k.Close() }
}
function Remove-Reg([string]$path, [string]$name) {
    $s = Split-Reg $path
    $k = $s.Hive.OpenSubKey($s.Sub, $true)
    if ($null -eq $k) { return }
    try { $k.DeleteValue($name, $false) } finally { $k.Close() }
}

# =============================================================================
#  OPERATIONS
# =============================================================================
function OpReg($p, $n, $k, $v) { return @{ T = 'R'; Path = $p; Name = $n; Kind = $k; Val = [string]$v } }
function OpPwr($sub, $set, $v) { return @{ T = 'P'; Sub = $sub; Set = $set; Val = [int]$v } }
function OpSvc($n) { return @{ T = 'S'; Name = $n } }
function OpMM($on) { return @{ T = 'M'; On = [bool]$on } }
function OpScheme { return @{ T = 'C' } }
function OpAct($n) { return @{ T = 'A'; Name = $n } }
function OpCmd($n) { return @{ T = 'X'; Name = $n } }

$script:G = @{
    PROC = '54533251-82be-4824-96c1-47b60b740d00'; MINP = '893dee8e-2bef-41e0-89c6-b55d0929964c'
    CPMIN = '0cc5b647-c1df-4637-891a-dec35c318583'; BOOST = 'be337238-0d82-4146-a960-4f3749d470c7'
    EPP = '36687f9e-e3a5-4dbf-b1dc-15eb381c6863'
    USB = '2a737441-1930-4402-8d77-b2bebba308a3'; USBSS = '48e6b7a6-50f5-4782-a5d4-53bb8f07e226'
    PCIE = '501a4d13-42af-4429-9fd1-a8218c268e20'; ASPM = 'ee12f906-d277-404b-b6da-e5fa1a576df5'
}

function Op-Id($o) {
    switch ($o.T) {
        'R' { return ('reg|' + $o.Path + '|' + $o.Name).ToLower() }
        'P' { return ('pwr|' + $o.Sub + '|' + $o.Set).ToLower() }
        'S' { return ('svc|' + $o.Name).ToLower() }
        'M' { return 'mm|compress' }
        'C' { return 'scheme' }
    }
    return $null
}
function Svc-Key([string]$n) { return ('HKLM:\SYSTEM\CurrentControlSet\Services\' + $n) }

function Get-ActiveScheme {
    $t = (& powercfg.exe /getactivescheme | Out-String)
    if ($t -match '([0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12})') { return $Matches[1].ToLower() }
    return $null
}
function Get-PwrAC($scheme, $sub, $set) {
    if (-not $scheme) { return $null }
    $vals = @()
    foreach ($l in @(& powercfg.exe /query $scheme $sub $set 2>$null)) {
        if (([string]$l) -match ':\s*0x([0-9a-fA-F]{8})\s*$') { $vals += [Convert]::ToUInt32($Matches[1], 16) }
    }
    if ($vals.Count -ge 2) { return [int64]$vals[$vals.Count - 2] }
    return $null
}

function Op-State($o) {
    switch ($o.T) {
        'R' {
            $c = Get-Reg $o.Path $o.Name
            if ($c.Exists -and $c.Kind -eq $o.Kind -and $c.Value -ceq $o.Val) { return 'on' }
            return 'off'
        }
        'P' { $v = Get-PwrAC (Get-ActiveScheme) $o.Sub $o.Set; if ($null -eq $v) { return 'na' }; if ($v -eq $o.Val) { return 'on' }; return 'off' }
        'S' { $c = Get-Reg (Svc-Key $o.Name) 'Start'; if (-not $c.Exists) { return 'na' }; if ($c.Value -eq '4') { return 'on' }; return 'off' }
        'M' { try { $v = [bool](Get-MMAgent -ErrorAction Stop).MemoryCompression; if ($v -eq $o.On) { return 'on' }; return 'off' } catch { return 'na' } }
        'C' { if ((Get-ActiveScheme) -eq $script:SchemeGuid) { return 'on' } else { return 'off' } }
        'A' { return 'act' }
        'X' { return 'act' }
    }
    return 'na'
}

function Apply-Op($o) {
    try {
        switch ($o.T) {
            'R' {
                $c = Get-Reg $o.Path $o.Name
                if ($c.Exists -and $c.Kind -eq $o.Kind -and $c.Value -ceq $o.Val) { return 'already' }
                Add-Orig (Op-Id $o) 'Reg' $o.Path $o.Name $c.Exists $c.Kind $c.Value ''
                Set-Reg $o.Path $o.Name $o.Kind $o.Val
                $v = Get-Reg $o.Path $o.Name
                if ($v.Exists -and $v.Value -ceq $o.Val) { Log ('reg ' + $o.Path + '\' + $o.Name); return 'ok' }
                return 'fail'
            }
            'P' {
                $sc = Get-ActiveScheme
                $cur = Get-PwrAC $sc $o.Sub $o.Set
                if ($null -eq $cur) { return 'skip' }
                if ($cur -eq $o.Val) { return 'already' }
                Add-Orig (Op-Id $o) 'Pwr' $o.Sub $o.Set $true 'DWord' $cur $sc
                & powercfg.exe /setacvalueindex $sc $o.Sub $o.Set $o.Val | Out-Null
                & powercfg.exe /setactive $sc | Out-Null
                if ((Get-PwrAC $sc $o.Sub $o.Set) -eq $o.Val) { Log ('power ' + $o.Set); return 'ok' }
                return 'fail'
            }
            'S' {
                $k = Svc-Key $o.Name
                $cur = Get-Reg $k 'Start'
                if (-not $cur.Exists) { return 'skip' }
                if ($cur.Value -eq '4') { return 'already' }
                $running = $false
                try { $running = ((Get-Service -Name $o.Name -ErrorAction Stop).Status -eq 'Running') } catch {}
                $dl = Get-Reg $k 'DelayedAutostart'
                $dlv = '0'; if ($dl.Exists) { $dlv = [string]$dl.Value }
                Add-Orig (Op-Id $o) 'Svc' $k $o.Name $true 'DWord' $cur.Value ([string]$running + '|' + $dlv)
                & sc.exe config $o.Name start= disabled | Out-Null
                if ((Get-Reg $k 'Start').Value -ne '4') { Set-Reg $k 'Start' 'DWord' '4' }
                if ($running) { & sc.exe stop $o.Name | Out-Null }
                if ((Get-Reg $k 'Start').Value -eq '4') { Log ('service ' + $o.Name); return 'ok' }
                return 'fail'
            }
            'M' {
                $mm = Get-MMAgent -ErrorAction Stop
                $cur = [bool]$mm.MemoryCompression
                if ($cur -eq $o.On) { return 'already' }
                $sm = Get-Service -Name 'SysMain' -ErrorAction SilentlyContinue
                if ($sm -and $sm.Status -ne 'Running' -and (Get-Reg (Svc-Key 'SysMain') 'Start').Value -ne '4') { Start-Service -Name 'SysMain' -ErrorAction SilentlyContinue }
                Add-Orig 'mm|compress' 'MM' '' 'MemoryCompression' $true 'Bool' ([string]$cur) ''
                if ($o.On) { Enable-MMAgent -MemoryCompression -ErrorAction Stop | Out-Null } else { Disable-MMAgent -MemoryCompression -ErrorAction Stop | Out-Null }
                if (([bool](Get-MMAgent).MemoryCompression) -eq $o.On) { Log 'memory compression'; return 'ok' }
                return 'fail'
            }
            'C' {
                $g = $script:SchemeGuid
                $act = Get-ActiveScheme
                if ($act -eq $g) { return 'already' }
                $made = 'existed'
                $list = (& powercfg.exe /list | Out-String)
                if ($list -notmatch $g) {
                    foreach ($src in @('e9a42b02-d5df-448d-aa00-03f14749eb61', '8c5e7fda-e8bf-4a90-9ec2-7ec8eb2c2c1a', '381b4222-f694-41f0-9685-ff5bb260df2e')) {
                        & powercfg.exe /duplicatescheme $src $g 2>$null | Out-Null
                        if ((& powercfg.exe /list | Out-String) -match $g) { break }
                    }
                    if ((& powercfg.exe /list | Out-String) -notmatch $g) { return 'fail' }
                    & powercfg.exe /changename $g 'WinBoost Max Performance' 'Created by WinBoost' 2>$null | Out-Null
                    $made = 'created'
                }
                Add-Orig 'scheme' 'Scheme' '' '' $true 'Guid' $act $made
                & powercfg.exe /setactive $g | Out-Null
                if ((Get-ActiveScheme) -eq $g) { Log 'power scheme'; return 'ok' }
                return 'fail'
            }
            'A' { return (Run-Action $o.Name) }
            'X' { return (Run-Command $o.Name) }
        }
    } catch {
        Log ('apply error ' + $o.T + ': ' + $_.Exception.Message)
        return 'fail'
    }
    return 'skip'
}

# =============================================================================
#  UNDO
# =============================================================================
function Restore-Entry($e) {
    switch ($e.Kind) {
        'Reg' { if ($e.Existed) { Set-Reg $e.Path $e.Name $e.OrigKind $e.OrigVal } else { Remove-Reg $e.Path $e.Name } }
        'Pwr' {
            $sc = [string]$e.Extra
            if ((& powercfg.exe /list | Out-String) -match $sc) { & powercfg.exe /setacvalueindex $sc $e.Path $e.Name $e.OrigVal | Out-Null }
            $now = Get-ActiveScheme
            if ($now) { & powercfg.exe /setactive $now | Out-Null }
        }
        'Svc' {
            $o = [int]$e.OrigVal
            $parts = ([string]$e.Extra) -split '\|'
            $wasRunning = ($parts[0] -eq 'True')
            $delayed = ($parts.Count -gt 1 -and $parts[1] -eq '1')
            $mode = switch ($o) { 2 { $(if ($delayed) { 'delayed-auto' } else { 'auto' }) } 3 { 'demand' } 4 { 'disabled' } default { '' } }
            if ($mode) { & sc.exe config $e.Name start= $mode | Out-Null }
            if ((Get-Reg $e.Path 'Start').Value -ne [string]$o) { Set-Reg $e.Path 'Start' 'DWord' ([string]$o) }
            if ($wasRunning -and $o -ne 4) { & sc.exe start $e.Name | Out-Null }
        }
        'MM' {
            $sm = Get-Service -Name 'SysMain' -ErrorAction SilentlyContinue
            if ($sm -and $sm.Status -ne 'Running' -and (Get-Reg (Svc-Key 'SysMain') 'Start').Value -ne '4') { Start-Service -Name 'SysMain' -ErrorAction SilentlyContinue }
            if ($e.OrigVal -eq 'True') { Enable-MMAgent -MemoryCompression -ErrorAction Stop | Out-Null } else { Disable-MMAgent -MemoryCompression -ErrorAction Stop | Out-Null }
        }
        'Scheme' {
            $orig = [string]$e.OrigVal
            if (-not $orig -or ((& powercfg.exe /list | Out-String) -notmatch $orig)) { $orig = '381b4222-f694-41f0-9685-ff5bb260df2e' }
            & powercfg.exe /setactive $orig | Out-Null
            if ((Get-ActiveScheme) -ne $orig.ToLower()) { throw 'original plan did not come back' }
            if ($e.Extra -eq 'created') { & powercfg.exe /delete $script:SchemeGuid | Out-Null }
        }
        default { throw ('unknown kind ' + $e.Kind) }
    }
}

function Undo-Entries($Ids, [switch]$All) {
    $targets = @($script:Man | Where-Object { $All -or ($Ids -contains $_.Id) })
    if ($targets.Count -gt 1) { [array]::Reverse($targets) }
    $done = @(); $fail = 0
    foreach ($e in $targets) {
        try { Restore-Entry $e; $done += $e.Id; Log ('undo ' + $e.Id) }
        catch { $fail++; Log ('undo failed ' + $e.Id + ': ' + $_.Exception.Message) }
    }
    $script:Man = @($script:Man | Where-Object { $done -notcontains $_.Id })
    Save-Man
    Refresh-Input
    return @{ Done = $done.Count; Fail = $fail }
}

function Refresh-Input {
    try {
        $m = 'HKCU:\Control Panel\Mouse'; $k = 'HKCU:\Control Panel\Keyboard'
        $a = [int[]]@([int]('0' + (Get-Reg $m 'MouseThreshold1').Value), [int]('0' + (Get-Reg $m 'MouseThreshold2').Value), [int]('0' + (Get-Reg $m 'MouseSpeed').Value))
        [void][WB.N]::SpiInts(4, 0, $a, 2)
        $s = (Get-Reg $m 'MouseSensitivity').Value
        if ($s -match '^\d+$') { [void][WB.N]::SpiVal(0x71, 0, [IntPtr][int]$s, 2) }
        $d = (Get-Reg $k 'KeyboardDelay').Value
        if ($d -match '^\d+$') { [void][WB.N]::SpiVal(0x17, [uint32]$d, [IntPtr]::Zero, 2) }
        $r = (Get-Reg $k 'KeyboardSpeed').Value
        if ($r -match '^\d+$') { [void][WB.N]::SpiVal(0x0B, [uint32]$r, [IntPtr]::Zero, 2) }
    } catch { Log ('refresh input: ' + $_.Exception.Message) }
}

# =============================================================================
#  ONE-TIME ACTIONS
# =============================================================================
$script:Freed = [int64]0
$script:Notes = @()
function Clear-Dir([string]$p) {
    $freed = [int64]0
    if (-not $p -or $p.Length -lt 12 -or -not (Test-Path -LiteralPath $p)) { return $freed }
    foreach ($f in @(Get-ChildItem -LiteralPath $p -Force -Recurse -File -ErrorAction SilentlyContinue)) {
        try { $len = $f.Length; Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop; $freed += $len } catch {}
    }
    foreach ($d in @(Get-ChildItem -LiteralPath $p -Force -Recurse -Directory -ErrorAction SilentlyContinue | Sort-Object { $_.FullName.Length } -Descending)) {
        try { if (-not (Get-ChildItem -LiteralPath $d.FullName -Force -ErrorAction SilentlyContinue)) { Remove-Item -LiteralPath $d.FullName -Force -ErrorAction Stop } } catch {}
    }
    return $freed
}
function Clear-Pattern([string]$pat) {
    $sum = [int64]0
    foreach ($d in @(Get-Item -Path $pat -Force -ErrorAction SilentlyContinue)) {
        if ($d.PSIsContainer) { $sum += (Clear-Dir $d.FullName) }
    }
    return $sum
}
function Free-RamMB { try { return [int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024) } catch { return 0 } }

function Run-Action([string]$name) {
    $la = $env:LOCALAPPDATA
    switch ($name) {
        'tmp_user' { $script:Freed += (Clear-Dir $env:TEMP); return 'ok' }
        'tmp_win' { $script:Freed += (Clear-Dir (Join-Path $env:SystemRoot 'Temp')); return 'ok' }
        'wu' {
            $was = @{}
            foreach ($s in @('wuauserv', 'bits')) {
                $was[$s] = ((Get-Service -Name $s -ErrorAction SilentlyContinue).Status -eq 'Running')
                & net.exe stop $s /y 2>$null | Out-Null
            }
            $script:Freed += (Clear-Dir (Join-Path $env:SystemRoot 'SoftwareDistribution\Download'))
            foreach ($s in @('bits', 'wuauserv')) { if ($was[$s]) { & net.exe start $s 2>$null | Out-Null } }
            return 'ok'
        }
        'shader' {
            foreach ($p in @("$la\D3DSCache", "$la\NVIDIA\DXCache", "$la\NVIDIA\GLCache", "$la\NVIDIA Corporation\NV_Cache", "$env:ProgramData\NVIDIA Corporation\NV_Cache",
                    "$la\AMD\DxCache", "$la\AMD\DxcCache", "$la\AMD\GLCache", "$la\AMD\VkCache", "$env:USERPROFILE\AppData\LocalLow\Intel\ShaderCache")) {
                $script:Freed += (Clear-Dir $p)
            }
            return 'ok'
        }
        'browser' {
            foreach ($p in @("$la\Microsoft\Edge\User Data\*\Cache", "$la\Microsoft\Edge\User Data\*\Code Cache", "$la\Microsoft\Edge\User Data\*\GPUCache",
                    "$la\Google\Chrome\User Data\*\Cache", "$la\Google\Chrome\User Data\*\Code Cache", "$la\Google\Chrome\User Data\*\GPUCache",
                    "$la\BraveSoftware\Brave-Browser\User Data\*\Cache", "$la\BraveSoftware\Brave-Browser\User Data\*\Code Cache",
                    "$la\Opera Software\Opera Stable\Cache", "$la\Opera Software\Opera GX Stable\Cache", "$la\Mozilla\Firefox\Profiles\*\cache2")) {
                $script:Freed += (Clear-Pattern $p)
            }
            return 'ok'
        }
        'dumps' {
            $script:Freed += (Clear-Dir (Join-Path $env:SystemRoot 'Minidump'))
            $script:Freed += (Clear-Dir "$la\CrashDumps")
            $dmp = Join-Path $env:SystemRoot 'MEMORY.DMP'
            if (Test-Path -LiteralPath $dmp) { try { $len = (Get-Item -LiteralPath $dmp).Length; Remove-Item -LiteralPath $dmp -Force -ErrorAction Stop; $script:Freed += $len } catch {} }
            return 'ok'
        }
        'wer' {
            $script:Freed += (Clear-Dir "$env:ProgramData\Microsoft\Windows\WER\ReportArchive")
            $script:Freed += (Clear-Dir "$env:ProgramData\Microsoft\Windows\WER\ReportQueue")
            return 'ok'
        }
        'dns' { try { Clear-DnsClientCache -ErrorAction Stop } catch { & ipconfig.exe /flushdns | Out-Null }; return 'ok' }
        'trim' { try { Optimize-Volume -DriveLetter ($env:SystemDrive.TrimEnd(':')) -ReTrim -ErrorAction Stop; return 'ok' } catch { return 'fail' } }
        'recycle' { try { Clear-RecycleBin -Force -ErrorAction Stop } catch {}; return 'ok' }
        'purge' {
            $before = Free-RamMB
            $st = [WBPurge]::Run()
            Start-Sleep -Milliseconds 200
            if ($st -ne 0) { return 'fail' }
            $script:Notes += (Tr 'note_ram' $before, (Free-RamMB))
            return 'ok'
        }
        'fontcache' {
            & net.exe stop "Windows Font Cache Service" 2>$null | Out-Null
            $script:Freed += (Clear-Dir "$la\Microsoft\Windows\Fonts")
            & net.exe start "Windows Font Cache Service" 2>$null | Out-Null
            return 'ok'
        }
        'eventlog' {
            try { foreach ($l in @(& wevtutil.exe el 2>$null)) { & wevtutil.exe cl $l 2>$null | Out-Null } } catch {}
            return 'ok'
        }
        'thumbcache' {
            & taskkill.exe /f /im explorer.exe 2>$null | Out-Null
            $script:Freed += (Clear-Pattern "$la\Microsoft\Windows\Explorer\thumbcache_*.db")
            Start-Process explorer.exe
            return 'ok'
        }
        'cleanmgr' {
            foreach ($cat in @('Temporary Files','Recycle Bin','Internet Cache Files','Downloaded Program Files','Windows Error Reporting Files','Delivery Optimization Files','Old ChkDsk Files','Setup Log Files','System error memory dump files','System error minidump files','Temporary Setup Files','Thumbnail Cache','Update Cleanup','Windows Defender')) {
                $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$cat"
                Set-Reg $key 'StateFlags0001' 'DWord' '2'
            }
            & cleanmgr.exe /sagerun:1 2>$null | Out-Null
            return 'ok'
        }
    }
    return 'skip'
}

function Run-Command([string]$name) {
    switch ($name) {
        'sfc' {
            Say ($script:cD + (Tr 'msg_running' 'sfc /scannow') + $script:cX)
            & sfc.exe /scannow 2>$null | Out-Null
            Log 'sfc done'
            return 'ok'
        }
        'dism' {
            Say ($script:cD + (Tr 'msg_running' 'DISM /RestoreHealth') + $script:cX)
            & DISM.exe /Online /Cleanup-Image /RestoreHealth 2>$null | Out-Null
            Log 'dism done'
            return 'ok'
        }
        'resetbase' {
            Say ($script:cD + (Tr 'msg_running' 'DISM /StartComponentCleanup /ResetBase') + $script:cX)
            & DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase 2>$null | Out-Null
            Log 'dism resetbase done'
            return 'ok'
        }
        'winsock' { & netsh.exe winsock reset 2>$null | Out-Null; Log 'winsock reset'; return 'ok' }
        'tcpip' { & netsh.exe int ip reset 2>$null | Out-Null; Log 'tcpip reset'; return 'ok' }
        'tcp' {
            & netsh.exe int tcp set global autotuninglevel=normal 2>$null | Out-Null
            & netsh.exe int tcp set global ecncapability=enabled 2>$null | Out-Null
            & netsh.exe int tcp set global timestamps=disabled 2>$null | Out-Null
            & netsh.exe int tcp set global initialRto=2000 2>$null | Out-Null
            Log 'tcp tuned'
            return 'ok'
        }
        'trim_force' { & fsutil.exe behavior set DisableDeleteNotify 0 2>$null | Out-Null; return 'ok' }
        'debloat_appx' {
            $names = @('*3dbuilder*','*sway*','*messaging*','*zunemusic*','*windowsalarms*','*officehub*','*skypeapp*','*getstarted*','*windowsmaps*','*solitairecollection*','*bingfinance*','*zunevideo*','*bingnews*','*people*','*windowsphone*','*bingsports*','*soundrecorder*','*windowsdvdplayer*','*disney*','*ShazamEntertainmentLtd.Shazam*','king.com.CandyCrushSaga','king.com.CandyCrushSodaSaga','Microsoft.Office.OneNote','Microsoft.SkypeApp','Microsoft.YourPhone','*MixedReality*','*OneConnect*','*FeedbackHub*','*Spotify*','*Twitter*','*Facebook*')
            foreach ($n in $names) {
                try { Get-AppxPackage -Name $n -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue } catch {}
            }
            Log 'appx debloat done'
            return 'ok'
        }
        'debloat_tasks' {
            $tasks = @(
                '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
                '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
                '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
                '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
                '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
                '\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents',
                '\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem',
                '\Microsoft\Windows\Windows Error Reporting\QueueReporting',
                '\Microsoft\Windows\Device Information\Device'
            )
            foreach ($t in $tasks) { & schtasks.exe /Change /TN $t /Disable 2>$null | Out-Null }
            Log 'telemetry tasks disabled'
            return 'ok'
        }
        'debloat_browsers' {
            & schtasks.exe /Change /Disable /TN "GoogleUpdateTaskMachineCore" 2>$null | Out-Null
            & schtasks.exe /Change /Disable /TN "GoogleUpdateTaskMachineUA" 2>$null | Out-Null
            try { foreach ($t in @(& schtasks.exe /query /fo csv 2>$null | Select-String 'Mozilla|Firefox Default Browser Agent')) { $n = ($t -split '","')[0].Trim('"'); & schtasks.exe /Change /Disable /TN $n 2>$null | Out-Null } } catch {}
            Set-Reg 'HKLM:\SOFTWARE\Policies\Google\Chrome' 'MetricsReportingEnabled' 'DWord' '0'
            Set-Reg 'HKLM:\SOFTWARE\Policies\Google\Chrome' 'ChromeCleanupReportingEnabled' 'DWord' '0'
            Set-Reg 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' 'DisableTelemetry' 'DWord' '1'
            Set-Reg 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' 'DisableDefaultBrowserAgent' 'DWord' '1'
            Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'MetricsReportingEnabled' 'DWord' '0'
            Log 'browser telemetry disabled'
            return 'ok'
        }
        'debloat_old' {
            $old = Join-Path $env:SystemDrive 'Windows.old'
            if (Test-Path -LiteralPath $old) {
                & takeown.exe /F $old /R /A 2>$null | Out-Null
                & icacls.exe $old /grant Administrators:F /T /C 2>$null | Out-Null
                Remove-Item -LiteralPath $old -Recurse -Force -ErrorAction SilentlyContinue
                $script:Freed += 0
            }
            return 'ok'
        }
    }
    return 'skip'
}

# =============================================================================
#  HARDWARE
# =============================================================================
function Get-HW {
    $h = @{ OS = ''; Build = 0; CPU = '?'; GPU = '?'; RAM = 8; Disk = '?'; Laptop = $false }
    try { $os = Get-CimInstance Win32_OperatingSystem; $h.OS = ([string]$os.Caption) -replace 'Microsoft ', ''; $h.Build = [int]$os.BuildNumber } catch {}
    try { $h.CPU = ((Get-CimInstance Win32_Processor | Select-Object -First 1).Name -replace '\s+', ' ' -replace '\(R\)|\(TM\)', '').Trim() } catch {}
    try {
        $g = @(Get-CimInstance Win32_VideoController | Where-Object { $_.Name -and $_.Name -notmatch '(?i)Microsoft Basic|Remote|Virtual|Parsec|Meta' } | ForEach-Object { [string]$_.Name })
        if ($g.Count -gt 0) { $h.GPU = ($g -join ' + ') }
    } catch {}
    try { $h.RAM = [int][math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB) } catch {}
    try {
        $p = Get-Partition -DriveLetter ($env:SystemDrive.TrimEnd(':')) -ErrorAction Stop
        $pd = Get-PhysicalDisk -ErrorAction Stop | Where-Object { [string]$_.DeviceId -eq [string]$p.DiskNumber } | Select-Object -First 1
        if ($pd) {
            if ([string]$pd.MediaType -eq 'HDD') { $h.Disk = 'HDD' }
            elseif ([string]$pd.BusType -eq 'NVMe') { $h.Disk = 'NVMe' }
            elseif ([string]$pd.MediaType -eq 'SSD') { $h.Disk = 'SSD' }
        }
    } catch {}
    try {
        $lap = @(8, 9, 10, 14, 30, 31, 32)
        foreach ($enc in @(Get-CimInstance Win32_SystemEnclosure)) { foreach ($t in @($enc.ChassisTypes)) { if ($lap -contains [int]$t) { $h.Laptop = $true } } }
        if (@(Get-CimInstance Win32_Battery).Count -gt 0) { $h.Laptop = $true }
    } catch {}
    return $h
}

# =============================================================================
#  TWEAK CATALOG
# =============================================================================
function Tw($id, $ops, [int]$risk = 0, [bool]$restart = $false) {
    return [pscustomobject]@{ Id = $id; Ops = @($ops); Risk = $risk; Restart = $restart; All = ($risk -eq 0); State = 'off' }
}
function Get-Ifaces {
    $root = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'
    $out = @()
    try {
        $s = Split-Reg $root
        $k = $s.Hive.OpenSubKey($s.Sub, $false)
        if ($k) {
            foreach ($n in $k.GetSubKeyNames()) {
                $p = $root + '\' + $n
                $d = Get-Reg $p 'DhcpIPAddress'; $st = Get-Reg $p 'IPAddress'
                $has = $false
                if ($d.Exists -and $d.Value -and $d.Value -ne '0.0.0.0' -and $d.Value -notmatch '^169\.254') { $has = $true }
                if ($st.Exists -and $st.Value -and $st.Value -ne '0.0.0.0') { $has = $true }
                if ($has) { $out += $p }
            }
            $k.Close()
        }
    } catch {}
    return $out
}

function TwUsb { Tw 'usb' @((OpPwr $script:G.USB $script:G.USBSS 0)) }
function TwBg { Tw 'bgapps' @((OpReg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 'DWord' 1)) }

function Get-Tweaks([string]$page) {
    $hw = $script:HW
    $t = @()
    $mouse = 'HKCU:\Control Panel\Mouse'; $kbd = 'HKCU:\Control Panel\Keyboard'; $acc = 'HKCU:\Control Panel\Accessibility'
    $sp = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    $mmk = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    switch ($page) {
        'input' {
            $t += Tw 'mouse_accel' @((OpReg $mouse 'MouseSpeed' 'String' '0'), (OpReg $mouse 'MouseThreshold1' 'String' '0'), (OpReg $mouse 'MouseThreshold2' 'String' '0'))
            $t += Tw 'mouse_speed' @((OpReg $mouse 'MouseSensitivity' 'String' '10'))
            $t += Tw 'kbd_fast' @((OpReg $kbd 'KeyboardDelay' 'String' '0'), (OpReg $kbd 'KeyboardSpeed' 'String' '31'))
            $t += Tw 'sticky' @((OpReg ($acc + '\StickyKeys') 'Flags' 'String' '506'), (OpReg ($acc + '\Keyboard Response') 'Flags' 'String' '122'), (OpReg ($acc + '\ToggleKeys') 'Flags' 'String' '58'))
            $t += TwUsb
        }
        'fps' {
            $t += Tw 'gamemode' @((OpReg 'HKCU:\Software\Microsoft\GameBar' 'AutoGameModeEnabled' 'DWord' 1), (OpReg 'HKCU:\Software\Microsoft\GameBar' 'AllowAutoGameMode' 'DWord' 1))
            $t += Tw 'gamedvr' @((OpReg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 'DWord' 0), (OpReg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 'DWord' 0), (OpReg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 'DWord' 0))
            $t += Tw 'mmcss' @((OpReg $sp 'SystemResponsiveness' 'DWord' 10), (OpReg ($sp + '\Tasks\Games') 'GPU Priority' 'DWord' 8), (OpReg ($sp + '\Tasks\Games') 'Priority' 'DWord' 6), (OpReg ($sp + '\Tasks\Games') 'Scheduling Category' 'String' 'High'), (OpReg ($sp + '\Tasks\Games') 'SFIO Priority' 'String' 'High'))
            $t += Tw 'win32prio' @((OpReg 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 'DWord' 38))
            $t += Tw 'nethrottle' @((OpReg $sp 'NetworkThrottlingIndex' 'DWord' 4294967295))
            $t += TwBg
            if ($hw.Build -ge 19041) {
                $t += Tw 'timer' @((OpReg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'GlobalTimerResolutionRequests' 'DWord' 1)) 0 $true
                $t += Tw 'hags' @((OpReg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 2)) 0 $true
            }
            if (-not $hw.Laptop) { $t += Tw 'pthrottle' @((OpReg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' 'PowerThrottlingOff' 'DWord' 1)) 0 $true }
            $nag = @()
            foreach ($p in @(Get-Ifaces)) { $nag += (OpReg $p 'TcpAckFrequency' 'DWord' 1); $nag += (OpReg $p 'TCPNoDelay' 'DWord' 1) }
            if ($nag.Count -gt 0) { $t += Tw 'nagle' $nag }
            $t += TwUsb
        }
        'energy' {
            $t += Tw 'scheme' @((OpScheme))
            $t += Tw 'cpumin' @((OpPwr $script:G.PROC $script:G.MINP 100)) $(if ($hw.Laptop) { 1 } else { 0 })
            $t += Tw 'unpark' @((OpPwr $script:G.PROC $script:G.CPMIN 100))
            $t += Tw 'boost' @((OpPwr $script:G.PROC $script:G.BOOST 2))
            $t += Tw 'epp' @((OpPwr $script:G.PROC $script:G.EPP 0))
            $t += Tw 'pcie' @((OpPwr $script:G.PCIE $script:G.ASPM 0))
            $t += TwUsb
            $t += Tw 'faststart' @((OpReg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 'DWord' 0))
        }
        'memory' {
            if ($hw.RAM -ge 32) { $t += Tw 'mcomp_off' @((OpMM $false)) }
            if ($hw.RAM -le 8) { $t += Tw 'mcomp_on' @((OpMM $true)) }
            if ($hw.RAM -ge 16) { $t += Tw 'pagexec' @((OpReg $mmk 'DisablePagingExecutive' 'DWord' 1)) 0 $true }
            if ($hw.Disk -in @('SSD', 'NVMe') -and $hw.RAM -ge 8) { $t += Tw 'sysmain' @((OpSvc 'SysMain')) }
            $t += TwBg
            $t += Tw 'ndu' @((OpSvc 'Ndu')) 0 $true
            $t += Tw 'purge' @((OpAct 'purge'))
        }
        'clean' {
            $t += Tw 'tmp_user' @((OpAct 'tmp_user'))
            $t += Tw 'tmp_win' @((OpAct 'tmp_win'))
            $t += Tw 'wu' @((OpAct 'wu'))
            $t += Tw 'shader' @((OpAct 'shader'))
            $t += Tw 'browser' @((OpAct 'browser'))
            $t += Tw 'dumps' @((OpAct 'dumps'))
            $t += Tw 'wer' @((OpAct 'wer'))
            $t += Tw 'dns' @((OpAct 'dns'))
            if ($hw.Disk -in @('SSD', 'NVMe')) { $t += Tw 'trim' @((OpAct 'trim')) }
            $t += Tw 'recycle' @((OpAct 'recycle')) 1
            $t += Tw 'fontcache' @((OpAct 'fontcache'))
            $t += Tw 'eventlog' @((OpAct 'eventlog'))
            $t += Tw 'thumbcache' @((OpAct 'thumbcache'))
            $t += Tw 'cleanmgr' @((OpAct 'cleanmgr'))
        }
        'privacy' {
            $t += Tw 'telemetry' @((OpReg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 'DWord' 0))
            $t += Tw 'cortana' @((OpReg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 'DWord' 0), (OpReg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 'DWord' 0))
            $t += Tw 'location' @((OpReg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocation' 'DWord' 1), (OpReg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableWindowsLocationProvider' 'DWord' 1))
            $t += Tw 'ads' @((OpReg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 'DWord' 0))
            $t += Tw 'activity' @((OpReg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackProgs' 'DWord' 0))
            $t += Tw 'feedback' @((OpReg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 'DWord' 1))
            $t += Tw 'cloudvoice' @((OpReg 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted' 'DWord' 0))
            $t += Tw 'ink' @((OpReg 'HKCU:\Software\Policies\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 'DWord' 1), (OpReg 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization' 'AllowInputPersonalization' 'DWord' 0))
            $t += Tw 'deliveryopt' @((OpReg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 'DWord' 0))
        }
        'system' {
            $t += Tw 'showext' @((OpReg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 'DWord' 0))
            $t += Tw 'longpaths' @((OpReg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' 'DWord' 1))
            $t += Tw 'menudelay' @((OpReg 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' 'String' '0'))
            $t += Tw 'startupdelay' @((OpReg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 'DWord' 0))
            $t += Tw 'balloon' @((OpReg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'EnableBalloonTips' 'DWord' 0))
            $t += Tw 'lowdisk' @((OpReg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoLowDiskSpaceChecks' 'DWord' 1))
            $t += Tw 'reserved' @((OpReg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager' 'ShippedWithReserves' 'DWord' 0), (OpReg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager' 'PassedPolicy' 'DWord' 0))
            $t += Tw 'visualfx' @((OpReg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 'DWord' 2))
            $t += Tw 'killtimeout' @((OpReg 'HKLM:\SYSTEM\CurrentControlSet\Control' 'WaitToKillServiceTimeout' 'String' '5000'))
        }
        'advanced' {
            $t += Tw 'nohyper' @((OpCmd 'bcd_nohyper')) 1 $true
            $t += Tw 'nodynamictick' @((OpCmd 'bcd_nodynamictick')) 1 $true
            $t += Tw 'bootlegacy' @((OpCmd 'bcd_bootlegacy')) 1 $true
            $t += Tw 'noquietboot' @((OpCmd 'bcd_quietboot')) 1 $true
            $t += Tw 'timeout3' @((OpCmd 'bcd_timeout3')) 1 $true
            $t += Tw 'spectre' @((OpCmd 'spectre_off')) 1 $true
            $t += Tw 'usbstor' @((OpReg 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR' 'Start' 'DWord' 4)) 1
            $t += Tw 'msimode' @((OpCmd 'msi_mode')) 1
            $t += Tw 'no8dot3' @((OpCmd 'fs_8dot3')) 1
            $t += Tw 'nolastaccess' @((OpCmd 'fs_lastaccess')) 1
        }
        'debloat' {
            $t += Tw 'debloat_appx' @((OpCmd 'debloat_appx')) 1
            $t += Tw 'debloat_tasks' @((OpCmd 'debloat_tasks')) 1
            $t += Tw 'debloat_browsers' @((OpCmd 'debloat_browsers')) 1
            $t += Tw 'debloat_old' @((OpCmd 'debloat_old')) 1
        }
        'repair' {
            $t += Tw 'repair_winsock' @((OpCmd 'winsock')) 1 $true
            $t += Tw 'repair_tcpip' @((OpCmd 'tcpip')) 1 $true
            $t += Tw 'repair_tcp' @((OpCmd 'tcp'))
            $t += Tw 'repair_trim' @((OpCmd 'trim_force'))
            $t += Tw 'repair_sfc' @((OpCmd 'sfc')) 1
            $t += Tw 'repair_dism' @((OpCmd 'dism')) 1
            $t += Tw 'repair_resetbase' @((OpCmd 'resetbase')) 1
        }
    }
    return $t
}
$script:Pages = @('input', 'fps', 'energy', 'memory', 'clean', 'privacy', 'system', 'advanced', 'debloat', 'repair')

function Tw-State($tw) {
    $on = 0; $off = 0; $act = 0
    foreach ($o in $tw.Ops) {
        $s = Op-State $o
        if ($s -eq 'on') { $on++ } elseif ($s -eq 'off') { $off++ } elseif ($s -eq 'act') { $act++ }
    }
    if (($on + $off) -eq 0) { if ($act -gt 0) { return 'act' }; return 'na' }
    if ($off -eq 0) { return 'on' }
    if ($on -eq 0) { return 'off' }
    return 'part'
}
function Tw-Ids($list) {
    $ids = @()
    foreach ($tw in @($list)) { foreach ($o in $tw.Ops) { $id = Op-Id $o; if ($id) { $ids += $id } } }
    return @($ids | Select-Object -Unique)
}

# =============================================================================
#  APPLY
# =============================================================================
function Ensure-RP {
    Say ($script:cD + (Tr 'msg_rp') + $script:cX)
    $fk = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
    $old = Get-Reg $fk 'SystemRestorePointCreationFrequency'
    try {
        Set-Reg $fk 'SystemRestorePointCreationFrequency' 'DWord' '0'
        Enable-ComputerRestore -Drive ($env:SystemDrive + '\') -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description 'WinBoost' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
        Say ($script:cB + (Tr 'msg_rp_ok') + $script:cX); Log 'restore point created'
    } catch {
        Say ($script:cR + (Tr 'msg_rp_fail') + $script:cX); Log ('restore point failed: ' + $_.Exception.Message)
    } finally {
        if ($old.Exists) { Set-Reg $fk 'SystemRestorePointCreationFrequency' 'DWord' $old.Value } else { Remove-Reg $fk 'SystemRestorePointCreationFrequency' }
    }
}

function Apply-Tweak($tw) {
    $res = @()
    foreach ($o in $tw.Ops) { $res += (Apply-Op $o) }
    if ($res -contains 'fail') { return 'fail' }
    if ($res -contains 'ok') { if ($tw.Restart) { $script:NeedRestart = $true }; return 'ok' }
    if ($res -contains 'already') { return 'already' }
    return 'skip'
}

function Run-Tweaks($list) {
    $list = @($list)
    if ($list.Count -eq 0) { return }
    $risky = @($list | Where-Object { $_.Risk -gt 0 })
    if ($risky.Count -gt 0) {
        Write-Host ''
        foreach ($r in $risky) {
            $w = Tr ('w_' + $r.Id)
            if ($w -eq ('w_' + $r.Id)) { $w = '' }
            Say ($script:cR + '! ' + (Tr ('t_' + $r.Id)) + $script:cX + $script:cD + '  ' + $w + $script:cX)
        }
        if (-not (Confirm-Yes (Tr 'q_risky'))) { return }
    }
    Show-Title
    Write-Host ''
    $script:Freed = [int64]0; $script:Notes = @(); $script:NeedRestart = $false
    $c = @{ ok = 0; already = 0; skip = 0; fail = 0 }
    $n = 0
    foreach ($tw in $list) {
        $n++
        $label = Tr ('t_' + $tw.Id)
        $r = Apply-Tweak $tw
        $c[$r]++
        $tag = switch ($r) { 'ok' { $script:cB + (Tr 'r_ok') } 'already' { $script:cD + (Tr 'r_already') } 'skip' { $script:cD + (Tr 'r_skip') } default { $script:cR + (Tr 'r_fail') } }
        Say (($script:cD + ('[{0}/{1}]' -f $n, $list.Count).PadRight(8) + $script:cX) + $script:cW + $label.PadRight(34) + $script:cX + $tag + $script:cX)
        Log ('tweak ' + $tw.Id + ' = ' + $r)
    }
    Refresh-Input
    Write-Host ''
    Show-Rule
    Say ($script:cB + (Tr 'msg_summary' $c.ok, $c.already, $c.skip, $c.fail) + $script:cX)
    if ($script:Freed -gt 0) { Say ($script:cB + (Tr 'msg_freed' (Format-Size $script:Freed)) + $script:cX) }
    foreach ($note in $script:Notes) { Say ($script:cD + $note + $script:cX) }
    if ($script:NeedRestart) { Say ($script:cR + (Tr 'msg_restart') + $script:cX) }
    Pause-Key
}

function Run-Undo($ids, [switch]$All, [string]$question) {
    $cnt = $(if ($All) { $script:Man.Count } else { @($script:Man | Where-Object { $ids -contains $_.Id }).Count })
    if ($cnt -eq 0) { Write-Host ''; Say ($script:cD + (Tr 'msg_nothing_undo') + $script:cX); Pause-Key; return }
    if (-not (Confirm-Yes (Tr $question $cnt))) { return }
    Show-Title
    Write-Host ''
    $r = $(if ($All) { Undo-Entries $null -All } else { Undo-Entries $ids })
    Say ($script:cB + (Tr 'msg_undone' $r.Done) + $script:cX)
    if ($r.Fail -gt 0) { Say ($script:cR + (Tr 'msg_undo_fail' $r.Fail) + $script:cX) }
    Say ($script:cD + (Tr 'msg_restart') + $script:cX)
    Pause-Key
}

# =============================================================================
#  SCREENS
# =============================================================================
function Parse-Idx([string]$txt, [int]$max) {
    $out = @()
    foreach ($p in ($txt -split '[,;\s]+')) {
        if (-not $p) { continue }
        if ($p -match '^(\d+)-(\d+)$') {
            $a = [int]$Matches[1]; $b = [int]$Matches[2]
            if ($a -gt $b) { $x = $a; $a = $b; $b = $x }
            for ($i = $a; $i -le $b; $i++) { if ($i -ge 1 -and $i -le $max -and $out -notcontains $i) { $out += $i } }
        } elseif ($p -match '^\d+$') {
            $i = [int]$p
            if ($i -ge 1 -and $i -le $max -and $out -notcontains $i) { $out += $i }
        } else { return $null }
    }
    return , $out
}

function Page-Loop([string]$page) {
    while ($true) {
        Show-Title
        Write-Host ''
        Say ($script:cD + (Tr 'loading') + $script:cX)
        $every = @(Get-Tweaks $page)
        $vis = @()
        foreach ($t in $every) {
            $t.State = Tw-State $t
            if ($t.State -ne 'na') { $vis += $t }
        }
        Show-Title
        Write-Host ''
        Write-Host (Center ($script:cR + '» ' + $script:cB + (Tr ('p_' + $page)) + $script:cX))
        Write-Host ''
        $w = CW
        $descW = [math]::Max(10, $w - 54)
        $i = 0
        foreach ($t in $vis) {
            $i++
            $mark = switch ($t.State) { 'on' { $script:cB + '[ON ]' } 'part' { $script:cR + '[ ~ ]' } 'act' { $script:cD + '[ * ]' } default { $script:cD + '[ - ]' } }
            $label = (Cut (Tr ('t_' + $t.Id)) 31).PadRight(31)
            $bang = $(if ($t.Risk -gt 0) { $script:cR + ' !' + $script:cX } else { '  ' })
            $name = $(if ($t.State -eq 'on') { $script:cB } else { $script:cW })
            Say ($script:cR + ('{0,2}' -f $i) + $script:cX + ' ' + $mark + $script:cX + ' ' + $name + $label + $script:cX + $bang + ' ' + $script:cD + (Cut (Tr ('d_' + $t.Id)) $descW) + $script:cX)
        }
        Write-Host ''
        Show-Rule
        Write-Host (Center ((Key 'A' (Tr 'ui_apply')) + '    ' + (Key 'U' (Tr 'ui_undo')) + '    ' + (Key 'B' (Tr 'ui_back'))))
        Write-Host (Center ($script:cD + (Tr 'ui_hint') + $script:cX))
        Write-Host (Center ($script:cD + (Tr 'ui_legend') + $script:cX))
        $c = (Ask).ToLower()
        if ($c -eq '' -or $c -eq 'b') { return }
        if ($c -eq 'a') {
            $sel = @($vis | Where-Object { $_.All -and $_.State -ne 'on' })
            if ($sel.Count -eq 0) { Write-Host ''; Say ($script:cD + (Tr 'msg_nothing_apply') + $script:cX); Pause-Key; continue }
            if (Confirm-Yes (Tr 'q_apply' $sel.Count)) { Run-Tweaks $sel }
            continue
        }
        if ($c -match '^u\s*(.*)$') {
            $arg = $Matches[1].Trim()
            if ($page -eq 'clean' -or $page -eq 'debloat' -or $page -eq 'repair') { Write-Host ''; Say ($script:cD + (Tr 'msg_onetime') + $script:cX); Pause-Key; continue }
            if ($arg -eq '') { Run-Undo (Tw-Ids $every) -question 'q_undo'; continue }
            $idx = Parse-Idx $arg $vis.Count
            if ($null -eq $idx -or @($idx).Count -eq 0) { continue }
            $pick = @(); foreach ($n in $idx) { $pick += $vis[$n - 1] }
            Run-Undo (Tw-Ids $pick) -question 'q_undo'
            continue
        }
        $idx = Parse-Idx $c $vis.Count
        if ($null -eq $idx -or @($idx).Count -eq 0) { continue }
        $pick = @(); foreach ($n in $idx) { $pick += $vis[$n - 1] }
        Run-Tweaks $pick
    }
}

function Apply-AllPages {
    Show-Title
    Write-Host ''
    Say ($script:cD + (Tr 'loading') + $script:cX)
    $seen = @{}; $sel = @()
    foreach ($p in $script:Pages) {
        foreach ($t in @(Get-Tweaks $p)) {
            if (-not $t.All -or $seen.ContainsKey($t.Id)) { continue }
            $seen[$t.Id] = $true
            $s = Tw-State $t
            if ($s -eq 'na' -or $s -eq 'on') { continue }
            $sel += $t
        }
    }
    if ($sel.Count -eq 0) { Write-Host ''; Say ($script:cD + (Tr 'msg_nothing_apply') + $script:cX); Pause-Key; return }
    if (Confirm-Yes (Tr 'q_apply' $sel.Count)) { Run-Tweaks $sel }
}

function Revert-Menu {
    while ($true) {
        Show-Title
        Write-Host ''
        Write-Host (Center ($script:cR + '» ' + $script:cB + (Tr 'p_revert') + $script:cX))
        Write-Host ''
        Write-Host (Center ($script:cD + (Tr 'rv_count' $script:Man.Count) + $script:cX))
        Write-Host ''
        foreach ($k in 1..5) { Write-Host (Center (PadV (Key ([string]$k) (Tr ('rv_' + $k))) 40)) }
        Write-Host ''
        Show-Rule
        Write-Host (Center (Key 'B' (Tr 'ui_back')))
        $c = (Ask).ToLower()
        if ($c -eq '1') { Run-Undo $null -All -question 'q_undoall' }
        elseif ($c -eq '2') { Show-Title; Write-Host ''; Ensure-RP; Pause-Key }
        elseif ($c -eq '3') { try { Start-Process 'rstrui.exe' } catch {} }
        elseif ($c -eq '4') { try { Start-Process explorer.exe $script:Root } catch {} }
        elseif ($c -eq '5') { try { Start-Process explorer.exe $script:LogDir } catch {} }
        else { return }
    }
}

function Choose-Lang {
    Show-Title
    Write-Host ''
    Write-Host (Center ($script:cR + '» ' + $script:cB + 'Language / Idioma' + $script:cX))
    Write-Host ''
    Write-Host (Center (PadV (Key '1' 'English') 24))
    Write-Host (Center (PadV (Key '2' 'Português (Brasil)') 24))
    $c = Ask
    if ($c -eq '2') { $script:Lang = 'pt' } elseif ($c -eq '1') { $script:Lang = 'en' } else { return }
    try { [IO.File]::WriteAllText($script:LangFile, $script:Lang) } catch {}
}

function Main-Menu {
    $hw = $script:HW
    Show-Title
    Write-Host ''
    $pcType = $(if ($hw.Laptop) { Tr 'hw_laptop' } else { Tr 'hw_desktop' })
    $info = (Tr 'hw_cpu') + ': ' + (Cut $hw.CPU 34) + '  |  ' + (Tr 'hw_gpu') + ': ' + (Cut $hw.GPU 30)
    $info2 = (Tr 'hw_ram') + ': ' + $hw.RAM + ' GB  |  ' + (Tr 'hw_disk') + ': ' + $hw.Disk + '  |  ' + (Tr 'hw_pc') + ': ' + $pcType + '  |  ' + $hw.OS
    Write-Host (Center ($script:cD + $info + $script:cX))
    Write-Host (Center ($script:cD + (Cut $info2 96) + $script:cX))
    Write-Host ''
    $cells = @(
        (Key '1' (Tr 'p_input')), (Key '2' (Tr 'p_fps')), (Key '3' (Tr 'p_energy')),
        (Key '4' (Tr 'p_memory')), (Key '5' (Tr 'p_clean')), (Key '6' (Tr 'p_privacy')),
        (Key '7' (Tr 'p_system')), (Key '8' (Tr 'p_advanced')), (Key '9' (Tr 'p_debloat')),
        (Key '0' (Tr 'p_repair')), (Key 'R' (Tr 'p_revert')), ('')
    )
    for ($i = 0; $i -lt $cells.Count; $i += 3) {
        Write-Host (Center ((PadV $cells[$i] 26) + (PadV $cells[$i + 1] 26) + (PadV $cells[$i + 2] 26)))
        Write-Host ''
    }
    Show-Rule
    Write-Host (Center ((PadV (Key 'A' (Tr 'ui_applyall')) 34) + (PadV (Key 'U' (Tr 'ui_undoall')) 22)))
    Write-Host (Center ((PadV (Key 'L' (Tr 'ui_lang')) 34) + (PadV (Key 'X' (Tr 'ui_exit')) 22)))
    return (Ask).ToLower()
}

# =============================================================================
#  START
# =============================================================================
if (Test-Path -LiteralPath $script:LangFile) {
    $l = ([IO.File]::ReadAllText($script:LangFile)).Trim()
    if ($l -in @('en', 'pt')) { $script:Lang = $l }
} else {
    Choose-Lang
}
Load-Man
Show-Title
Write-Host ''
Say ($script:cD + (Tr 'detecting') + $script:cX)
$script:HW = Get-HW
Log ('WinBoost ' + $script:Ver + ' started | ' + $script:HW.OS + ' | ' + $script:HW.CPU + ' | ' + $script:HW.GPU + ' | ' + $script:HW.RAM + ' GB | ' + $script:HW.Disk)

while ($true) {
    $c = Main-Menu
    if ($c -in @('1','2','3','4','5','6','7','8','9','0')) {
        $idx = [array]::IndexOf(@('1','2','3','4','5','6','7','8','9','0'), $c)
        Page-Loop $script:Pages[$idx]
    }
    elseif ($c -eq 'r') { Revert-Menu }
    elseif ($c -eq 'a') { Apply-AllPages }
    elseif ($c -eq 'u') { Run-Undo $null -All -question 'q_undoall' }
    elseif ($c -eq 'l') { Choose-Lang }
    elseif ($c -eq 'x') { break }
}
Clear-Host
Write-Host ''
Write-Host '  WinBoost closed.'
Write-Host ''