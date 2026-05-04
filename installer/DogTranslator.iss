#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

[Setup]
AppId={{8B8B4D0C-6D0F-4E8D-BE2D-3A3B02F19D13}
AppName=DogTranslator
AppVersion={#AppVersion}
AppPublisher=OpenAI Codex Workspace
AppPublisherURL=https://example.invalid/dogtranslator
DefaultDirName={localappdata}\Programs\DogTranslator
DefaultGroupName=DogTranslator
DisableDirPage=no
DisableProgramGroupPage=yes
OutputDir=..\dist\installer
OutputBaseFilename=DogTranslator-Setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\dog_translator.exe
SetupLogging=yes

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "デスクトップ アイコンを作成する"; GroupDescription: "追加タスク:"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\dog_voice_local\app\*"; DestDir: "{app}\dog_voice_local\app"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\dog_voice_local\README.md"; DestDir: "{app}\dog_voice_local"; Flags: ignoreversion
Source: "..\dog_voice_local\release-requirements.txt"; DestDir: "{app}\dog_voice_local"; Flags: ignoreversion
Source: "..\dog_voice_local\sample_test.wav"; DestDir: "{app}\dog_voice_local"; Flags: ignoreversion
Source: "scripts\Install-Dog2vecRuntime.ps1"; DestDir: "{app}\installer-scripts"; Flags: ignoreversion
Source: "scripts\Uninstall-Dog2vecRuntime.ps1"; DestDir: "{app}\installer-scripts"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\DogTranslator"; Filename: "{app}\dog_translator.exe"
Name: "{autodesktop}\DogTranslator"; Filename: "{app}\dog_translator.exe"; Tasks: desktopicon

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -NoProfile -File ""{app}\installer-scripts\Install-Dog2vecRuntime.ps1"" -AppInstallDir ""{app}"" -RuntimeRoot ""{localappdata}\DogTranslator\dog2vec-runtime"" -ConfigRoot ""{localappdata}\DogTranslator\.dog2vec"""; \
  StatusMsg: "Dog2vec ローカル runtime を構成しています。モデルと依存関係のダウンロードが完了するまでお待ちください..."; \
  Flags: waituntilterminated
Filename: "{app}\dog_translator.exe"; Description: "DogTranslator を起動する"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -NoProfile -File ""{app}\installer-scripts\Uninstall-Dog2vecRuntime.ps1"" -RuntimeRoot ""{localappdata}\DogTranslator\dog2vec-runtime"" -ConfigRoot ""{localappdata}\DogTranslator\.dog2vec"""; \
  RunOnceId: "DogTranslatorRuntimeCleanup"; \
  Flags: runhidden waituntilterminated
