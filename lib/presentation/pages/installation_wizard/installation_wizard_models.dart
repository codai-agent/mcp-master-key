import '../../../core/models/mcp_server.dart';

/// 安装向导的步骤枚举
enum WizardStep {
  configure,
  analyze,
  options,
  execute,
}

/// 安装向导状态模型
class InstallationWizardState {
  final WizardStep currentStep;
  final String configError;
  final Map<String, dynamic> parsedConfig;
  final McpInstallType? detectedInstallType;
  final bool needsAdditionalInstall;
  final String analysisResult;
  final String selectedInstallType;
  final bool isInstalling;
  final List<String> installationLogs;
  final bool installationSuccess;
  final bool isAutoAdvancing;
  final int? currentInstallProcessPid;
  
  // 表单数据
  final String serverName;
  final String serverDescription;
  final String configText;
  final String githubUrl;
  final String localPath;
  final String installCommand;

  const InstallationWizardState({
    this.currentStep = WizardStep.configure,
    this.configError = '',
    this.parsedConfig = const {},
    this.detectedInstallType,
    this.needsAdditionalInstall = false,
    this.analysisResult = '',
    this.selectedInstallType = 'github',
    this.isInstalling = false,
    this.installationLogs = const [],
    this.installationSuccess = false,
    this.isAutoAdvancing = false,
    this.currentInstallProcessPid,
    this.serverName = '',
    this.serverDescription = '',
    this.configText = '',
    this.githubUrl = '',
    this.localPath = '',
    this.installCommand = '',
  });

  InstallationWizardState copyWith({
    WizardStep? currentStep,
    String? configError,
    Map<String, dynamic>? parsedConfig,
    McpInstallType? detectedInstallType,
    bool? needsAdditionalInstall,
    String? analysisResult,
    String? selectedInstallType,
    bool? isInstalling,
    List<String>? installationLogs,
    bool? installationSuccess,
    bool? isAutoAdvancing,
    int? currentInstallProcessPid,
    String? serverName,
    String? serverDescription,
    String? configText,
    String? githubUrl,
    String? localPath,
    String? installCommand,
  }) {
    return InstallationWizardState(
      currentStep: currentStep ?? this.currentStep,
      configError: configError ?? this.configError,
      parsedConfig: parsedConfig ?? this.parsedConfig,
      detectedInstallType: detectedInstallType ?? this.detectedInstallType,
      needsAdditionalInstall: needsAdditionalInstall ?? this.needsAdditionalInstall,
      analysisResult: analysisResult ?? this.analysisResult,
      selectedInstallType: selectedInstallType ?? this.selectedInstallType,
      isInstalling: isInstalling ?? this.isInstalling,
      installationLogs: installationLogs ?? this.installationLogs,
      installationSuccess: installationSuccess ?? this.installationSuccess,
      isAutoAdvancing: isAutoAdvancing ?? this.isAutoAdvancing,
      currentInstallProcessPid: currentInstallProcessPid ?? this.currentInstallProcessPid,
      serverName: serverName ?? this.serverName,
      serverDescription: serverDescription ?? this.serverDescription,
      configText: configText ?? this.configText,
      githubUrl: githubUrl ?? this.githubUrl,
      localPath: localPath ?? this.localPath,
      installCommand: installCommand ?? this.installCommand,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep.index,
      'configError': configError,
      'parsedConfig': parsedConfig,
      'detectedInstallType': detectedInstallType?.name,
      'needsAdditionalInstall': needsAdditionalInstall,
      'analysisResult': analysisResult,
      'selectedInstallType': selectedInstallType,
      'isInstalling': isInstalling,
      'installationLogs': installationLogs,
      'installationSuccess': installationSuccess,
      'isAutoAdvancing': isAutoAdvancing,
      'currentInstallProcessPid': currentInstallProcessPid,
      'serverName': serverName,
      'serverDescription': serverDescription,
      'configText': configText,
      'githubUrl': githubUrl,
      'localPath': localPath,
      'installCommand': installCommand,
    };
  }

  factory InstallationWizardState.fromJson(Map<String, dynamic> json) {
    return InstallationWizardState(
      currentStep: WizardStep.values[json['currentStep'] ?? 0],
      configError: json['configError'] ?? '',
      parsedConfig: Map<String, dynamic>.from(json['parsedConfig'] ?? {}),
      detectedInstallType: json['detectedInstallType'] != null 
          ? McpInstallType.values.firstWhere(
              (e) => e.name == json['detectedInstallType'],
              orElse: () => McpInstallType.uvx,
            )
          : null,
      needsAdditionalInstall: json['needsAdditionalInstall'] ?? false,
      analysisResult: json['analysisResult'] ?? '',
      selectedInstallType: json['selectedInstallType'] ?? 'github',
      isInstalling: json['isInstalling'] ?? false,
      installationLogs: List<String>.from(json['installationLogs'] ?? []),
      installationSuccess: json['installationSuccess'] ?? false,
      isAutoAdvancing: json['isAutoAdvancing'] ?? false,
      currentInstallProcessPid: json['currentInstallProcessPid'],
      serverName: json['serverName'] ?? '',
      serverDescription: json['serverDescription'] ?? '',
      configText: json['configText'] ?? '',
      githubUrl: json['githubUrl'] ?? '',
      localPath: json['localPath'] ?? '',
      installCommand: json['installCommand'] ?? '',
    );
  }
}

/// 安装分析结果
class InstallAnalysisResult {
  final McpInstallType installType;
  final bool needsAdditionalInstall;
  final String analysisMessage;
  final String? packageName;
  final List<String> args;
  final Map<String, String> envVars;

  const InstallAnalysisResult({
    required this.installType,
    required this.needsAdditionalInstall,
    required this.analysisMessage,
    this.packageName,
    this.args = const [],
    this.envVars = const {},
  });
} 